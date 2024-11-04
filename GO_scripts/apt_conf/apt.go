package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"os/exec"
	"runtime"
	"strings"
)

type RequestPayload struct {
	Model    string    `json:"model"`
	Messages []Message `json:"messages"`
}

type Message struct {
	Role    string `json:"role"`
	Content string `json:"content"`
}

type FormatSpec struct {
	Type       string         `json:"type"`
	JsonSchema JsonSchemaSpec `json:"json_schema"`
}

type JsonSchemaSpec struct {
	Name   string `json:"name"`
	Schema Schema `json:"schema"`
	Strict bool   `json:"strict"`
}

type Schema struct {
	Type                 string              `json:"type"`
	Properties           map[string]Property `json:"properties"`
	Required             []string            `json:"required"`
	AdditionalProperties bool                `json:"additionalProperties"`
}

type Property struct {
	Type  string `json:"type"`
	Items *Item  `json:"items,omitempty"`
}

type Item struct {
	Type string `json:"type"`
}

func getPackageLists(criticalServices, currentPackages []string, apiKey string) (map[string]interface{}, error) {
	criticalServicesStr := strings.Join(criticalServices, "\n\t-")
	currentPackagesStr := strings.Join(currentPackages, "\n\t-")
	maliciousTools := []string{
		"ace", "aircrack-ng", "aisleriot", "amap", "android-sdk", "apache-users", "apktool", "apt2", "arachni", "armitage",
		"arp-scan", "asleap", "backdoor-factory", "bbqsql", "bed", "beef", "besside-ng", "bettercap", "ettercap-common", "binwalk",
		"blindepephant", "bluelog", "bluemaho", "bluepot", "blueranger", "bluesnarfer", "braa", "brutespray", "bulk-extractor", "bully",
		"burpsuite", "capstone", "casefile", "cewl", "chntpw", "cisco-auditing-tool", "cisco-global-exploiter", "cisco-ocs", "cisco-torch",
		"cmospwd", "commix", "copy-router-config", "cowpattay", "crackle", "creddump", "crowbar", "crunch", "cryptcat", "cuckoo",
		"cutycapt", "cymothoa", "davtest", "dbd", "dc3dd", "ddrescue", "deblace", "deluge-common", "deluge-gtk", "dex2jar",
		"dff", "dhcpig", "dirb", "dirbuster", "distorm3", "dns2tcp", "dnschef", "dnsenum", "dnsmap", "dnstracer",
		"dnswalk", "doona", "dotdotpwn", "dumpzilla", "eapmd5pass", "easside-ng", "edb-debugger", "enum4linux", "enumiax", "explooitdb",
		"extundelete", "eyewitness", "faraday", "fern-wifi-cracker", "fierce", "fiked", "fimap", "findmyhash", "firewalk", "five-or-more",
		"foremost", "four-in-a-row", "fragroute", "fragrouter", "freeradius-wpe", "funkload", "funkloader", "galleta", "gameconqueror",
		"ghost-phisher", "ghostphisher", "giskismet", "gnome-chess", "gnome-klotski", "gnome-mahjongg", "gnome-mines", "gnome-robots",
		"gnome-sudoku", "gnome-taquin", "gnome-tetravex", "gobuster", "golismero", "goofile", "gpp-decrypt", "gqrx", "grabber", "gr-scan",
		"guymager", "hampster-sidejack", "hashcat", "hash-identifier", "hexinject", "hexorbase", "hitori", "hostadp-wpe", "hping3",
		"httptunnel", "hurl", "hydra", "iagno", "iaxflood", "ident-user-enum", "inspy", "intersect", "intrace", "inundator",
		"inviteflood", "iphone-backup-analyzer", "ismtp", "isr-evilgrade", "ivstools", "jad", "javasnoop", "jboss-autopwn", "jd-gui", "john",
		"johnny", "joomscan", "jsql-injection", "kalibrate-rtl", "keimpx", "killerbee", "kismet", "lbd", "lightsoff", "linux-exploit-suggester",
		"lynis", "makeivs-ng", "maltego-teeth", "manaplus", "maskprocessor", "masscan", "mdk3", "metagoofil", "metasploit-framework", "mfcuk",
		"mfoc", "mfterm", "miranda", "mitmproxy", "msfpc", "multiforcer", "multimon-ng", "nbtscan", "ncrack", "nikto",
		"nishang", "nmap", "ntop", "oclgausscrack", "ohrwurm", "ollydbg", "openvas", "ophcrack", "oscanner", "osrframework",
		"p0f", "pack", "packetforge-ng", "padbuster", "paros", "parsero", "patator", "pdfid", "pdgmail", "peepdf",
		"phrasendrescher", "pixiewps", "plecost", "polenum", "powerfuzzer", "powersploit", "protos-sip", "proxystrike", "pwnat", "pyrit",
		"quadrapassel", "rainbow-crack", "rcracki-mt", "reaver", "rebind", "recon-ng", "redfang", "regripper", "remmina", "responder",
		"ridenum", "routersploit", "rsmangler", "rtlsdr-scanner", "rtpbreak", "rtpflood", "rtpinsertsound", "rtpmixsound", "sakis3g", "sbd",
		"sctpscan", "seclists", "set", "sfuzz", "shellnoob", "shellter", "sidguesser", "siparmyknife", "sipp", "sipvicious",
		"skipfish", "slowhttptest", "smali", "smbmap", "smtp-user-enum", "sniffjoke", "snmp-check", "sparta", "splsus", "spooftooph",
		"sqldict", "sqlmap", "sqlninja", "sqlsus", "sslsplit", "sslstrip", "sslyze", "statsprocessor", "sublist3r", "swell-foop",
		"t50", "tali", "temineter", "thc-hydra", "thc-ipv6", "thc-pptp-bruter", "thc-ssl-doc", "theharvester", "tkiptun-ng", "tlssled",
		"tnscmd10g", "toolkit", "transmission-cli", "transmission-common", "transmission-daemon", "transmission-gtk", "truecrach", "twofi",
		"u3-pwn", "ua-tester", "unicornscan", "uniscan", "unix-privesc-check", "valgrind", "vinagre", "voiphopper", "volatility", "w3af",
		"webscarab", "webshag", "webshells", "webslayer", "weevely", "wesside-ng", "wfuzz", "whatweb", "wifi-honey", "wifiphisher",
		"wifitap", "wifite", "winexe", "wireshark", "wordlists", "wpaclean", "wpscan", "xplico", "xspy", "xsser",
		"yara", "yersinia", "zaproxy",
	}
	maliciousToolsStr := strings.Join(maliciousTools, "\n\t-")

	data := RequestPayload{
		Model: "mistral-large-latest",
		Messages: []Message{
			{
				Role: "user",
				Content: fmt.Sprintf(
					`You are an expert in extracting structured data. I need your help in analyzing a configuration of packages on a system. Below is some unstructured information from a config file, and I want you to convert it into structured lists based on the criteria I provide.

Here are the details:

1. **Critical Services List**: The approved critical services (note: only include the package names like 'apache2', not their dependencies):
%v

2. **Currently Installed Packages**: The system has the following packages installed:
%v

3. **Examples of Malicious or Unauthorized Packages**: Below is a list of examples of packages considered to be hacking tools, games, network scanners, or unauthorized apt packages:
%v

Your task is to provide:
- A list of **critical service apt packages** that are installed on the system.
- A list of any **potentially malicious, hacking tools, games, network scanners, or unauthorized apt packages** based on both the examples provided and any other packages you may suspect (be overconfident!!! if you're unsure, include it anyway).

Please respond with two lists:
- A list of the names of the installed packages that match the **critical services**.
- A list of the names of the installed packages that match or resemble **malicious or unauthorized packages**.

Use this format:`+"```json\n"+`{
  "critical_services_apt_packages": ["..."],
  "malicous_or_unauthorized_apt_packages": ["..."]
}`+"```"+`
Be strict and ensure no additional properties are added outside of this schema.`,
					criticalServicesStr, currentPackagesStr, maliciousToolsStr),
			},
		},
	}

	jsonData, err := json.Marshal(data)
	if err != nil {
		return nil, err
	}

	req, err := http.NewRequest("POST", "https://api.mistral.ai/v1/chat/completions", bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, err
	}

	req.Header.Set("Authorization", "Bearer "+apiKey)
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	var result map[string]interface{}
	err = json.Unmarshal(body, &result)
	if err != nil {
		return nil, err
	}
	err = writeToFile(".marmottes-configs/request.json", string(jsonData))

	return result, nil
}

