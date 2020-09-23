Visual Studio Code
==================

Go [here][download] for downloads.

Usage
-----

This configuration is managed by invoking various make targets defined in the
`Makefile`.

### Install

Begin by cloning the repository into `~/.vscode` if you are using Linux or
macOS, or `%USERPROFILE%\.vscode` if you are using Windows. Move into this
directory and execute the following command:

```shell
$ make init
```

This will install your extensions and link the `settings.json` file into the
appropriate directory on your system. According to the
[documentation][settings], the user settings file can be located in the
following places:

* **Linux:** `${HOME}/.config/Code/User/settings.json`
* **Windows:** `%APPDATA%\Code\User\settings.json`
* **macOS:** `${HOME}/Library/Application Support/Code/User/settings.json`

### Update

Execute the following command to pull changes from the repository and update
installed extensions.

```shell
$ make update
```

Symbolic links on Windows
-------------------------

Normal user accounts do not have the required `SeCreateSymbolicLinkPrivilege`
privilege enabled by default.

### How to enable

1. Open *Local Security Policy* or `secpol.msc`.
2. Navigate to *Local Policies* followed by *User Rights Assignment*.
3. Open the *Create symbolic links* policy.
4. Click *Add User or Group...* and add the appropriate username.

[download]: https://code.visualstudio.com/download
[settings]: https://code.visualstudio.com/docs/getstarted/settings
