#!/bin/bash
echo "Installing pnpm"
wget -qO- https://get.pnpm.io/install.sh | sh -
echo "Reloading bash"
source ~/.bashrc
echo "Installing Node@Latest"
pnpm env use --global latest
echo "Done!"
