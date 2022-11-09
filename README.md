<h1 align="center">
  DoE Network Kit Linux
  
  [![Stars](https://img.shields.io/github/stars/toastxc/DoE-Network-Kit-Linux?style=flat-square&logoColor=white)](https://github.com/toastxc/DoE-Network-Kit-Linux/stargazers)
  [![Forks](https://img.shields.io/github/forks/toastxc/DoE-Network-Kit-Linux?style=flat-square&logoColor=white)](https://github.com/toastxc/DoE-Network-Kit-Linux/network/members)
  [![Pull Requests](https://img.shields.io/github/issues-pr/toastxc/DoE-Network-Kit-Linux?style=flat-square&logoColor=white)](https://github.com/toastxc/DoE-Network-Kit-Linux/pulls)
  [![Issues](https://img.shields.io/github/issues/toastxc/DoE-Network-Kit-Linux?style=flat-square&logoColor=white)](https://github.com/toastxc/DoE-Network-Kit-Linux/issues)
  [![Contributors](https://img.shields.io/github/contributors/toastxc/DoE-Network-Kit-Linux?style=flat-square&logoColor=white)](https://github.com/toastxc/DoE-Network-Kit-Linux/graphs/contributors)
  [![Licence](https://img.shields.io/github/license/toastxc/DoE-Network-Kit-Linux?style=flat-square&logoColor=white)](https://github.com/toastxc/DoE-Network-Kit-Linux/blob/main/LICENCE)
</h1>

A script for implementing security certificates from the Australian Department of Education into Linux

**THIS REPOSITORY WAS NOT MADE BY OR AUTHORISED BY THE DEPARTMENT OF EDUCATION, SOFTWARE COMES WITH ABSOLUTELY NO WARRENTY**

# Usage

```bash
git clone https://github.com/toastxc/DoE-Network-Kit-Linux.git
cd DoE-Network-Kit-Linux
```
Choose the script that matches your school (generic for if none apply)
```bash
sudo sh generic.sh
```

# Dependancies
- OpenSSL
- Curl
- Git (Optional)
- NetworkManager

# For Fedora Users
An update will be automatically applied for Fedora's networking, it can be found here:
https://github.com/toastxc/Fedora-Network-Fix


# For contributors
There are a few rules for contributing to this project
- Never package certificates, only download them from restricted repositories
- Test that modified scripts work before running a pull request
- Comment commplicated functions (bash can be hard to read)

![LGPLv3 Badge](/README_RESOURCES/LGPLv3%20Logo.svg)
