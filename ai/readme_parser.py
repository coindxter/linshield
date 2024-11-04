import json
import os
import jsonschema
from jsonschema import validate
import openai

#api_key = os.getenv("OPENAI_API_KEY")
#if not api_key:
#    raise EnvironmentError("OPENAI_API_KEY not set in environment. Please set it as an environment variable.")
api_key = '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'

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
    file_path = os.path.expanduser(file_path) 
    with open(file_path, "r") as file:
        return file.read()

def validate_json_output(json_data):
    try:
        validate(instance=json_data, schema=schema)
        print("JSON output is valid.")
    except jsonschema.exceptions.ValidationError as err:
        print(f"JSON output is invalid: {err.message}")

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

    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo-0125",  # Specify GPT-4 model
        messages=[
            {"role": "user", "content": prompt}
        ]
    )

    formatted_json = json.loads(response['choices'][0]['message']['content'])
    validate_json_output(formatted_json)
    if not os.path.exists(output_folder_path):
        os.makedirs(output_folder_path)
    output_file_path = os.path.join(output_folder_path, "ReadMe.json")
    with open(output_file_path, "w") as file:
        file.write(json.dumps(formatted_json, indent=4))
    print(f"JSON output has been written to {output_file_path}")

input_readme_path = os.path.expanduser("~/Desktop/linshield/.ReadMe-configs/ReadMe.html")
output_directory_path = os.path.expanduser("../.ReadMe-configs/")
process_readme_to_json(input_readme_path, output_directory_path)