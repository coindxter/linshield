import os
import subprocess
import json
import requests

def getPackageLists(critical_services, current_packages):
    api_key = input("Enter your OpenAI API key: ")

    critical_services_str = "\n\t-".join(critical_services)
    current_packages_str = "\n\t-".join(current_packages)
    malicious_tools_str = "\n\t-".join([
        "nmap",
        "hydra",
        "john (John the Ripper)",
        "netcat",
        "aircrack-ng",
        "metasploit",
        "nikto",
        "sqlmap",
        "ettercap",
        "wireshark",
        "netstat",
        "tcpdump",
        "sshpass",
        "ufw",
        "ftp",
        "telnet",
        "rdesktop",
        "hashcat",
        "tcpflow",
        "4g8",
        "deluge"
    ])
    # Define the data payload
    data = {
        "model": "gpt-4o-mini",
        "messages": [
            {
                "role": "system",
                "content": "You are an expert at structured data extraction. You will be given unstructured text from a config file and should convert it into the given structure."
            },
            {
                "role": "user",
                "content": f"""Here is a list of the approved critical services (note I only want the package like 'apache2' not its dependencies):
{critical_services_str}

The system has the following packages installed:
{current_packages_str}

Please provide a list of the critical services apt packages and a list of the malicious, hacking tools, or unauthorized apt packages.

Examples of malicious, hacking tools, or unauthorized apt packages:
{malicious_tools_str}
"""
            }
        ],
        "response_format": {
            "type": "json_schema",
            "json_schema": {
                "name": "config",
                "schema": {
                    "type": "object",
                    "properties": {
                        "critical_services_apt_packages": {
                            "type": "array",
                            "items": { "type": "string" }
                        },
                        "malicous_or_unauthorized_apt_packages": {
                            "type": "array",
                            "items": { "type": "string" }
                        },
                    },
                    "required": ["critical_services_apt_packages", "malicous_or_unauthorized_apt_packages"],
                    "additionalProperties": False
                },
                "strict": True
            }
        }
    }

    # Make the request
    response = requests.post("https://api.openai.com/v1/chat/completions", headers={
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json"
    }, json=data)
    return response.json()

if os.geteuid() != 0:
    print("This script must be run as root")
    exit(1)

if __name__ != '__main__':
    print("This script must be run as main")
    exit(1)


with open('.marmottes-configs/ReadMe.json', 'r') as file:
    data = json.load(file)
critical_services = data['critical_services']

d = subprocess.run(["comm", "-23", "<(apt-mark showmanual | sort -u)", "<(gzip -dc /var/log/installer/initial-status.gz | sed -n 's/^Package: //p' | sort -u)"], capture_output=True, text=True)

response_json = getPackageLists(critical_services, d.stdout.splitlines())
pac = response_json['choices'][0]['message']['content']
if type(pac) is str:
    pac = json.loads(pac)

critical_packages = pac['critical_services_apt_packages']
unauthorized_packages = pac['malicous_or_unauthorized_apt_packages']

print("Hold the following critical packages:")
for package in critical_packages:
    print(f"\t- {package}")
print(" ")
print("Remove the following unauthorized packages:")
for package in unauthorized_packages:
    print(f"\t- {package}")

confirmation = input("Do you want to continue? (y/n): ")
if confirmation.lower() != 'y':
    exit(0)

for package in critical_packages:
    subprocess.run(["apt-mark", "hold", package])

for package in unauthorized_packages:
    subprocess.run(["apt", "remove", "--purge", package, "-y"])