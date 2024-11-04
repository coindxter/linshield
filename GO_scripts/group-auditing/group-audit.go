package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"strings"
)

type User struct {
	Name   string   `json:"name"`
	Groups []string `json:"groups"`
}

type ReadMe struct {
	AllUsers []User `json:"all_users"`
	NewUsers []User `json:"new_users"`
}

func main() {
	// Execute command to fetch groups
	cmd := exec.Command("bash", "-c", `awk -F':' '$4 {print}' /etc/group | grep -v "sudo" | grep -v "adm" | grep -v "audio" | grep -v "cdrom"`)
	output, err := cmd.Output()
	if err != nil {
		fmt.Println("Error running command:", err)
		return
	}

	groupData := strings.Split(strings.TrimSpace(string(output)), "\n")
	groups := make(map[string][]string)
	for _, line := range groupData {
		parts := strings.Split(line, ":")
		groupName := parts[0]
		groupMembers := strings.Split(parts[len(parts)-1], ",")
		groups[groupName] = groupMembers
	}

	// Read the JSON file
	file, err := os.Open(".marmottes-configs/ReadMe.json")
	if err != nil {
		fmt.Println("Error opening JSON file:", err)
		return
	}
	defer file.Close()

	var readme ReadMe
	jsonParser := json.NewDecoder(file)
	if err = jsonParser.Decode(&readme); err != nil {
		fmt.Println("Error parsing JSON:", err)
		return
	}

	// Add new users to the list of all users
	for _, user := range readme.NewUsers {
		readme.AllUsers = append(readme.AllUsers, user)
	}

	var groupsToCreate []string
	var missingFromGroup []map[string]string
	var shouldNotBeInGroup []map[string]string

	// Process users and groups
	for _, user := range readme.AllUsers {
		for _, group := range user.Groups {
			if _, ok := groups[group]; !ok {
				groupsToCreate = append(groupsToCreate, group)
				missingFromGroup = append(missingFromGroup, map[string]string{"user": user.Name, "group": group})
			} else {
				if !contains(groups[group], user.Name) {
					missingFromGroup = append(missingFromGroup, map[string]string{"user": user.Name, "group": group})
				} else {
					shouldNotBeInGroup = append(shouldNotBeInGroup, map[string]string{"user": user.Name, "group": group})
				}
			}
		}
	}

	if len(groupsToCreate) == 0 && len(missingFromGroup) == 0 && len(shouldNotBeInGroup) == 0 {
		fmt.Println("No changes needed")
		return
	}

	if len(groupsToCreate) > 0 {
		fmt.Println("Adding Groups:")
		for _, group := range groupsToCreate {
			fmt.Printf("    - %s\n", group)
		}
	}

	if len(missingFromGroup) > 0 || len(shouldNotBeInGroup) > 0 {
		fmt.Println("\nAuditing Groups:")
		for group := range groups {
			if contains(groupsToCreate, group) || anyGroupMatches(missingFromGroup, group) || anyGroupMatches(shouldNotBeInGroup, group) {
				fmt.Printf("  - %s\n", group)
				fmt.Println("    - Users Missing:")
				for _, user := range missingFromGroup {
					if user["group"] == group {
						fmt.Printf("      - %s\n", user["user"])
					}
				}
				fmt.Println("    - Users that should not be in group:")
				for _, user := range shouldNotBeInGroup {
					if user["group"] == group {
						fmt.Printf("      - %s\n", user["user"])
					}
				}
			}
		}
	}

	fmt.Print("Would you like to continue with these changes? (y/n): ")
	reader := bufio.NewReader(os.Stdin)
	confirm, _ := reader.ReadString('\n')
	confirm = strings.TrimSpace(strings.ToLower(confirm))
	if confirm != "y" && confirm != "yes" {
		return
	}

	for _, group := range groupsToCreate {
		cmd := exec.Command("sudo", "groupadd", group)
		err := cmd.Run()
		if err != nil {
			fmt.Printf("Error creating group: %s\n", group)
		} else {
			fmt.Printf("Created group: %s\n", group)
		}
	}

	for _, user := range missingFromGroup {
		cmd := exec.Command("sudo", "usermod", "-aG", user["group"], user["user"])
		err := cmd.Run()
		if err != nil {
			fmt.Printf("Error adding %s to %s\n", user["user"], user["group"])
		} else {
			fmt.Printf("Added %s to %s\n", user["user"], user["group"])
		}
	}

	for _, user := range shouldNotBeInGroup {
		cmd := exec.Command("sudo", "gpasswd", "-d", user["user"], user["group"])
		err := cmd.Run()
		if err != nil {
			fmt.Printf("Error removing %s from %s\n", user["user"], user["group"])
		} else {
			fmt.Printf("Removed %s from %s\n", user["user"], user["group"])
		}
	}
}

func contains(slice []string, item string) bool {
	for _, s := range slice {
		if s == item {
			return true
		}
	}
	return false
}

func anyGroupMatches(slice []map[string]string, group string) bool {
	for _, s := range slice {
		if s["group"] == group {
			return true
		}
	}
	return false
}
