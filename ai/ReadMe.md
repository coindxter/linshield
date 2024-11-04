# README Parser Script

This project includes a Python script (`readme_parser.py`) that processes a CyberPatriot README in HTML format, extracts structured data using OpenAI's GPT-4, and outputs it as a JSON file.

## Prerequisites

1. **Python 3.7+**: Ensure Python is installed on your system.
2. **Dependencies**: Install the required Python libraries:
   ```bash
   pip install openai beautifulsoup4 jsonschema
   ```
## Setting Up Your OpenAI API Key (Environment Variable)
To run this script, you need to set up your OPENAI_API_KEY in your environment.

### For Linux/Mac:
1. Open your terminal
2. Run the following command to set the API key temporarily (only for the current session):
   ```bash
   export OPENAI_API_KEY="your_secure_api_key"
   ```
3. To set the API key permanently, add the line to your shell configuration file (`~/.bashrc, ~/.bash_profile, or ~/.zshrc):`
   ```bash
   echo 'export OPENAI_API_KEY="your_secure_api_key"' >> ~/.bashrc
   ```
   ```bash
   source ~/.bashrc
   ```

### For Windows:
1. Open Command Prompt or PowerShell
2. Run the following command to set the API key temporarily (only for the current session):
   ```bash
   set OPENAI_API_KEY="your_secure_api_key"
   ```
3. To set the API key permanently:
   - Open **Control Panel > System and Security > System > Advanced system settings**
   - Click on **Environment Variables**
   - Under **User variables** or **System variables**, click **New** and add:
      - **Variable name**: `OPENAI_API_KEY`   
      - **Variable value**: `your_secure_api_key`
4. Click **OK** and restart your Command Prompt or computer for the changes to take effect.

