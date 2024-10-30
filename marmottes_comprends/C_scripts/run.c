#include <stdio.h>
#include <stdlib.h>
#include <dirent.h>
#include <string.h>
#include <pthread.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <json-c/json.h>

#define MAX_PATH_LENGTH 4096
#define MAX_THREAD_COUNT 8  // Adjust based on CPU cores
#define MD5_HASH_LENGTH 32  // Length of MD5 hash

typedef struct FileNode {
    char path[MAX_PATH_LENGTH];
    struct FileNode* next;
} FileNode;

typedef struct {
    FileNode* head;
    FileNode* tail;
    pthread_mutex_t mutex;
} FileQueue;

FileQueue fileQueue;
pthread_mutex_t print_mutex = PTHREAD_MUTEX_INITIALIZER;
int active_threads = 0;
int use_baseline = 0;
int use_diff = 0;
FILE* baseline_file = NULL;
FILE* diff_file = NULL;
unsigned long total_files_processed = 0;
unsigned long error_count = 0;
int files_in_queue = 0;

// Structure to store file hashes for comparison
struct hash_entry {
    char path[MAX_PATH_LENGTH];
    char hash[MD5_HASH_LENGTH + 1];
    struct hash_entry* next;
};

struct hash_entry* hash_list = NULL;  // Hash list for comparison

