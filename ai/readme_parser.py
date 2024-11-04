import json
import os
import jsonschema
from jsonschema import validate
import openai

# Check if the API key is loaded from the environment variable
api_key = os.getenv("OPENAI_API_KEY")
if not api_key:
    raise EnvironmentError("OPENAI_API_KEY not set in environment. Please set it as an environment variable.")

# Initialize the OpenAI client
openai.api_key = api_key  # Use the API key securely fetched from the environment

# Define the JSON Schema for validation
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
                "additionalProperties": false
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
                "additionalProperties": false
            }
        },
        "critical_services": {
            "type": "array",
            "items": {"type": "string"}
        },
        "markdown_summary": {"type": "string"}
    },
    "required": ["title", "all_users", "new_users", "critical_services", "markdown_summary"],
    "additionalProperties": false
}

# Function to read the README file content
def read_readme_file(file_path):
    with open(file_path, "r") as file:
        return file.read()

# Function to validate JSON output against the schema
def validate_json_output(json_data):
    try:
        validate(instance=json_data, schema=schema)
        print("JSON output is valid.")
    except jsonschema.exceptions.ValidationError as err:
        print(f"JSON output is invalid: {err.message}")

# Main function to process the README and save the JSON output
def process_readme_to_json(input_file_path, output_folder_path):
    # Read the README content from the specified file
    readme_content = read_readme_file(input_file_path)

    # Define the prompt with instructions
    prompt = (
        "You are an expert at structured data extraction. You will be given unstructured text from a Cyber Patriot "
        "ReadMe and should convert it into the given structure. This data must include the title (name of the image), "
        "all users (all authorized users), new users (any additional users the document asks to create), critical "
        "services, and a markdown summary. For each user, you **must** mention the groups they're apart of, the "
        "account name, and permissions they should have (admin or not). The data should be in JSON format. You may "
        "only output JSON and nothing else! Your response should be in the format of the JSON Schema.\n\n"
        f"{readme_content}"
    )

    # Send the prompt and README content to the OpenAI API for structured data extraction using GPT-4
    response = openai.ChatCompletion.create(
        model="gpt-4",  # Specify GPT-4 model
        messages=[
            {"role": "user", "content": prompt}
        ]
    )

    # Parse the API response and format the JSON
    formatted_json = json.loads(response['choices'][0]['message']['content'])

    # Validate the formatted JSON against the schema
    validate_json_output(formatted_json)

    # Ensure the output directory exists
    if not os.path.exists(output_folder_path):
        os.makedirs(output_folder_path)

    # Construct the full path for the output file
    output_file_path = os.path.join(output_folder_path, "ReadMe.json")

    # Write the formatted JSON to the file
    with open(output_file_path, "w") as file:
        file.write(json.dumps(formatted_json, indent=4))

    print(f"JSON output has been written to {output_file_path}")

# Example usage: Adjust the paths as necessary
input_readme_path = "path/to/your/README.txt"  # Path to your input README file
output_directory_path = "../.ReadMe-configs"   

# Run the function
process_readme_to_json(input_readme_path, output_directory_path)