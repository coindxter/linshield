package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"os/exec"
	"regexp"
	"runtime"
	"strings"
)

// checkFileExists checks if a file exists at the given path.
func checkFileExists(path string) bool {
	_, err := os.Stat(path)
	return !os.IsNotExist(err)
}

// openNano opens the nano editor for the user to input raw HTML.
func openNano(filename string) error {
	var cmd *exec.Cmd
	if runtime.GOOS == "windows" {
		cmd = exec.Command("notepad", filename)
	} else {
		cmd = exec.Command("nano", filename)
	}
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}

// removeHTMLTags removes the <head>, <script>, <style> tags and all other HTML tags from the content.
func removeHTMLTags(content string) string {
	// Remove <head>, <script>, <style> tags and their content.
	reHead := regexp.MustCompile(`(?s)<head.*?>.*?</head>`)
	reScript := regexp.MustCompile(`(?s)<script.*?>.*?</script>`)
	reStyle := regexp.MustCompile(`(?s)<style.*?>.*?</style>`)
	content = reHead.ReplaceAllString(content, "")
	content = reScript.ReplaceAllString(content, "")
	content = reStyle.ReplaceAllString(content, "")

	// Remove all other HTML tags.
	reTags := regexp.MustCompile(`(?s)<.*?>`)
	content = reTags.ReplaceAllString(content, "")

	// Replace multiple spaces or newlines with a single space.
	content = strings.TrimSpace(content)
	reSpaces := regexp.MustCompile(`\s+`)
	content = reSpaces.ReplaceAllString(content, " ")

	return content
}

func extractReadMEData(userContent string) (string, error) {
	// Define the API key and URL
	// ask for the API key
	// CHECK if windows or linux

	var apiKey string
	if runtime.GOOS == "windows" {
		currentUser := exec.Command("echo %USERNAME%")
		currentUserOut, _ := currentUser.Output()
		apiKeyPath := "C:\\Users\\" + strings.TrimSpace(string(currentUserOut)) + "\\mistral_api_key"
		if checkIfPathExists(apiKeyPath) {
			apiKeyBytes, _ := ioutil.ReadFile(apiKeyPath)
			apiKey = strings.TrimSpace(string(apiKeyBytes))
		} else {
			fmt.Println("Enter your Mistral API key:")
			fmt.Scanln(&apiKey)
			err := writeToFile(apiKeyPath, apiKey)
			if err != nil {
				fmt.Println("Error writing API key to file:", err)
				os.Exit(1)
			}
		}
	} else if runtime.GOOS == "linux" {
		currentUser := exec.Command("logname")
		currentUserOut, _ := currentUser.Output()
		apiKeyPath := "/home/" + strings.TrimSpace(string(currentUserOut)) + "/.mistral_api_key"
		if checkIfPathExists(apiKeyPath) {
			apiKeyBytes, _ := ioutil.ReadFile(apiKeyPath)
			apiKey = strings.TrimSpace(string(apiKeyBytes))
		} else {
			fmt.Println("Enter your Mistral API key:")
			fmt.Scanln(&apiKey)
			err := writeToFile(apiKeyPath, apiKey)
			if err != nil {
				fmt.Println("Error writing API key to file:", err)
				os.Exit(1)
			}
		}
	}

	url := "https://api.mistral.ai/v1/chat/completions"

	// Create the request body including the structured README JSON schema
	requestBody := map[string]interface{}{
		"model": "mistral-large-latest",
		"messages": []map[string]string{
			{
				"role": "user",
				"content": `#Goal:
You are an expert at structured data extraction. You will be given unstructured text from a Cyber Patriot ReadMe and should convert it into the given structure. This data must include the title (name of the image), all users (all authorized users), new users (any additional users the document asks to create), critical services, and a markdown summary. For each user, you **must** mention the groups they're appart of, the account name, and permissions they sould have (admin or not). Note, don't include "users" or "administrators" in the groups list. The data should be in JSON format. You may only output JSON and nothing else! Your response should be in the format of the JSON Schema

#JSON Schema:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "structured_readme",
  "type": "object",
  "properties": {
	"title": {
	  "type": "string"
	},
	"all_users": {
	  "type": "array",
	  "items": {
		"type": "object",
		"properties": {
		  "name": {
			"type": "string"
		  },
		  "account_type": {
			"type": "string",
			"enum": ["admin", "standard"]
		  },
		  "groups": {
			"type": "array",
			"items": {
			  "type": "string"
			}
		  }
		},
		"required": ["name", "groups", "account_type"],
		"additionalProperties": false
	  }
	},
	"new_users": {
	  "type": "array",
	  "items": {
		"type": "object",
		"properties": {
		  "name": {
			"type": "string"
		  },
		  "account_type": {
			"type": "string",
			"enum": ["admin", "standard"]
		  },
		  "groups": {
			"type": "array",
			"items": {
			  "type": "string"
			}
		  },
		  "password": {
			"type": "string"
		  }
		},
		"required": ["name", "groups", "account_type", "password"],
		"additionalProperties": false
	  }
	},
	"critical_services": {
	  "type": "array",
	  "items": {
		"type": "string"
	  }
	},
	"markdown_summary": {
	  "type": "string"
	}
  },
  "required": ["title", "all_users", "new_users", "critical_services", "markdown_summary"],
  "additionalProperties": false
}

#Readme:` + "\n```" + userContent + "\n```",
			},
		},
	}

	// Convert the request body to JSON
	jsonData, err := json.Marshal(requestBody)
	if err != nil {
		return "", fmt.Errorf("error marshalling JSON: %v", err)
	}

	// Create the HTTP request
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		return "", fmt.Errorf("error creating HTTP request: %v", err)
	}

	// Add the necessary headers
	req.Header.Set("Authorization", "Bearer "+apiKey)
	req.Header.Set("Content-Type", "application/json")

	// Send the HTTP request
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return "", fmt.Errorf("error sending request: %v", err)
	}
	defer resp.Body.Close()

	// Read the response body
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return "", fmt.Errorf("error reading response body: %v", err)
	}

	// Check for HTTP errors
	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("request failed with status code: %d, response: %s", resp.StatusCode, string(body))
	}

	// get the message content from the response body
	var response map[string]interface{}
	if err := json.Unmarshal(body, &response); err != nil {
		return "", fmt.Errorf("error unmarshalling JSON: %v", err)
	}

	// Get the message content from the response
	choices := response["choices"].([]interface{})
	if len(choices) == 0 {
		return "", fmt.Errorf("no choices in response")
	}
	message := choices[0].(map[string]interface{})["message"].(map[string]interface{})["content"].(string)
	message = strings.Replace(message, "```json", "", 1)
	message = strings.Replace(message, "```", "", 1)
	// Return the message content
	return message, nil
}

