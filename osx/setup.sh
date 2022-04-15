#!/bin/bash

echo "brew installing stuff..."
sh brew_install.sh

echo "luarocks inspect module..."
luarocks install inspect

# install the spaces spoon for hammerspoon
curl -s https://api.github.com/repos/asmagill/hs._asm.undocumented.spaces/releases/latest \
        |grep "browser_download_url" \
        | cut -d : -f 2,3 | tr -d \" \
        | wget -qi -
tar -zxvf spaces-.*.tar.gz -C ~/.hammerspoon/

echo "spacemacs..."
git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d
