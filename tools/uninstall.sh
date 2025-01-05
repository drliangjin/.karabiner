#!/usr/bin/env bash

set -e

# macOS only
[[ "$(uname -s)" = "Darwin" ]] || echo "Karabiner-Elements is only available for macOS" && exit 1

GH_REPO=mini-karabiner-elements
GH_DIR=~/${GH_REPO}
LN_DIR=~/.config/karabiner

if [[ -L "${LN_DIR}" ]]; then
  unlink -rf ${LN_DIR}
fi

if [[ -d "${GH_REPO}" ]]; then
  rm -rf /${GH_REPO}
fi
