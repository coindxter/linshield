package main

import (
	"encoding/json"
	"fmt"
	"log"
	"math/rand"
	"os"
	"os/exec"
	"strings"
	"time"
)

type User struct {
	Name        string `json:"name"`
	AccountType string `json:"account_type"`
	Password    string `json:"password,omitempty"`
}

type ConfigData struct {
	AllUsers []User `json:"all_users"`
	NewUsers []User `json:"new_users"`
}

func randomString(n int) string {
	const letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	b := make([]byte, n)
	for i := range b {
		b[i] = letters[rand.Intn(len(letters))]
	}
	return string(b)
}

func userExists(name string, users []string) bool {
	for _, user := range users {
		if user == name {
			return true
		}
	}
	return false
}

func printSummary(unAuthorizedUsers []string, missingUsers []User, unAuthorizedAdmins []string, missingAdmins []User, newUsers []User, users []User, admins []User, currentAdmin string) {
	if len(unAuthorizedUsers) > 0 {
		fmt.Println("Removed these users:")
		for _, user := range unAuthorizedUsers {
			fmt.Printf("  - %s\n", user)
		}
	}

	if len(missingUsers) > 0 {
		fmt.Println("Added these users:")
		for _, user := range missingUsers {
			fmt.Printf("  - %s\n", user.Name)
			fmt.Printf("  - %s\n", user.Password)
		}
	}

	if len(unAuthorizedAdmins) > 0 {
		fmt.Println("Removed these admins:")
		for _, user := range unAuthorizedAdmins {
			fmt.Printf("  - %s\n", user)
		}
	}

	if len(missingAdmins) > 0 {
		fmt.Println("Added these admins:")
		for _, user := range missingAdmins {
			fmt.Printf("  - %s\n", user.Name)
			fmt.Printf("  - %s\n", user.Password)
		}
	}

	if len(newUsers) > 0 {
		fmt.Println("Added these new users:")
		for _, user := range newUsers {
			fmt.Printf("  - %s\n", user.Name)
			fmt.Printf("  - %s\n", user.Password)
		}
	}

	for _, user := range users {
		fmt.Printf("Updated password for %s\n", user.Name)
		fmt.Printf("  - %s\n", user.Password)
	}

	for _, user := range admins {
		fmt.Printf("Updated password for %s\n", user.Name)
		if user.Name == currentAdmin {
			fmt.Println("  - Original password")
			continue
		}
		fmt.Printf("  - %s\n", user.Password)
	}
}

