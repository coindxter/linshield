<!-- ABOUT THE PROJECT -->
## About The Project

<!-- GETTING STARTED -->
## Getting Started

Detailed Ubuntu 22.04 hardening script for Cyberpatriots\
Make sure to mark main.py as an execuatable\
[Link to CIS Benchmarks](https://drive.google.com/drive/folders/1ypIhhKznlM7kV1YDaFEKwkTnpdsPZXk_?usp=sharing)\
[Link to learning images](https://drive.google.com/drive/u/1/folders/1w9VY57FTUfuPinmd2CvVs-oA5N03URW6)\
What doesn't currently work: remove_.forwardFiles.sh, remove_.netrcFiles.sh, remove_.rhostFiles.sh, wirelessInterface_disable.sh\
Some things to note:\
READ THE README FILE ON THE IMAGE, it will give you critical information as to if you need to modify any of the scripting files. For example, if the README says that ssh is a critical service, go into the apt_install.sh and edit out the part where the script purges ssh\
For some reason, script1.sh does not work when you git clone it. Go to the file in src and copy and paste it to a new text file and run chmod +x <txtfiletname> and then run it from there


### Prerequisites

* git
  ```sh
  sudo apt install git
  ```
* python3
  ```sh
  sudo apt install
  ```

### Installation

1. Clone the repo
   ```sh
   git clone https://github.com/Coin-Dexter/Minecraft-Hacks.git
   ```
2. Mark main.py as an execuable
   ```sh
   sudo chmod +x main.py
   ```

<!-- USAGE EXAMPLES -->
## Usage


<!-- ROADMAP -->
## Roadmap

- [x] example
- [x] example
- [ ] example
- [ ] example
- [ ] example
    - [ ] example
    - [ ] example

See the [open issues](https://github.com/Coin-Dexter/Minecraft-Hacks/issues) for a full list of proposed features (and known issues).

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

Your Name - [@your_twitter](https://twitter.com/your_username) - email@example.com

Project Link: [https://github.com/your_username/repo_name](https://github.com/your_username/repo_name)

<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

Use this space to list resources you find helpful and would like to give credit to. I've included a few of my favorites to kick things off!
