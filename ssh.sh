#!/usr/bin/env bash

THIS_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

# Required for authorized_keys to work properly.
sudo chmod 700 ${THIS_DIR}/ssh

ssh_keys_original="${HOME}/.ssh/authorized_keys"
ssh_keys_backup="${HOME}/.ssh.backup/authorized_keys"

if [[ -f ${ssh_keys_original} ]]; then
  cp -n "${ssh_keys_original}" "${THIS_DIR}/ssh/"
elif [[ -f ${ssh_keys_backup} ]]; then
  cp -n "${ssh_keys_backup}" "${THIS_DIR}/ssh/"
fi
