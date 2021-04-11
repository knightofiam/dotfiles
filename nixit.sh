#!/usr/bin/env bash

# Convert dotfiles directory for Linux.

THIS_DIR="${BASH_SOURCE%/*}"
[[ ! -d "$THIS_DIR" ]] && THIS_DIR="$PWD"

SHEBANG="#!/usr/bin/env bash"
package_type=""
package_command=""
package_update=""
package_install=""
package_uninstall=""
homebrew_pre_install=""

if command -v rpm &>/dev/null; then
  package_type="rpm"
  package_command="sudo yum"
  package_update="${package_command} check-update"
  package_install="${package_command} -y install"
  package_uninstall="${package_command} -y remove"
  homebrew_pre_install="${package_update}; ${package_install} @'Development Tools' curl file gawk git libxcrypt-compat"
elif command -v dpkg &>/dev/null; then
  package_type="deb"
  package_command="sudo apt-get"
  package_update="${package_command} update"
  package_install="${package_command} -y install"
  package_uninstall="${package_command} -y purge"
  homebrew_pre_install="${package_update}; ${package_install} build-essential curl file gawk git"
else
  printf "Error: Unsupported OS. Could not detect a valid Linux package manager.\n"
  exit 1
fi

# Remove macOS-specific dotfiles.
declare -a files=("cvimrc" "dock.sh" "duti" "duti.sh" "ideavimrc" "iterm2.sh" "macos.sh" "mvim.sh" "xcode.sh")
for i in "${files[@]}"
do
  rm "${THIS_DIR}/${i}" &>/dev/null
done

# install.sh: Remove macOS-specific content.
declare -a install=("dock" "duti" "iterm2" "macos" "mvim" "xcode")
for i in "${install[@]}"
do
  sed -i "/${i}/d" "${THIS_DIR}/install.sh"
done

# install.sh: Modify for Linux.
bashrc_append="grep -Fxq \"[[ -f ~/.bash_profile ]] \&\& . ~/.bash_profile\" ~/.bashrc || echo -e \"\\\n[[ -f ~/.bash_profile ]] \&\& . ~/.bash_profile\" >> ~/.bashrc"
bashrc_append_grep="${bashrc_append//\\&/&}"
bashrc_append_grep="${bashrc_append_grep//\\n/n}"
brew_path="export PATH=\"/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:\${PATH}\""
grep -Fxq "${brew_path}" install.sh || sed -i "s,${SHEBANG},${SHEBANG}\\n\\n${brew_path}," install.sh
grep -Fxq "${bashrc_append_grep}" install.sh || sed -i "s,${SHEBANG},${SHEBANG}\\n\\n${bashrc_append}," install.sh

# brew.sh: Modify for Linux.
homebrew_post_install="${package_install} vim-gtk"
homebrew_post_uninstall="${package_uninstall} gawk git"
grep -Fxq "${homebrew_pre_install}" brew.sh || sed -i "s,${SHEBANG},${SHEBANG}\\n\\n${homebrew_pre_install}," brew.sh
grep -Fxq "${homebrew_post_install}" brew.sh || echo -e "\n${homebrew_post_install}" >> brew.sh
grep -Fxq "${homebrew_post_uninstall}" brew.sh || echo -e "\n${homebrew_post_uninstall}" >> brew.sh

# Brewfile: Remove macOS-specific content.
declare -a brewfile=("cask" "dock" "duti" "mackup" "mas")
for i in "${brewfile[@]}"
do
  sed -i "/${i}/d" "${THIS_DIR}/Brewfile"
done

# bash_profile: Modify for Linux.
sed -i "s/\(brew_prefix=\"\)\/usr\/local\(\"\)/\1\/home\/linuxbrew\/\.linuxbrew\2/g" bash_profile

# git/gitconfig: Modify for Linux
sed -i 's/\/usr\/local\/bin\/vim/\/usr\/bin\/vim/g' git/gitconfig

# gpg.sh: Modify for Linux.
op_install="curl -s https://cache.agilebits.com/dist/1P/op/pkg/v1.8.0/op_linux_amd64_v1.8.0.zip > op.zip \&\& sudo unzip -o op.zip op -d /usr/local/bin/ \&\& rm op.zip"
grep -Fxq "${op_install//\\&/&}" gpg.sh || sed -i "s,${SHEBANG},${SHEBANG}\\n\\n${op_install}," gpg.sh

# shell.sh: Modify for Linux.
chsh_install="${package_update}; ${package_install} util-linux"
grep -Fxq "${chsh_install}" shell.sh || sed -i "s,${SHEBANG},${SHEBANG}\\n\\n${chsh_install}," shell.sh
sed -i '/# Use Touch ID in shell./,$d' shell.sh

# symlinks: Remove macOS-specific content.
declare -a symlinks=("cvimrc" "duti" "ideavimrc")
for i in "${symlinks[@]}"
do
  sed -i "/${i}/d" "${THIS_DIR}/symlinks"
done