func confirmPackages(listName string, packages []interface{}) []string {
	fmt.Printf("Here is the list of %s:\n", listName)
	modifiedPackages := []string{}
	for i, pkg := range packages {
		fmt.Printf("[%d] %s\n", i, pkg)
	}

	for {
		fmt.Print("Would you like to remove any package from this list? (y/n): ")
		var response string
		fmt.Scan(&response)
		if strings.ToLower(response) != "y" {
			break
		}
		fmt.Print("Enter the number of the package to remove: ")
		var idx int
		fmt.Scan(&idx)
		if idx >= 0 && idx < len(packages) {
			packages = append(packages[:idx], packages[idx+1:]...)
			fmt.Println("Updated list:")
			for i, pkg := range packages {
				fmt.Printf("[%d] %s\n", i, pkg)
			}
		} else {
			fmt.Println("Invalid number, please try again.")
		}
	}

	for _, pkg := range packages {
		modifiedPackages = append(modifiedPackages, pkg.(string))
	}

	return modifiedPackages
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

func main() {
	if os.Geteuid() != 0 {
		fmt.Println("This script must be run as root")
		os.Exit(1)
	}

	// Load the JSON from the provided file
	file, err := os.Open(".marmottes-configs/ReadMe.json")
	if err != nil {
		fmt.Println("Error opening config file:", err)
		os.Exit(1)
	}
	defer file.Close()

	byteValue, _ := ioutil.ReadAll(file)
	var data map[string]interface{}
	err = json.Unmarshal(byteValue, &data)
	if err != nil {
		fmt.Println("Error parsing JSON:", err)
		os.Exit(1)
	}

	// Extract critical services
	criticalServices := data["critical_services"].([]interface{})
	criticalServicesStr := make([]string, len(criticalServices))
	for i, v := range criticalServices {
		criticalServicesStr[i] = v.(string)
	}

	// Extract installed packages using shell command
	cmd := exec.Command("bash", "-c", "apt list --installed")
	var out bytes.Buffer
	cmd.Stdout = &out
	err = cmd.Run()
	if err != nil {
		fmt.Println("Error executing command:", err)
		os.Exit(1)
	}

	packages := strings.Split(out.String(), "\n")

	// Get API key from user input
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

	// Call the Mistral API
	response, err := getPackageLists(criticalServicesStr, packages, apiKey)
	if err != nil {
		fmt.Println("Error calling Mistral API:", err)
		os.Exit(1)
	}

	choices := response["choices"].([]interface{})
	messageContent := choices[0].(map[string]interface{})["message"].(map[string]interface{})["content"]
	message := messageContent.(string)
	message = strings.Replace(message, "```json", "", 1)
	message = strings.Replace(message, "```", "", 1)
	var pac map[string]interface{}
	err = json.Unmarshal([]byte(message), &pac)
	if err != nil {
		fmt.Println("Error parsing response:", err)
		os.Exit(1)
	}

	criticalPackages := pac["critical_services_apt_packages"].([]interface{})
	unauthorizedPackages := pac["malicous_or_unauthorized_apt_packages"].([]interface{})

	// Allow user to review and modify the lists
	finalCriticalPackages := confirmPackages("critical packages", criticalPackages)
	finalUnauthorizedPackages := confirmPackages("unauthorized packages", unauthorizedPackages)

	// Proceed with package holding and removal
	var confirmation string
	fmt.Print("Do you want to continue with the changes? (y/n): ")
	fmt.Scan(&confirmation)
	if strings.ToLower(confirmation) != "y" {
		os.Exit(0)
	}

	for _, packageName := range finalCriticalPackages {
		fmt.Println("Holding package:", packageName)
		cmd := exec.Command("apt-mark", "hold", packageName)
		cmd.Run()
	}

	for _, packageName := range finalUnauthorizedPackages {
		fmt.Println("Removing package:", packageName)
		cmd := exec.Command("sudo", "apt", "remove", "--purge", packageName, "-y")
		cmd.Run()
	}
	cmd = exec.Command("sudo", "apt", "autoremove", "-y")
	cmd.Run()

	fmt.Println("Package management complete")
}
