import json
import os
import jsonschema
from jsonschema import validate
import openai

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

def read_readme_file(file_path):
    print(f"Reading README file from {file_path}...")
    with open(file_path, "r") as file:
        content = file.read()
    print("README content read successfully.")
    return content

def validate_json_output(json_data):
    print("Starting JSON validation...")
    try:
        validate(instance=json_data, schema=schema)
        print("JSON output is valid.")
    except jsonschema.exceptions.ValidationError as err:
        print(f"JSON output is invalid: {err.message}")
        raise

def process_readme_to_json(input_file_path, output_folder_path):
    readme_content = read_readme_file(input_file_path)

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
            model="gpt-4",  # Specify GPT-4 model
            messages=[
                {"role": "user", "content": prompt}
            ]
        )
        print("Response received from OpenAI API.")
    except Exception as e:
        print(f"An error occurred while contacting the OpenAI API: {e}")
        return

    print("Raw response from API:", response)

    try:
        formatted_json = json.loads(response['choices'][0]['message']['content'])
        print("Formatted JSON parsed successfully.")
    except Exception as e:
        print(f"Error parsing the JSON response: {e}")
        return

    try:
        validate_json_output(formatted_json)
    except Exception as e:
        print(f"JSON validation failed: {e}")
        return

    if not os.path.exists(output_folder_path):
        print(f"Creating output directory at {output_folder_path}...")
        os.makedirs(output_folder_path)
        print("Output directory created.")

    output_file_path = os.path.join(output_folder_path, "ReadMe.json")

    try:
        with open(output_file_path, "w") as file:
            file.write(json.dumps(formatted_json, indent=4))
        print(f"JSON output has been written to {output_file_path}")
    except Exception as e:
        print(f"An error occurred while writing the JSON to the file: {e}")

input_readme_path = "~/Desktop/linsheild/.ReadMe-configs/ReadMe.html"  # Path to your input README file
output_directory_path = "../.ReadMe-configs"   # Path to your output directory

process_readme_to_json(input_readme_path, output_directory_path)
