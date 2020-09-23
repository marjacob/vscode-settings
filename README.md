Visual Studio Code
==================

Installing
----------

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

Updating
--------

Execute the following command to pull changes from the repository and update
installed extensions.

```shell
$ make update
```

[settings]: https://code.visualstudio.com/docs/getstarted/settings
