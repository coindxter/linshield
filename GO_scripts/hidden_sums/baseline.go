package main

import (
	"fmt"
	"hash/crc32"
	"io"
	"os"
	"path/filepath"
	"runtime"
	"sync"
)

func main() {
	fileTypes := map[string][]string{
		"document": {"*.pdf", "*.doc", "*.docx"},
		"audio":    {"*.mp3", "*.ogg", "*.mkv", "*.wav", "*.flac"},
		"video":    {"*.mov", "*.mp4", "*.wmv", "*.webm"},
		"script":   {"*.sh", "*.exe", "*.pl", "*.py", "*.rb", "*.js", "*.php"},
		"txt":      {"*.txt", "*.md", "*.csv"},
	}

	// Create a WaitGroup to wait for all goroutines to finish
	var wg sync.WaitGroup

	// Channel to collect files to process
	fileChan := make(chan string, 10000)

	// Map to store file patterns and their corresponding types
	patternMap := make(map[string]string)
	for fileType, patterns := range fileTypes {
		for _, pattern := range patterns {
			patternMap[pattern] = fileType
		}
	}

	// Number of worker goroutines
	numWorkers := runtime.NumCPU() * 2

	// Start worker goroutines
	for i := 0; i < numWorkers; i++ {
		wg.Add(1)
		go worker(fileChan, patternMap, &wg)
	}

	// Walk the directory tree and send file paths to fileChan
	go func() {
		findFiles("/", fileChan)
		close(fileChan)
	}()

	// Wait for all workers to finish
	wg.Wait()
}

func computeCRC32(filePath string) (uint32, error) {
	file, err := os.Open(filePath)
	if err != nil {
		return 0, err
	}
	defer file.Close()

	hasher := crc32.NewIEEE()
	if _, err := io.Copy(hasher, file); err != nil {
		return 0, err
	}

	return hasher.Sum32(), nil
}

func worker(fileChan <-chan string, patternMap map[string]string, wg *sync.WaitGroup) {
	defer wg.Done()
	for path := range fileChan {
		fileName := filepath.Base(path)
		fileType := "other"
		for pattern, fType := range patternMap {
			match, _ := filepath.Match(pattern, fileName)
			if match {
				fileType = fType
				break
			}
		}

		if _, err := os.Stat(path); err == nil {
			hash, err := computeCRC32(path)
			if err == nil {
				fmt.Printf("{\"file_type\":\"%s\",\"path\":\"%s\",\"crc32\":\"%08x\"}\n", fileType, path, hash)
			}
		}
	}
}

func findFiles(root string, fileChan chan<- string) {
	filepath.Walk(root, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return nil // Ignore errors and continue
		}
		if !info.IsDir() {
			fileChan <- path
		}
		return nil
	})
}
