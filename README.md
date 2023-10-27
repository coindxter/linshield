<!-- ABOUT THE PROJECT -->
## About The Project
This is a detailed Ubuntu 22.04 hardening script for Cyberpatriots. This is not fully done. There are still many, many things me and my team need to add to polish this up. I personally don't think this will ever be finsihed as Cyberpatiots is an ever changing compitetion with different vulnurablitys each image. This project aims to configure an Ubuntu 22.04 virtual computer as polished as possible. Thank you for using this project for your needs and please submit issues that you've come across and I will try to fix it as soon as possible (thank you for your patience in advance).

<!-- GETTING STARTED -->
## Getting Started

[Link to CIS Benchmarks](https://drive.google.com/drive/folders/1ypIhhKznlM7kV1YDaFEKwkTnpdsPZXk_?usp=sharing)\
[Link to learning images](https://drive.google.com/drive/u/1/folders/1w9VY57FTUfuPinmd2CvVs-oA5N03URW6)\
Some things to note:\
-READ THE README FILE ON THE IMAGE, it will give you critical information as to if you need to modify any of the scripting files. For example, if the README says that ssh is a critical service, go into the apt_install.sh and edit out the part where the script purges ssh. I have sperated these scripts so it is possible to make last miniute ajustment to better suit your needs.\
-There are two main sripts, main.py and script1.sh. main.py is my custom script and uses code that I wrote. Scrpit1.sh is not my script and was writin by Ethan Fowler of Team-ByTE. Links to him and his team will be in [Acknowledgments](#acknowledgments)

<!-- Important Notes -->
## IMPORTANT!
Please please please, ***NEVER EVER*** run programs in root. If you need to a command that requires root, just use sudo <command>. I beg you to do this. Running commands as root is useful, only if you know what you are doing, otherwise, it will screw up permisions of files you manipulate. All commands run in my scrpit make use of sudo instead of running the script as root.\

Also, the main script does not work as of writing this, so just run each script on its own. For example




### Prerequisites

* git
  ```sh
  sudo apt install git
  ```
* python3
  ```sh
  sudo apt-get install python3
  ```

### Installation

1. Clone the repo
   ```sh
   git clone https://github.com/coindxter/ubushield.git
   ```
2. Mark main.py as an executable
   ```sh
   sudo chmod +x main.py
   ```
3. Then run main.py
   ```sh
   ./main.py
   ```

If you want to use script1.sh, mark it as an executable
  ```sh
  sudo chmod +x script1.sh
  ```
<!-- USAGE EXAMPLES -->
## Usage



<!-- ROADMAP -->
## Roadmap
What doesn't currently work
  - [ ] remove_.forwardFiles.sh
  - [ ] remove_.netrcFiles.sh
  - [ ] remove_.rhostFiles.sh
  - [ ] wirelessInterface_disable.sh
  - [ ] main.py

What will be added
  - [ ] SSH Configurater
  - [ ] Apache2 Configurater
  - [ ] Google Chrome benchmark script
        
Misolanious scripts/helper scripts
   - [ ] Auto user passwords (see issues)
    


See the [open issues](https://github.com/coindxter/ubushield/issues) for a full list of proposed features (and known issues).

<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE.txt` for more information.


<!-- CONTACT -->
## Contact

Discord - [coindxter](https://discrodapp.com/users/728364815130820709)\
Project Link -  [https://github.com/coindxter/ubuhield](https://github.com/coindxter/ubushield)

<!-- ACKNOWLEDGMENTS -->
## Acknowledgments
I would like to acknowledge Ethan Fowler for his script that I have implemnted in this script. This is the link to his [repository](https://github.com/ponkio/CyberPatriot/tree/master)