func main() {
	if os.Geteuid() != 0 {
		fmt.Println("You are not root")
		os.Exit(1)
	}

	if len(os.Args) < 1 {
		fmt.Println("This isn't the main program")
		os.Exit(0)
	}

	file, err := os.Open(".marmottes-configs/ReadMe.json")
	if err != nil {
		log.Fatalf("Error opening file: %v", err)
	}
	defer file.Close()

	var data ConfigData
	if err := json.NewDecoder(file).Decode(&data); err != nil {
		log.Fatalf("Error decoding JSON: %v", err)
	}

	var admins, users []User
	for _, user := range data.AllUsers {
		if user.AccountType == "admin" {
			admins = append(admins, user)
		} else {
			users = append(users, user)
		}
	}
	newUsers := data.NewUsers

	currentAdminCmd := exec.Command("logname")
	currentAdminOut, err := currentAdminCmd.Output()
	if err != nil {
		log.Fatalf("Error getting current admin: %v", err)
	}
	currentAdmin := strings.TrimSpace(string(currentAdminOut))

	minUUID := 1000
	maxUUID := 60000

	awkCmd := fmt.Sprintf(`awk -F':' -v min=%d -v max=%d '{ if ($3 >= min && $3 <= max) print $1}' /etc/passwd`, minUUID, maxUUID)
	currentUsersCmd := exec.Command("bash", "-c", awkCmd)
	currentUsersOut, err := currentUsersCmd.Output()
	if err != nil {
		log.Fatalf("Error getting current users: %v", err)
	}
	currentUsers := strings.Split(strings.TrimSpace(string(currentUsersOut)), "\n")

	sudoAdmCmd := "getent group sudo adm | cut -d: -f4 | tr ',' '\\n' | sort -u"
	currentAdminsCmd := exec.Command("bash", "-c", sudoAdmCmd)
	currentAdminsOut, err := currentAdminsCmd.Output()
	if err != nil {
		log.Fatalf("Error getting current admins: %v", err)
	}
	currentAdmins := strings.Split(strings.TrimSpace(string(currentAdminsOut)), "\n")

	var unAuthorizedUsers, unAuthorizedAdmins []string
	var missingUsers, missingAdmins []User

	for _, user := range currentUsers {
		found := false
		for _, u := range users {
			if user == u.Name {
				found = true
				break
			}
		}
		for _, u := range admins {
			if user == u.Name {
				found = true
				break
			}
		}
		for _, u := range newUsers {
			if user == u.Name {
				found = true
				break
			}
		}
		if !found {
			unAuthorizedUsers = append(unAuthorizedUsers, user)
		}
	}

	for _, user := range users {
		found := false
		for _, u := range currentUsers {
			if user.Name == u {
				found = true
				break
			}
		}
		if !found {
			missingUsers = append(missingUsers, user)
		}
	}

	for _, user := range currentAdmins {
		found := false
		for _, u := range admins {
			if user == u.Name {
				found = true
				break
			}
		}
		if !found {
			unAuthorizedAdmins = append(unAuthorizedAdmins, user)
		}
	}

	for _, user := range admins {
		found := false
		for _, u := range currentAdmins {
			if user.Name == u {
				found = true
				break
			}
		}
		if !found {
			missingAdmins = append(missingAdmins, user)
		}
	}

	if len(unAuthorizedUsers) > 0 {
		fmt.Println("Unauthorized users:")
		for _, user := range unAuthorizedUsers {
			fmt.Printf("  - %s\n", user)
		}
	}

	if len(missingUsers) > 0 {
		fmt.Println("Missing users:")
		for _, user := range missingUsers {
			fmt.Printf("  - %s\n", user.Name)
		}
	}

	if len(unAuthorizedAdmins) > 0 {
		fmt.Println("Unauthorized admins:")
		for _, user := range unAuthorizedAdmins {
			fmt.Printf("  - %s\n", user)
		}
	}

	if len(missingAdmins) > 0 {
		fmt.Println("Missing admins:")
		for _, user := range missingAdmins {
			fmt.Printf("  - %s\n", user.Name)
		}
	}

	var fix string
	fmt.Print("Would you like to fix these issues? (yes/no): ")
	fmt.Scanln(&fix)

	if fix == "yes" || fix == "y" {
		rand.Seed(time.Now().UnixNano())

		for i := range missingUsers {
			missingUsers[i].Password = randomString(16)
			exec.Command("bash", "-c", fmt.Sprintf("useradd -m -s /bin/bash -U %s", missingUsers[i].Name)).Run()
			exec.Command("bash", "-c", fmt.Sprintf("echo \"%s:%s\" | chpasswd", missingUsers[i].Name, missingUsers[i].Password)).Run()
			exec.Command("bash", "-c", fmt.Sprintf("chage -d 0 %s", missingUsers[i].Name)).Run()
		}

		for i := range missingAdmins {
			if missingAdmins[i].Name == currentAdmin {
				continue
			}
			missingAdmins[i].Password = randomString(16)
			if !userExists(missingAdmins[i].Name, currentUsers) {
				exec.Command("bash", "-c", fmt.Sprintf("useradd -m -s /bin/bash -U %s", missingAdmins[i].Name)).Run()
				exec.Command("bash", "-c", fmt.Sprintf("echo \"%s:%s\" | chpasswd", missingAdmins[i].Name, missingAdmins[i].Password)).Run()
				exec.Command("bash", "-c", fmt.Sprintf("chage -d 0 %s", missingAdmins[i].Name)).Run()
			}
			exec.Command("bash", "-c", fmt.Sprintf("usermod -aG sudo %s", missingAdmins[i].Name)).Run()
			exec.Command("bash", "-c", fmt.Sprintf("usermod -aG adm %s", missingAdmins[i].Name)).Run()
		}

		for _, user := range unAuthorizedUsers {
			exec.Command("bash", "-c", fmt.Sprintf("userdel -r %s", user)).Run()
		}

		for _, user := range unAuthorizedAdmins {
			if user == currentAdmin {
				continue
			}
			exec.Command("bash", "-c", fmt.Sprintf("deluser %s sudo", user)).Run()
			exec.Command("bash", "-c", fmt.Sprintf("deluser %s adm", user)).Run()
		}

		for i := range newUsers {
			exec.Command("bash", "-c", fmt.Sprintf("useradd -m -s /bin/bash -U %s", newUsers[i].Name)).Run()
			exec.Command("bash", "-c", fmt.Sprintf("echo \"%s:%s\" | chpasswd", newUsers[i].Name, newUsers[i].Password)).Run()
			exec.Command("bash", "-c", fmt.Sprintf("chage -d 0 %s", newUsers[i].Name)).Run()
			if newUsers[i].AccountType == "admin" {
				exec.Command("bash", "-c", fmt.Sprintf("usermod -aG sudo %s", newUsers[i].Name)).Run()
				exec.Command("bash", "-c", fmt.Sprintf("usermod -aG adm %s", newUsers[i].Name)).Run()
			}
		}

		for i := range users {
			users[i].Password = randomString(16)
			exec.Command("bash", "-c", fmt.Sprintf("echo \"%s:%s\" | chpasswd", users[i].Name, users[i].Password)).Run()
		}

		for i := range admins {
			if admins[i].Name == currentAdmin {
				continue
			}
			admins[i].Password = randomString(16)
			exec.Command("bash", "-c", fmt.Sprintf("echo \"%s:%s\" | chpasswd", admins[i].Name, admins[i].Password)).Run()
		}

		printSummary(unAuthorizedUsers, missingUsers, unAuthorizedAdmins, missingAdmins, newUsers, users, admins, currentAdmin)
	}
}