// Function to load and process diff file
void load_diff_file(const char* filename) {
    FILE* file = fopen(filename, "r");
    if (!file) {
        fprintf(stderr, "Error opening diff file: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }

    char line[1024];
    while (fgets(line, sizeof(line), file)) {
        struct hash_entry* entry = (struct hash_entry*)malloc(sizeof(struct hash_entry));
        sscanf(line, "%32s %s", entry->hash, entry->path);
        entry->next = hash_list;
        hash_list = entry;
    }

    fclose(file);
}

// Retrieve hash for a given file path
char* find_hash_for_path(const char* path) {
    struct hash_entry* current = hash_list;
    while (current != NULL) {
        if (strcmp(current->path, path) == 0) {
            return current->hash;
        }
        current = current->next;
    }
    return NULL;
}

// Compare and display hash differences
void check_diff_and_output(const char* path, const char* new_hash) {
    char* old_hash = find_hash_for_path(path);
    if (old_hash != NULL) {
        if (strcmp(old_hash, new_hash) != 0) {
            pthread_mutex_lock(&print_mutex);
            printf("Difference found: %s\n", path);
            pthread_mutex_unlock(&print_mutex);
        }
    } else {
        pthread_mutex_lock(&print_mutex);
        printf("New file: %s\n", path);
        pthread_mutex_unlock(&print_mutex);
    }
}

// Add file path to queue
void enqueue_file(const char* path) {
    FileNode* node = (FileNode*)malloc(sizeof(FileNode));
    if (node == NULL) {
        fprintf(stderr, "Error: Unable to allocate memory for new FileNode\n");
        exit(EXIT_FAILURE);
    }
    strncpy(node->path, path, MAX_PATH_LENGTH);
    node->next = NULL;

    pthread_mutex_lock(&fileQueue.mutex);
    if (fileQueue.tail) {
        fileQueue.tail->next = node;
        fileQueue.tail = node;
    } else {
        fileQueue.head = fileQueue.tail = node;
    }
    files_in_queue++;
    pthread_mutex_unlock(&fileQueue.mutex);
}

// Fetch file from queue
char* dequeue_file() {
    pthread_mutex_lock(&fileQueue.mutex);
    if (!fileQueue.head) {
        pthread_mutex_unlock(&fileQueue.mutex);
        return NULL;
    }
    FileNode* node = fileQueue.head;
    fileQueue.head = node->next;
    if (!fileQueue.head) {
        fileQueue.tail = NULL;
    }
    files_in_queue--;
    pthread_mutex_unlock(&fileQueue.mutex);

    char* path = strdup(node->path);
    free(node);
    return path;
}

// Generate MD5 hash for a file
void get_md5_hash(const char* path, char* output) {
    char command[MAX_PATH_LENGTH + 10];
    snprintf(command, sizeof(command), "md5sum \"%s\"", path);

    FILE* pipe = popen(command, "r");
    if (!pipe) {
        perror("popen");
        exit(EXIT_FAILURE);
    }

    char md5_output[MD5_HASH_LENGTH + 2];
    if (fscanf(pipe, "%32s", md5_output) == 1) {
        strcpy(output, md5_output);
    } else {
        output[0] = '\0';
    }

    pclose(pipe);
}

// Worker thread function for hashing
void* hash_worker(void* arg) {
    (void)arg;
    char* file_path;

    while ((file_path = dequeue_file()) != NULL) {
        char md5_hash[MD5_HASH_LENGTH + 1];

        get_md5_hash(file_path, md5_hash);

        if (use_diff) {
            check_diff_and_output(file_path, md5_hash);
        } else {
            if (use_baseline && baseline_file) {
                fprintf(baseline_file, "%s %s\n", md5_hash, file_path);
            }
        }

        free(file_path);
        total_files_processed++;
    }

    pthread_mutex_lock(&fileQueue.mutex);
    active_threads--;
    pthread_mutex_unlock(&fileQueue.mutex);
    return NULL;
}

// Function to determine if a path should be skipped
int should_skip(const char* path) {
    // Skip /sys, /proc, /dev directories and their subdirectories
    if (strncmp(path, "/sys", 4) == 0 ||
        strncmp(path, "/proc", 5) == 0 ||
        strncmp(path, "/dev", 4) == 0) {
        return 1;
    }

    // Skip /sys/kernel/tracing and its subdirectories
    if (strncmp(path, "/sys/kernel/tracing", 19) == 0) {
        return 1;
    }

    // Skip Tracker/GNOME-related files
    if (strstr(path, "/.cache/tracker") != NULL ||
        strstr(path, "/.local/share/gvfs-metadata") != NULL ||
        strstr(path, "/usr/lib/tracker") != NULL ||
        strstr(path, "/usr/share/gnome") != NULL ||
        strstr(path, "/usr/lib/gnome") != NULL) {
        return 1;
    }

    // Skip GVFS metadata
    if (strstr(path, "/gvfs") != NULL) {
        return 1;
    }

    // Skip APT cache
    if (strncmp(path, "/var/cache/apt/archives", 23) == 0) {
        return 1;
    }

    // Skip logs and journals
    if (strncmp(path, "/var/log", 8) == 0 ||
        strncmp(path, "/run/log", 8) == 0 ||
        strstr(path, "/log/journal") != NULL) {
        return 1;
    }

    // Skip Snap files
    if (strncmp(path, "/snap", 5) == 0 ||
        strncmp(path, "/var/snap", 9) == 0 ||
        strncmp(path, "/var/lib/snapd", 14) == 0) {
        return 1;
    }

    // Skip new files under /sys/, /var/, /snap/, and /usr/ directories
    if (strncmp(path, "/sys/", 5) == 0 ||
        strncmp(path, "/var/", 5) == 0 ||
        strncmp(path, "/snap/", 6) == 0 ||
        strncmp(path, "/usr/", 5) == 0) {
        return 1;
    }

    return 0;
}

// Traverse directories recursively
void traverse_directory(const char* dir_path) {
    if (should_skip(dir_path)) {
        return;
    }

    DIR* dir = opendir(dir_path);
    if (!dir) {
        return;
    }

    struct dirent* entry;
    char path[MAX_PATH_LENGTH];
    while ((entry = readdir(dir)) != NULL) {
        if (strcmp(entry->d_name, ".") == 0 || strcmp(entry->d_name, "..") == 0) {
            continue;
        }

        snprintf(path, MAX_PATH_LENGTH, "%s/%s", dir_path, entry->d_name);

        // Check if we should skip this path
        if (should_skip(path)) {
            continue;
        }

        struct stat statbuf;
        if (lstat(path, &statbuf) == -1) {
            continue;
        }

        if (S_ISDIR(statbuf.st_mode)) {
            traverse_directory(path);
        } else if (S_ISREG(statbuf.st_mode)) {
            enqueue_file(path);
        }
    }
    closedir(dir);
}

// Display program usage information
void print_usage(const char* program_name) {
    printf("Usage: %s [baseline <output_file>] [diff <diff_file>]\n", program_name);
    printf("Options:\n");
    printf("  baseline <output_file>  Save MD5 hashes to the specified file.\n");
    printf("  diff <diff_file>        Compare MD5 hashes with the specified diff file.\n");
}

int main(int argc, char* argv[]) {
    if (argc > 1 && strcmp(argv[1], "baseline") == 0) {
        if (argc < 3) {
            fprintf(stderr, "Error: No output file specified for baseline.\n");
            print_usage(argv[0]);
            return EXIT_FAILURE;
        }
        use_baseline = 1;
        baseline_file = fopen(argv[2], "w");
        if (!baseline_file) {
            fprintf(stderr, "Error opening output file: %s\n", strerror(errno));
            return EXIT_FAILURE;
        }
    } else if (argc > 1 && strcmp(argv[1], "diff") == 0) {
        if (argc < 3) {
            fprintf(stderr, "Error: No diff file specified for comparison.\n");
            print_usage(argv[0]);
            return EXIT_FAILURE;
        }
        use_diff = 1;
        load_diff_file(argv[2]);
    } else {
        print_usage(argv[0]);
        return EXIT_FAILURE;
    }

    fileQueue.head = fileQueue.tail = NULL;
    pthread_mutex_init(&fileQueue.mutex, NULL);

    traverse_directory("/");

    pthread_t threads[MAX_THREAD_COUNT];
    active_threads = MAX_THREAD_COUNT;

    for (int i = 0; i < MAX_THREAD_COUNT; ++i) {
        if (pthread_create(&threads[i], NULL, hash_worker, NULL) != 0) {
            fprintf(stderr, "Error creating thread\n");
            return EXIT_FAILURE;
        }
    }

    for (int i = 0; i < MAX_THREAD_COUNT; ++i) {
        pthread_join(threads[i], NULL);
    }

    if (use_baseline && baseline_file) {
        pthread_mutex_lock(&print_mutex);
        printf("Saving hashes to %s\n", argv[2]);
        pthread_mutex_unlock(&print_mutex);
        fclose(baseline_file);
    }

    pthread_mutex_destroy(&fileQueue.mutex);
    pthread_mutex_destroy(&print_mutex);

    return EXIT_SUCCESS;
}
