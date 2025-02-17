#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
set -e

# macOS only
[[ ! "$(uname -s)" = "Darwin" ]] && echo "Sorry, macOS only!" && return 1

# Remote configuration repo
GH_USER="drliangjin"
GH_REPO="karabiner.d"
GH_BRANCH="master"

# Local configuration dir
CONFIG_DIR="$HOME/${GH_REPO}"
BACKUP_DIR="$HOME/Backups"

# symlink
LINK_DIR="$HOME/.config/karabiner"

# command checking
function command_exists() {
  command -v $1 > /dev/null 2>&1
}

# Homebrew
function install_homebrew() {
  if ! command_exists brew; then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" > /dev/null 2>&1
    if [[ $? != 0 ]]; then
      echo " => unable to install Homebrew!"
      return 1
    fi
  fi
}
      
# brew install
function brew_install() {
  local formulae=$1
  if [[ ! -z "${formulae}" ]]; then
    echo "Installing $formulae..."
    if ! brew list "${formulae}" > /dev/null 2>&1; then
      brew install "${formulae}" > /dev/null 2>&1 
      if [[ $? != 0 ]]; then
        echo " => unable to install "${formulae}" !"
        return 1
      else
        echo "Installing "${formulae}"...done "
      fi
    else
      echo "Installing "${formulae}"...skipped "
    fi
  fi
}

# cask install
function cask_install() {
  local formulae=$1
  if [[ ! -z "${formulae}" ]]; then
    echo "Installing "${formulae}"..."
    if ! brew list --cask "${formulae}" > /dev/null 2>&1; then
      brew install --cask $formulae > /dev/null 2>&1 
      if [[ $? != 0 ]]; then
        echo " => unable to install "${formulae}" !"
        return 1
      else
        echo "Installing "${formulae}"...done "
      fi
    else
      echo "Installing "${formulae}"...skipped "
    fi
  fi
}

# clone and link config
function deploy_config() {
  local config_name="${GH_REPO}"
  local config_dir="${CONFIG_DIR}"
  local backup_dir="${BACKUP_DIR}"
  local target_dir="${LINK_DIR}"
  
  if [[ -d "${config_dir}" ]]; then
    echo "Backing up existing "${config_name}"... "
    if [[ ! -d "${backup_dir}" ]]; then
      mkdir -p "${backup_dir}"
    fi
    mv "${config_dir}" "${backup_dir}" && \
    echo "Backing up existing "${config_name}"...done "
  fi
  
  echo "Cloning "${config_name}"..."
  git clone -q -b ${GH_BRANCH} https://github.com/${GH_USER}/${GH_REPO}.git && \
  if [[ $? != 0 ]]; then
    echo " => unable to clone "${config_name}" !"
    return 1
  else
    echo "Cloning "${config_name}"...done "
  fi
  
  echo "Linking "${config_name}"..."
  [[ -d "$HOME/.config" ]] || mkdir "$HOME/.config"
  [[ -d "${target_dir}" ]] && rm -rf "${target_dir}"
  ln -sf "${config_dir}" "${target_dir}"
  if [[ $? != 0 ]]; then
    echo " => unable to link "${config_name}" !"
    return 1
  else
    echo "Linking "${config_name}"...done "
  fi
  
}

function main() {
  install_homebrew && \
  cask_install karabiner-elements && \
  deploy_config
}

main
