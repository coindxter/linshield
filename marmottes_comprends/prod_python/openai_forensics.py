import requests
import subprocess
import uuid
import os
import json
import urllib.parse
import re

def check_if_path_exists(path):
    return os.path.exists(path)

def write_to_file(path, content):
    try:
        with open(path, 'w') as f:
            f.write(content)
    except Exception as e:
        return e
    return None
# check if windows or linux
current_user = ""
api_key_path = ""
api_key = ""
if os.name == "nt":
    current_user = subprocess.check_output("echo %USERNAME%", shell=True).decode().strip()
    api_key_path = f"C:\\Users\\{current_user}\\openai_api_key"
    api_key = ""
else:
    current_user = subprocess.check_output("logname").decode().strip()
    api_key_path = f"/home/{current_user}/.openai_api_key"
    api_key = ""

if check_if_path_exists(api_key_path):
    with open(api_key_path, 'r') as f:
        api_key = f.read().strip()
else:
    api_key = input("Enter your OpenAI API key: ").strip()
    error = write_to_file(api_key_path, api_key)
    if error:
        print(f"Error writing API key to file: {error}")
        os._exit(1)

def search_internet(args):
    if type(args) is not dict:
        args = json.loads(args)
    print(">>> Searching the internet for:", args["query"])
    query = args["query"]
    query = urllib.parse.quote(query)
    search_url = f"https://searxng.myphone.education/search?q={query}&format=json"
    response = requests.get(search_url, headers={"User-Agent": "Mozilla/5.0"})
    if response.status_code != 200:
        return f"Error: {response.status_code}"
    search_results = response.json()
    search_results["results"] = search_results["results"][:5]
    for i, el in enumerate(search_results["results"]):
        if el.get("img_src"):
            del search_results["results"][i]["img_src"]
        if el.get("parsed_url"):
            del search_results["results"][i]["parsed_url"]
    return json.dumps(search_results)

def get_url_content(args):
    if type(args) is not dict:
        args = json.loads(args)
    print(">>> Reading webpage:", args["url"])
    url = args["url"]
    response = requests.get(url, headers={"User-Agent": "Mozilla/5.0"})
    if response.status_code != 200:
        return f"Error: {response.status_code}"
    response_text = response.text
    response_text = re.sub(r'<head.*?>.*?</head>', '', response_text, flags=re.DOTALL)
    response_text = re.sub(r'<script.*?>.*?</script>', '', response_text, flags=re.DOTALL)
    response_text = re.sub(r'<style.*?>.*?</style>', '', response_text, flags=re.DOTALL)
    response_text = re.sub(r'<.*?>', '', response_text)
    return response_text[:1300]

def run_cli_command(args, skip_opt=False):
    if type(args) is not dict:
        args = json.loads(args)
    command = args["command"]
    if not skip_opt:
        print(">>> Running command:", command)
    result = subprocess.run(command, shell=True, capture_output=True)
    if not skip_opt:
        print(">>> Command output:", result.stdout.decode() + result.stderr.decode())
    return result.stdout.decode() + result.stderr.decode()

def run_python_script(args):
    if type(args) is not dict:
        args = json.loads(args)
    if os.name == "nt":
        current_user = subprocess.check_output("echo %USERNAME%", shell=True).decode().strip()
        newPythonScript = f"C:\\Users\\{current_user}\\Desktop\\" + str(uuid.uuid4()) + ".py"
    else:
        newPythonScript = "./" + str(uuid.uuid4()) + ".py"
    with open(newPythonScript, "w") as file:
        file.write(args["script"])
    if args.get("dependencies"):
        for dependency in args["dependencies"]:
            installDep = input(f"Dependency {dependency} is not installed. Would you like to install it? (y/n): ")
            if installDep.lower() == "y":
                print(">>> Installing dependency:", dependency)
                if os.name == "nt":
                    python_loc = subprocess.check_output("where python", shell=True).decode().strip()
                    subprocess.run([python_loc, "-m", "pip", "install", dependency])
                else:
                    subprocess.run(["pip", "install", dependency])
            else:
                print(">>> Skipping dependency installation.")
                return "User refused to install dependency, refactor your code. Exiting."
    if os.name == "nt":
        python_loc = subprocess.check_output("where python", shell=True).decode().strip()
        result = subprocess.run([python_loc, newPythonScript], capture_output=True)
    else:
        result = subprocess.run(["python3", newPythonScript], capture_output=True)
    os.remove(newPythonScript)
    print(">>> Python script output:", result.stdout.decode() + result.stderr.decode())
    return result.stdout.decode() + result.stderr.decode()

url = "https://api.openai.com/v1/chat/completions"

