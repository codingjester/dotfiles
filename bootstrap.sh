#!/usr/bin/env bash

PKG_MNGR="${PKG_MANAGER:-brew}"
GITHUB_USERNAME="${GITHUB_USERNAME:-codingjester}"
OS=`uname`

# verify which package managers we support based on operating system
# this could definitely be less chaotic neutral
verify_package_managers() {
  # asdf check and coder check
  if [[ "$OS" == "Linux" && ! -z ${CODER_WORKSPACE_NAME} ]];
  then
    # asdf for now bc of reasons
    PKG_MNGR="asdf"
  elif [[ "$OS" == "Darwin" ]];
  then
    if ! command -v brew &> /dev/null
    then
      echo "brew not found. please install brew"
      exit 1
    fi
    echo "Mac OS and brew detected. using those"
  fi
}

# install chezmoi
chezmoi_install() {
  echo "checking if chezmoi is installed..."
  if ! command -v chezmoi &> /dev/null
  then
    echo "installing chezmoi and the dot files repo from $GITHUB_USERNAME"
    sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME
  fi
}

# bootstrap asdf
asdf_bootstrap() {
  if [[ -d ~/.asdf ]]; 
  then
    source ~/.asdf/asdf.sh
    asdf update
  else
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf
    source ~/.asdf/asdf.sh
  fi

  # bootstrapping plugins, you should have a tool versions
  for plugin in $(awk '{print $1}' ~/.tool-versions);
  do
    asdf plugin add "${plugin}"
  done

  asdf install
}

# bootstrap brew
brew_bootstrap() {
  echo "would do things related to chezmoi and installing"
}

## MAIN

# install chezmoi
chezmoi_install

# verify the packages
verify_package_managers

# install based on your poison, this could be better
if [[ "$PKG_MNGR" == "brew" ]];
then
  brew_bootstrap
elif [[ "$PKG_MNGR" == "asdf" ]];
then
  asdf_bootstrap
fi

# install tmux bootstrap
if [[ ! -d ~/.tmux/plugins/tpm ]];
then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# if it's a coder specific setup setup your git config
if [[ ! -z ${CODER_OWNER_EMAIL} ]];
then
  USERNAME=$(echo "$CODER_OWNER_EMAIL" | sed -e "s%\@.*$%%g" -e "s%\.% %g" -e "s%\b\(.\)%\u\1%g")
  git config --global user.name "${USERNAME}"
  git config --global user.email "${CODER_OWNER_EMAIL}"
fi
