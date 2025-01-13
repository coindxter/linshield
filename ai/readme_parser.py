import json
import os
import jsonschema
from jsonschema import validate
import openai
from bs4 import BeautifulSoup
from pathlib import Path

api_key = os.getenv("OPENAI_API_KEY")
if not api_key:
    raise EnvironmentError("OPENAI_API_KEY not set in environment. Please set it as an environment variable. View Instructions are in ai/ReadMe.md")

openai.api_key = api_key

schema = {
    "$schema": "http://json-schema.org/draft-07/schema#",
    "title": "structured_readme",
    "type": "object",
    "properties": {
        "title": {"type": "string"},
        "all_users": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "name": {"type": "string"},
                    "account_type": {
                        "type": "string",
                        "enum": ["admin", "standard"]
                    },
                    "groups": {
                        "type": "array",
                        "items": {"type": "string"}
                    }
                },
                "required": ["name", "groups", "account_type"],
                "additionalProperties": False
            }
        },
        "new_users": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "name": {"type": "string"},
                    "account_type": {
                        "type": "string",
                        "enum": ["admin", "standard"]
                    },
                    "groups": {
                        "type": "array",
                        "items": {"type": "string"}
                    },
                    "password": {"type": "string"}
                },
                "required": ["name", "groups", "account_type", "password"],
                "additionalProperties": False
            }
        },
        "critical_services": {
            "type": "array",
            "items": {"type": "string"}
        },
        "markdown_summary": {"type": "string"}
    },
    "required": ["title", "all_users", "new_users", "critical_services", "markdown_summary"],
    "additionalProperties": False
}

def read_html_readme_file(file_path):
    print(f"Reading and parsing HTML README file from {file_path}...")
    try:
        content = file_path.read_text(encoding="utf-8")
    except FileNotFoundError:
        print(f"File not found: {file_path}")
        raise

    soup = BeautifulSoup(content, "html.parser")
    plain_text = soup.get_text()
    print("HTML README content parsed successfully.")
    return plain_text

def validate_json_output(json_data):
    print("Starting JSON validation...")
    try:
        validate(instance=json_data, schema=schema)
        print("JSON output is valid.")
    except jsonschema.exceptions.ValidationError as err:
        print(f"JSON output is invalid: {err.message}")
        raise

def process_readme_to_json(input_file_path, output_folder_path):
    if not input_file_path.exists():
        raise FileNotFoundError(f"Input file not found: {input_file_path}")
    
    output_folder_path.mkdir(parents=True, exist_ok=True)
    output_file_path = output_folder_path / "ReadMe.json"

    readme_content = read_html_readme_file(input_file_path)

    prompt = (
        "You are an expert at structured data extraction. You will be given unstructured text from a Cyber Patriot "
        "ReadMe and should convert it into the given structure. This data **must** include the title (name of the image), "
        "all users (all authorized users), new users (any additional users the document asks to create), critical "
        "services (apache2, sshd, etc), and a markdown summary. For each user, you **must** mention the groups they're a part of, the "
        "account name, and permissions they should have (admin or not). The data should be in JSON format. You may "
        "only output JSON and nothing else! Your response should be in the format of the JSON Schema."
        "Some common errors that you need to look out for since I will be checking this with the JSON Schema:"
        "1. Error parsing the JSON response: string indices must be integers, not 'str'\n\n"
        f"{readme_content}"
    )

    print("Sending prompt to OpenAI API...")
    try:
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=[{"role": "user", "content": prompt}]
        )
        print("Response received from OpenAI API.")
    except Exception as e:
        print(f"An error occurred while contacting the OpenAI API: {e}")
        return

    try:
        raw_content = response['choices'][0]['message']['content']
        json_content = raw_content.strip("```json\n").strip("```")
        parsed_json = json.loads(json_content)

        if not isinstance(parsed_json, dict):
            raise TypeError("Parsed JSON is not a dictionary. Check the response format.")

        print("Formatted JSON parsed successfully.")

        parsed_json['markdown_summary'] = parsed_json.pop('summary', "")
        
        all_users = [
            {
                "name": user["account_name"],
                "account_type": "admin" if user["permissions"] == "admin" else "standard",
                "groups": user["groups"]
            }
            for user in parsed_json.pop('users', [])
        ]
        parsed_json["all_users"] = all_users

        new_users = [
            {
                "name": new_user.pop("account_name"),
                "account_type": "admin" if new_user.pop("permissions", "") == "admin" else "standard",
                "groups": new_user["groups"],
                "password": "default_password"
            }
            for new_user in parsed_json.get("new_users", [])
        ]
        parsed_json["new_users"] = new_users


    # force convert into a integer
    # common error: Error parsing the JSON response: string indices must be integers, not 'str'
    # this breaks it and makes it so that it doesnt work all the time, only sometimes
    except (json.JSONDecodeError, TypeError) as e:      
        print(f"Error parsing the JSON response: {e}")
        return

    try:
        validate_json_output(parsed_json)
    except Exception as e:
        print(f"JSON validation failed: {e}")
        return

    try:
        with output_file_path.open("w", encoding="utf-8") as file:
            file.write(json.dumps(parsed_json, indent=4))
        print(f"JSON output has been written to {output_file_path}")
    except Exception as e:
        print(f"An error occurred while writing the JSON to the file: {e}")

input_readme_path = Path("~/Desktop/linshield/.ReadMe-configs/ReadMe.html").expanduser()
output_directory_path = Path("~/Desktop/linshield/.ReadMe-configs/").expanduser()

process_readme_to_json(input_readme_path, output_directory_path)
