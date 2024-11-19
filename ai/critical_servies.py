import os
import json
import subprocess
from jsonschema import validate
from pathlib import Path
import openai

api_key = os.getenv("OPENAI_API_KEY")
if not api_key:
    raise EnvironmentError("OPENAI_API_KEY not set in environment. Please set it as an environment variable.")

openai.api_key = api_key

schema = {
    "$schema": "http://json-schema.org/draft-07/schema#",
    "title": "package_validation",
    "type": "object",
    "properties": {
        "critical_services_apt_packages": {
            "type": "array",
            "items": {"type": "string"}
        },
        "malicous_or_unauthorized_apt_packages": {
            "type": "array",
            "items": {"type": "string"}
        }
    },
    "required": ["critical_services_apt_packages", "malicous_or_unauthorized_apt_packages"],
    "additionalProperties": False
}

def get_installed_packages():
    try:
        result = subprocess.run(
            ["bash", "-c", "comm -23 <(apt-mark showmanual | sort -u) <(gzip -dc /var/log/installer/initial-status.gz | sed -n 's/^Package: //p' | sort -u)"],
            capture_output=True,
            text=True,
            shell=True
        )
        result.check_returncode()
        return result.stdout.splitlines()
    except subprocess.CalledProcessError as e:
        print(f"Error retrieving installed packages: {e}")
        raise

def send_prompt_to_openai(critical_services, current_packages):
    malicious_tools = [
        "nmap", "hydra", "john", "netcat", "aircrack-ng", "metasploit", "nikto",
        "sqlmap", "ettercap", "wireshark", "netstat", "tcpdump", "sshpass",
        "ufw", "ftp", "telnet", "rdesktop", "hashcat", "tcpflow", "4g8", "deluge"
    ]

    prompt = (
        "You are an expert at structured data extraction. Given the list of critical services and installed packages, "
        "classify packages as critical or unauthorized based on the provided input.\n\n"
        f"Critical Services:\n{', '.join(critical_services)}\n\n"
        f"Installed Packages:\n{', '.join(current_packages)}\n\n"
        f"Examples of Malicious or Unauthorized Tools:\n{', '.join(malicious_tools)}\n\n"
        "Respond only with a JSON object conforming to this schema:\n"
        f"{json.dumps(schema, indent=4)}"
    )

    print("Sending prompt to OpenAI API...")
    try:
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=[{"role": "user", "content": prompt}]
        )
        return response['choices'][0]['message']['content']
    except Exception as e:
        print(f"An error occurred while contacting the OpenAI API: {e}")
        raise

def validate_and_process_json(json_data):
    print("Validating JSON response...")
    try:
        validate(instance=json_data, schema=schema)
        print("JSON response is valid.")
        return json_data
    except Exception as e:
        print(f"JSON validation failed: {e}")
        raise

def hold_and_remove_packages(critical_packages, unauthorized_packages):
    print("\nCritical Packages to Hold:")
    for package in critical_packages:
        print(f"\t- {package}")

    print("\nUnauthorized Packages to Remove:")
    for package in unauthorized_packages:
        print(f"\t- {package}")

    confirmation = input("\nDo you want to continue? (y/n): ").strip().lower()
    if confirmation != 'y':
        print("Operation cancelled.")
        return

    for package in critical_packages:
        try:
            subprocess.run(["apt-mark", "hold", package], check=True)
            print(f"Held: {package}")
        except subprocess.CalledProcessError as e:
            print(f"Error holding package '{package}': {e}")

    for package in unauthorized_packages:
        try:
            subprocess.run(["apt", "remove", "--purge", package, "-y"], check=True)
            print(f"Removed: {package}")
        except subprocess.CalledProcessError as e:
            print(f"Error removing package '{package}': {e}")

def main():
    config_path = Path("~/.marmottes-configs/ReadMe.json").expanduser()
    if not config_path.exists():
        raise FileNotFoundError(f"Configuration file not found: {config_path}")

    try:
        with config_path.open("r", encoding="utf-8") as file:
            config_data = json.load(file)
    except json.JSONDecodeError as e:
        print(f"Error reading JSON config: {e}")
        raise

    critical_services = config_data.get("critical_services", [])
    if not critical_services:
        raise ValueError("No critical services found in the configuration.")

    current_packages = get_installed_packages()
    response_content = send_prompt_to_openai(critical_services, current_packages)

    try:
        parsed_json = json.loads(response_content)
        validated_json = validate_and_process_json(parsed_json)
    except (json.JSONDecodeError, TypeError) as e:
        print(f"Error parsing API response: {e}")
        raise

    hold_and_remove_packages(
        validated_json["critical_services_apt_packages"],
        validated_json["malicous_or_unauthorized_apt_packages"]
    )

if __name__ == "__main__":
    if os.geteuid() != 0:
        print("This script must be run as root.")
        exit(1)
    main()