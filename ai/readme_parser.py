import json
import os
import jsonschema
from jsonschema import validate
import openai
from bs4 import BeautifulSoup

api_key = os.getenv("OPENAI_API_KEY")
if not api_key:
    raise EnvironmentError("OPENAI_API_KEY not set in environment. Please set it as an environment variable.")

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
    file_path = os.path.expanduser(file_path)
    print(f"Reading and parsing HTML README file from {file_path}...")
    try:
        with open(file_path, "r", encoding="utf-8") as file:
            content = file.read()
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
    readme_content = read_html_readme_file(input_file_path)

    prompt = (
        "You are an expert at structured data extraction. You will be given unstructured text from a Cyber Patriot "
        "ReadMe and should convert it into the given structure. This data must include the title (name of the image), "
        "all users (all authorized users), new users (any additional users the document asks to create), critical "
        "services, and a markdown summary. For each user, you **must** mention the groups they're apart of, the "
        "account name, and permissions they should have (admin or not). The data should be in JSON format. You may "
        "only output JSON and nothing else! Your response should be in the format of the JSON Schema.\n\n"
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

        print("Raw JSON content (after stripping Markdown):", json_content)

        parsed_json = json.loads(json_content)
        
        if not isinstance(parsed_json, dict):
            raise TypeError("Parsed JSON is not a dictionary. Check the response format.")

        print("Formatted JSON parsed successfully.")

        parsed_json['markdown_summary'] = parsed_json.pop('summary', "")

        all_users = []
        for user in parsed_json.pop('users', []):
            user_data = {
                "name": user["account_name"],
                "account_type": "admin" if user["permissions"] == "admin" else "standard",
                "groups": user["groups"]
            }
            all_users.append(user_data)

        parsed_json["all_users"] = all_users

        new_users = []
        for new_user in parsed_json.get("new_users", []):
            new_user["name"] = new_user.pop("account_name")
            new_user["account_type"] = "admin" if new_user["permissions"] == "admin" else "standard"
            new_user["password"] = "default_password" 
            new_user.pop("permissions", None)  
            new_users.append(new_user)

        parsed_json["new_users"] = new_users 

    except json.JSONDecodeError as e:
        print(f"Error parsing the JSON response: {e}")
        return
    except TypeError as e:
        print(f"Type error during JSON handling: {e}")
        return
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        return

    try:
        validate_json_output(parsed_json)
    except Exception as e:
        print(f"JSON validation failed: {e}")
        return

    if not os.path.exists(output_folder_path):
        print(f"Creating output directory at {output_folder_path}...")
        os.makedirs(output_folder_path)
        print("Output directory created.")

    output_file_path = os.path.join(output_folder_path, "ReadMe.json")

    try:
        with open(output_file_path, "w", encoding="utf-8") as file:
            file.write(json.dumps(parsed_json, indent=4))
        print(f"JSON output has been written to {output_file_path}")
    except Exception as e:
        print(f"An error occurred while writing the JSON to the file: {e}")

input_readme_path = "~/Desktop/linshield/.ReadMe-configs/ReadMe.html"  # Path to your input HTML README file
output_directory_path = "~/Desktop/linshield/.ReadMe-configs/"          # Path to your output directory

process_readme_to_json(input_readme_path, output_directory_path)
