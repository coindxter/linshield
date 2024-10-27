<!-- ABOUT THE PROJECT -->
## About The Project
This is a detailed Ubuntu 22.04 and Debian 11 hardening script for Cyberpatriots. This is not fully done. There are still many, many things me and my team need to add to polish this up. I personally don't think this will ever be finsihed as Cyberpatiots is an ever changing compitetion with different vulnurablitys each image. This project aims to configure an Ubuntu 22.04 and a Debian 11 virtual computer as polished as possible. Thank you for using this project for your needs and please submit issues that you've come across and me and my team will try to fix it as soon as possible (thank you for your patience in advance).

<!-- GETTING STARTED -->
## Getting Started
Some things to note:\
-READ THE README FILE ON THE IMAGE, it will give you critical information as to if you need to modify any of the scripting files. For example, if the README says that ssh is a critical service, go into the apt_install.sh and edit out the part where the script purges ssh. I have made it super easy to make last miniute adjustments to the scripts to better suit your needs.\
-All scripts so far are copyed and pasted from the CIS benchmarks for [Ubuntu 22.04](https://drive.google.com/drive/folders/1iwv5_95D-gDa7hn9o9zfXLLVjZSOa_Oz) unless otherwise noted and most of them are not broken unlesss otherwise noted (see [Roadmap](#roadmap))


<!-- Important Notes -->
## IMPORTANT!
Please please please, **NEVER EVER** run programs in root. If you need to a command that requires root, just use sudo "command". I beg you to do this. Running commands as root is useful, only if you know what you are doing, otherwise, it will screw up permisions of files you manipulate. All commands run in my scrpit make use of sudo instead of running the script as root.\

Also, the main script does not work as of writing this, so just run each script on its own



### Prerequisites

* git
  ```sh
  sudo apt install git
  ```
* python3
  ```sh
  sudo apt-get install python3
  ```
* github token for cloning
[how to make one](https://docs.github.com/en/enterprise-server@3.6/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)



### Installation

**1.** Clone the repo
   ```sh
   git clone https://github.com/coindxter/linshield.git
   ```
**2.** Enter your github username

**3.** Enter your github token NOT YOUR GITHUB PASSWORD

**4.** Move into the correct directory

  For Ubuntu 
  ```sh
  cd /root/ubu/src/scr
  ```

  For Debian
  ```sh
  cd /root/deb/src/scr
  ```

**5.** Run main file

  For Ubuntu:
  ```sh
  sudo bash main.py
  ```
  Or 
  ```sh
  sudo bash script1.py
  ```


  For Debian:
  ```sh
  sudo -S source harden.sh
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


What will be added
  - [ ] SSH Configurater
  - [ ] Apache2 Configurater
  - [ ] Google Chrome benchmark script
  - [ ] Implementation and Usage of Anti-Virus Software
  - [ ] AppArmor Implemntation for both Debian and Ubuntu 
  - [ ] Add support for Mint 
 

        
Misolanious scripts/helper scripts
 - [ ]
 - [ ] 
 
Testing
  - [ ]
  - [ ] 
  

See [here](https://docs.google.com/document/d/1-FsZslNIoV-RhUrHJwwTRpoqesvRpsoWxYrz_h87TeI/edit?usp=sharing) for a more extensive to-do list\
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

Directory's are organized as follows:

    root
      |
      |_archive
      |
      |_util(helper scripts)
      |
      |_deb(debian)
      |   |
      |   |_src(source)
      |     |
      |     |_scr(script)
      |     
      |
      |_ubu(ubutu)
          |
          |_src(source)
              |
              |_scr(script)
      
              

Please keep this file structure like this as it will keep everything organized. Everything Debian related will go under root/deb and everything ubuntu related will go under root/ubu. Both root/deb and root/ubu have source files that will have everything for each programs and there will be scr/ for all scripts related to the topic. 


<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE.txt` for more information.


<!-- CONTACT -->
## Contact

Discord - [coindxter](https://discrodapp.com/users/728364815130820709)\
Project Link -  [https://github.com/coindxter/ubuhield](https://github.com/coindxter/linshield)

<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

I would like to acknowledge Ethan Fowler for his script that I have implemnted in this project. This is the link to his [repository](https://github.com/ponkio/CyberPatriot/tree/master)

<!-- RESOURCES -->
## Resources

[Link to CIS Benchmarks](https://drive.google.com/drive/folders/1ypIhhKznlM7kV1YDaFEKwkTnpdsPZXk_?usp=sharing)\
[Link to learning images](https://drive.google.com/drive/u/1/folders/1w9VY57FTUfuPinmd2CvVs-oA5N03URW6)\
[Link to Round 2 Debian Practice Image 2023](https://docs.google.com/document/d/10vg4U3EpGVp7VSqat-g2Pg2Qn-7W2-x4ySpIYPXFS-w/edit)
[ETA CyberPatriot Wiki](http://cypat.guru/index.php/Main_Page)\
[Canonical Ubuntu 18.04 LTS Security Technical Implementation Guide](https://www.stigviewer.com/stig/canonical_ubuntu_18.04_lts/)\
[openstack/ansible-hardening](https://github.com/openstack/ansible-hardening)\
[SELinux/Setup - Debian Wiki](https://wiki.debian.org/SELinux/Setup)\
[SSL/TLS Strong Encryption: How-To - Apache HTTP Server Version 2.4](https://httpd.apache.org/docs/2.4/ssl/ssl_howto.html)\
[Apache Web Server Hardening and Security Guide](https://geekflare.com/apache-web-server-hardening-security/)


