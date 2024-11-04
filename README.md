# LinShield - Ubuntu 22.04 & Debian 11 Hardening Script

![License](https://img.shields.io/badge/license-MIT-blue)
![GitHub stars](https://img.shields.io/github/stars/coindxter/linshield?style=social)

## Table of Contents
- [About The Project](#about-the-project)
- [Features](#features)
- [Getting Started](#getting-started)
- [Installation](#installation)
- [Usage](#usage)
- [Project Structure](#project-structure)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)
- [Acknowledgments](#acknowledgments)
- [Resources](#resources)
- [Issues](#issues)

## About The Project
Linshield is a comprehensive hardening script designed for CyberPatriots participants, aimed at improving the security of Linux systems. This project helps users configure a virtual computer with a focus on competition needs, addressing vulnerabilities as they change over time. 

## The Goal
The goal of this project is to script the CIS Benchmarks for Ubuntu, Debian, Mint, etc, and to complete Cyberpatriot compitions fast and as efficient as possible.

**Note**: This project is constantly evolving, and contributions are encouraged to adapt to new vulnerabilities and challenges.

## Features
- Configures security settings based on CIS benchmarks
- Easy-to-modify scripts for last-minute competition adjustments
- Ai! Uses Chatgpt 4o to create custom configs for scripts
- Modular scripts for tailored use (run individually if needed)

## Getting Started
Before using this project, **read any README files provided with the competition image**. These files may contain crucial information for modifying scripts to suit your specific needs, such as preserving critical services like SSH.

## Installation

### Prerequisites

- **GitHub Token**: Contact the project maintainer for access.

#### On the VM:
Ensure the following are installed:
- **Git**: 
  ```bash
  sudo apt install git
  ```
- **Python3**:
  ```bash
  sudo apt-get install python3
  ```
- **OpenAI Library**:
  ```bash
  pip install openai
  ```
- **jsonschema library**:
  ```bash
  pip install jsonschema
  ``` 
#### On the Host Machine:

- **Ensure that you are using the lastest versoin of VMware Workstatoin Pro**. It is free and easy to use and using snapshots saves so much time.

### Installation Steps
1. **Clone the repository**:
   ```bash
   git clone https://github.com/coindxter/linshield.git
   ```
2. **Enter GitHub username**
   
3. **Enter the Repository token**

4. **Run the main script**(doesn't currently work, please run scripts individually:
   ```bash
   sudo python3 main.py
   ```

## Usage
Run each script as needed for specific hardening tasks. Refer to the provided README files or comments within each script for more details. **Do not execute the entire script as root.**

## Project Structure
The project is organized as follows:

```
root
│
|
│
├── util (Helper scripts)
│
├── deb (Debian-specific scripts)
│   └── src
│       └── scr (Main scripts)
│
└── ubu (Ubuntu-specific scripts)
    └── src
        └── scr (Main scripts)
```

Keep this file structure intact for better organization and clarity.

## Roadmap
### Current Known Issues
- [ ] `remove_.forwardFiles.sh`
- [ ] `remove_.netrcFiles.sh`
- [ ] `remove_.rhostFiles.sh`
- [ ] `wirelessInterface_disable.sh`
- [ ] `updates.bash` (causes Firefox issues)


### Planned Features
- [ ] SSH Configurator
- [ ] Apache2 Configurator
- [ ] Google Chrome benchmark script
- [ ] Integration of antivirus software
- [ ] Support for Linux Mint
- [ ] ReadMe paser
- [ ] Forensics question solver


For a detailed to-do list, refer to [this document](https://docs.google.com/document/d/1-FsZslNIoV-RhUrHJwwTRpoqesvRpsoWxYrz_h87TeI/edit?usp=sharing).

## Contributing
Contributions are welcome! Follow these steps:
1. Fork the project.
2. Create a feature branch (`git checkout -b feature/AmazingFeature`).
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4. Push to the branch (`git push origin feature/AmazingFeature`).
5. Open a pull request.

## License
Distributed under the MIT License. See `LICENSE.txt` for more information.

## Contact
- Discord: [coindxter](https://discordapp.com/users/728364815130820709)
- Project Link: [GitHub](https://github.com/coindxter/linshield)

## Acknowledgments
Thank you to my Cyberpatriot team members for ideas and scripts that they have found or made. And esspecially Chatgpt.

## Resources and Extra stuff
- [CIS Benchmarks](https://drive.google.com/drive/folders/1ypIhhKznlM7kV1YDaFEKwkTnpdsPZXk_)
- [Learning Images](https://drive.google.com/drive/u/1/folders/1w9VY57FTUfuPinmd2CvVs-oA5N03URW6)
- [Debian Wiki - SELinux Setup](https://wiki.debian.org/SELinux/Setup)
- [Apache Hardening Guide](https://geekflare.com/apache-web-server-hardening-security/)
- [Configurator Windows](https://cyberpatriots.nyc3.cdn.digitaloceanspaces.com/scripts/go/build_configs.exe) (Windows only)

## Issues
For known issues and to report new ones, visit [GitHub Issues](https://github.com/coindxter/linshield/issues).