messages = [{
    "role": "system",
    "content": f"""
You are an AI assistant helping to solve forensics questions on a CyberPatriot image. You have access to the following functions which you can use to interact with the system to find the answers to the questions.

Available Functions:

1. `run_cli_command`: Run a command in {"power" if os.name == 'nt' else "a bash "}shell and return the output to gather information. With this function, you must write the command to run.
2. `run_python`: Run a Python script and return the output. With this function, you must write the Python script to run **YOU MAY NOT PROVIDE A PATH OF A PYTHON FILE TO RUN**.
3. `search_internet`: Search the internet for information. With this function, you must provide a query to search the internet for.
4. `read_webpage`: Read the content of a webpage. With this function, you must provide the URL of the webpage to read.

You may not use search_internet or read_webpage to interact with internet tools, you must use python or the shell to interact with the system.

Use these functions to gather information as needed to answer the forensics questions.

If your attempt to solve the question fails, keep calling tools until you find your answer.

When you provide the final answer, ensure that you answer **every** question asked by the user.
"""
}]

def executor():
    global messages
    template = {
        "model": "gpt-4o",  # You can adjust to another model if needed
        "messages": messages,
        "tools": [
    {
        "type": "function",
        "function": 
            {
                "name": "run_cli_command",
                "description": "Run a command in the shell and return the output.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "command": {
                            "type": "string",
                            "description": "The command to run in the shell."
                        },
                    },
                    "required": ["command"]
                }
            },
    },
    {
        "type": "function",
        "function": 
            {
                "name": "run_python",
                "description": "Run a Python script and return the output.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "script": {
                            "type": "string",
                            "description": "The Python script to run."
                        },
                        "dependencies": {
                            "type": "array",
                            "description": "The dependencies to install before running the script.",
                            "items": {
                                "type": "string"
                            }
                        }
                    },
                    "required": ["script", "dependencies"]
                }
            }
    },
    {
        "type": "function",
        "function": 
            {
                "name": "search_internet",
                "description": "Search the internet for information.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "query": {
                            "type": "string",
                            "description": "The query to search the internet for."
                        }
                    },
                    "required": ["query"]
                }
            }
    },
    {
        "type": "function",
        "function": 
            {
                "name": "read_webpage",
                "description": "Read the content of a webpage.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "url": {
                            "type": "string",
                            "description": "The URL of the webpage to read."
                        }
                    },
                    "required": ["url"]
                }
            }
    }
        ]
    }

    headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer " + api_key
    }

    response = requests.post(url, headers=headers, json=template)

    if response.status_code != 200:
        print("Error:", response.status_code, response.text)
        exit()

    response_data = response.json()["choices"][0]["message"]

    if response_data.get("content") and not response_data.get("tool_calls"):
        print(response_data["content"])
        messages.append(response_data)
    if response_data.get("tool_calls"):
        if response_data.get("content"):
            print(response_data["content"])
        tool_calls = response_data['tool_calls']
        for function_call in tool_calls:
            function_name = function_call["function"]['name']
            arguments = function_call["function"]['arguments']

            available_functions = {
                "run_cli_command": run_cli_command,
                "run_python": run_python_script,
                "search_internet": search_internet,
                "read_webpage": get_url_content
            }

            if function_name in available_functions:
                print(">>> Calling tool: ", function_name)
                function_to_call = available_functions[function_name]
                output = function_to_call(arguments)
                messages.append(response_data)
                messages.append({
                    'role': 'tool',
                    'content': json.dumps(output),
                    'tool_call_id': function_call["id"]
                })

def prompt(file_path):
    global messages
    with open(file_path, "r") as file:
        data = file.read()
    messages.append({
    "role": "user",
    "content": data
    })
    while True:
        if messages[-1].get("role") != "tool" and len(messages) > 2:
            user_input = input("Enter your message (type e or exit to exit): ")
            if user_input.lower() == "exit" or user_input.lower() == "e":
                break
            messages.append({
                "role": "user",
                "content": user_input
            })
        executor()

# get all home directories
cdir = ""
if os.name == "nt":
    cdir = subprocess.check_output("echo %USERNAME%", shell=True).decode().strip()
else:
    cdir = run_cli_command({"command": "logname"}, True)

if not cdir:
    exit()
else:
    if os.name == "nt":
        desktop_files = run_cli_command({"command": f"dir /b C:\\Users\\{cdir.strip()}\\Desktop"}, True)
        forensic_files = [f"C:\\Users\\{cdir}\\Desktop\\{x}".replace('\n', '').replace("\r","") for x in desktop_files.split("\n") if "forensic" in x.lower() and x.lower().replace('\n', '').replace("\r","").endswith(".txt")]
    else:
        desktop_files = run_cli_command({"command": f"ls /home/{cdir.strip()}/Desktop"}, True)
        forensic_files = [f"/home/{cdir}/Desktop/{x}".replace('\n', '') for x in desktop_files.split("\n") if "forensic" in x.lower() and x.lower().replace('\n', '').replace("\r","").endswith(".txt")]
    for i, file in enumerate(forensic_files):
        if os.name == "nt":
            print(f"{i+1}. {file.replace(f'C:\\Users\\{cdir}\\Desktop\\', '')}")
        else:
            print(f"{i+1}. {file.replace(f'/home/{cdir}/Desktop/', '')}")
    file_choice = int(input("Choose a file: "))
    prompt(forensic_files[file_choice-1])