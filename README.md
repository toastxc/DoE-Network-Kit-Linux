<h1 align="center">
  Department of Education Network Kit for Linux
  
  [![Stars](https://img.shields.io/github/stars/toastxc/DoE-Network-Kit-Linux?style=flat-square&logoColor=white)](https://github.com/toastxc/DoE-Network-Kit-Linux/stargazers)
  [![Forks](https://img.shields.io/github/forks/toastxc/DoE-Network-Kit-Linux?style=flat-square&logoColor=white)](https://github.com/toastxc/DoE-Network-Kit-Linux/network/members)
  [![Pull Requests](https://img.shields.io/github/issues-pr/toastxc/DoE-Network-Kit-Linux?style=flat-square&logoColor=white)](https://github.com/toastxc/DoE-Network-Kit-Linux/pulls)
  [![Issues](https://img.shields.io/github/issues/toastxc/DoE-Network-Kit-Linux?style=flat-square&logoColor=white)](https://github.com/toastxc/DoE-Network-Kit-Linux/issues)
  [![Contributors](https://img.shields.io/github/contributors/toastxc/DoE-Network-Kit-Linux?style=flat-square&logoColor=white)](https://github.com/toastxc/DoE-Network-Kit-Linux/graphs/contributors)
  [![Licence](https://img.shields.io/github/license/toastxc/DoE-Network-Kit-Linux?style=flat-square&logoColor=white)](https://github.com/toastxc/DoE-Network-Kit-Linux/blob/main/LICENCE)
</h1>

A set of scripts for implementing security certificates from the Australian Department of Education into Linux.

> [!IMPORTANT]
> This repository was not made or authorised by the Department of Education. Software comes with absolutely no warranty.

> [!NOTE]
> This repository is no longer actively maintained due to the primary contributors having graduated. It should continue to work into the future but may need minor tweaks. Please feel free to [contact Declan Chidlow](https://vale.rocks/contact) if necessary.

## Usage

Consult the guide [Connecting to Australian Public School Internet](https://vale.rocks/posts/connecting-to-australian-public-school-internet) or follow this concise guide below:

```console
$ git clone https://github.com/toastxc/DoE-Network-Kit-Linux.git
$ cd DoE-Network-Kit-Linux
```

Choose the script that matches your school. Use `generic.sh` if there isn't one specific for your institution.

```console
# sh generic.sh
```

## Dependencies

- OpenSSL
- Curl
- Git (optional)
- NetworkManager

## For Fedora Users

An update will be automatically applied for Fedora's networking. It can be found here: \
https://github.com/toastxc/Fedora-Network-Fix

## For Contributors

There are a few rules for contributing to this project.

- Never package certificates; only download them from restricted repositories.
- Test that modified scripts work before running a pull request.
- Comment complicated functions (BASH can be hard to read).