func writeToFile(filename, content string) error {
	// Create or open the file for writing
	file, err := os.Create(filename)
	if err != nil {
		return fmt.Errorf("failed to create or open file: %w", err)
	}
	defer file.Close()

	// Write the content to the file
	_, err = file.WriteString(content)
	if err != nil {
		return fmt.Errorf("failed to write to file: %w", err)
	}

	fmt.Println("File written successfully.")
	return nil
}

func checkIfPathExists(path string) bool {
	_, err := os.Stat(path)
	return !os.IsNotExist(err)
}

func contains(s []string, e string) bool {
	for _, a := range s {
		if strings.Contains(strings.ToLower(e), strings.ToLower(a)) {
			return true
		}
	}
	return false
}

func main() {
	if !checkIfPathExists("./.marmottes-configs") {
		fmt.Println("Creating .marmottes-configs directory...")
		err := os.Mkdir("./.marmottes-configs", 0755)
		if err != nil {
			fmt.Println("Error creating directory:", err)
			return
		}
	}
	if checkFileExists("./.marmottes-configs/ReadMe.json") {
		fmt.Println("Config 'ReadMe.json' already exists.")
		fmt.Println("Press y to continue or n to exit")
		var input string
		fmt.Scanln(&input)
		if input == "n" {
			fmt.Println("Exiting...")
			return
		}
	}

	fmt.Println("Running ReadME Auto-locate...")
	var filename string
	if runtime.GOOS == "windows" {
		filename = "C:\\aeacus\\assets\\ReadMe.html"
	} else if runtime.GOOS == "linux" {
		filename = "/opt/aeacus/assets/ReadMe.html"
	}
	// Check if the file exists. If not, open nano for input.
	if !checkFileExists(filename) {
		// check if /opt/CyberPatriot exists wget $(grep '^Exec=' /opt/CyberPatriot/README.desktop | awk -F'"' '{print $2}') -O ReadME.html
		if runtime.GOOS == "linux" {
			if checkFileExists("/opt/CyberPatriot/README.desktop") {
				filename = "./ReadMe.html"
				fmt.Println("CyberPatriot does not exist locally...")
				fmt.Println("Press y to download CyberPatriot or n to exit")
				var input string
				fmt.Scanln(&input)
				if input == "n" {
					if !checkFileExists(filename) {
						fmt.Println("ReadMe does not exist locally...")
						fmt.Println("Press y to open an editor to paste in the ReadMe or n to exit")
						var input string
						fmt.Scanln(&input)
						if input == "n" {
							fmt.Println("Exiting...")
							return
						}
						if err := openNano(filename); err != nil {
							fmt.Println("Error opening nano:", err)
							return
						}
					}
				}
				cmd := exec.Command("sh", "-c", "wget $(grep '^Exec=' /opt/CyberPatriot/README.desktop | awk -F'\"' '{print $2}') -O ReadMe.html")
				if err := cmd.Run(); err != nil {
					fmt.Println("Error running command:", err)
					return
				}
			} else {
				filename = "./.marmottes-configs/ReadMe.html"
				if !checkFileExists(filename) {
					fmt.Println("ReadMe does not exist locally...")
					fmt.Println("Press y to open an editor to paste in the ReadME or n to exit")
					var input string
					fmt.Scanln(&input)
					if input == "n" {
						fmt.Println("Exiting...")
						return
					}
					if err := openNano(filename); err != nil {
						fmt.Println("Error opening nano:", err)
						return
					}
				}
			}
		} else {
			filename = "./.marmottes-configs/ReadMe.html"
			if !checkFileExists(filename) {
				fmt.Println("ReadMe does not exist locally...")
				fmt.Println("Press y to open an editor to paste in the ReadME or n to exit")
				var input string
				fmt.Scanln(&input)
				if input == "n" {
					fmt.Println("Exiting...")
					return
				}
				if err := openNano(filename); err != nil {
					fmt.Println("Error opening nano:", err)
					return
				}
			}
		}
	}

	// Read the file.
	fileContent, err := ioutil.ReadFile(filename)
	if err != nil {
		fmt.Println("Error reading file:", err)
		return
	}

	// Remove HTML tags.
	fmt.Println("Loaded ReadMe")
	processedContent := removeHTMLTags(string(fileContent))
	fmt.Println("Removed HTML Garbage")

	fmt.Println("Processing ReadMe with AI...")
	processedContentAI, err := extractReadMEData(processedContent)
	if err != nil {
		fmt.Println("Error calling API:", err)
		return
	}
	writeToFile("./.marmottes-configs/ReadMe.json", processedContentAI)
	fmt.Println("Config 'ReadMe.json' was written successfully.")
	// get the markdown summary from the processed content
	var readmeData map[string]interface{}
	if err := json.Unmarshal([]byte(processedContentAI), &readmeData); err != nil {
		fmt.Println("Error unmarshalling JSON:", err)
		return
	}
	markdownSummary := readmeData["markdown_summary"].(string)
	writeToFile("./.marmottes-configs/Summary.md", markdownSummary)
	fmt.Println("Config 'Summary.md' was written successfully.")

	fmt.Println("")
	fmt.Println("")

	knownCriticalServices := []string{"apache2", "nginx", "mysql", "postgresql", "ssh", "vsftpd", "samba", "bind9", "dovecot", "exim4", "postfix", "squid", "docker", "nginx", "rdp"}

	fmt.Println("Critical Services:")
	criticalServices := readmeData["critical_services"].([]interface{})
	for _, service := range criticalServices {
		if contains(knownCriticalServices, service.(string)) {
			fmt.Println("	-", service, "(Supported)")
		}
		if !contains(knownCriticalServices, service.(string)) {
			fmt.Println("	-", service)
		}
	}

	fmt.Println("")
	fmt.Println("Press the return key to continue...")
	var input string
	fmt.Scanln(&input)

	fmt.Println("")
	fmt.Println("Authorized Users:")
	allUsers := readmeData["all_users"].([]interface{})
	for _, user := range allUsers {
		fmt.Println("	-", user.(map[string]interface{})["name"])
		fmt.Println("		- Account Type:", user.(map[string]interface{})["account_type"])
		fmt.Println("		- Groups:")
		for _, group := range user.(map[string]interface{})["groups"].([]interface{}) {
			fmt.Println("			-", group)
		}
		fmt.Println("")
	}

	fmt.Println("")
	fmt.Println("Press the return key to continue...")
	var input2 string
	fmt.Scanln(&input2)

	fmt.Println("")
	fmt.Println("New Users:")
	newUsers := readmeData["new_users"].([]interface{})
	if len(newUsers) == 0 {
		fmt.Println("No new users to create.")
	}
	for _, user := range newUsers {
		fmt.Println("	-", user.(map[string]interface{})["name"])
		fmt.Println("		- Account Type:", user.(map[string]interface{})["account_type"])
		fmt.Println("		- Groups:")
		for _, group := range user.(map[string]interface{})["groups"].([]interface{}) {
			fmt.Println("			-", group)
		}
		fmt.Println("		- Password:", user.(map[string]interface{})["password"])
	}

	fmt.Println("")
	fmt.Println("Press the return key to continue...")
	var input3 string
	fmt.Scanln(&input3)

	fmt.Println("")

	fmt.Println("Setup Complete! Use scripts in the scripts directory to continue.")
}
