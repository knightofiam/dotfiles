#!/usr/bin/env bash

# Python 2 no longer exists on MacOS by default, causing problems in some apps
# such as ebcli. Symlink 'python' command to 'python3'.
sudo ln -s /usr/local/bin/python3 /usr/local/bin/python
