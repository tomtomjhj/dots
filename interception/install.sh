#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")"

sudo apt install cmake libboost-dev libevdev-dev libyaml-cpp-dev libudev-dev

# installs in /usr/local/bin
git clone https://gitlab.com/interception/linux/tools
(
    cd tools
    cmake -B build -DCMAKE_BUILD_TYPE=Release
    cmake --build build
    sudo cmake --install build
)

git clone https://gitlab.com/interception/linux/plugins/dual-function-keys
(
    cd dual-function-keys
    make && sudo make install
)

# configs
sudo mkdir /etc/interception
sudo cp udevmon.yaml /etc/interception/
sudo cp dual-function-keys.yaml /etc/interception/

# systemd
sudo cp udevmon.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now udevmon
