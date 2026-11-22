#!/bin/bash
fontVersion=3.5.1
for fontName in AtkinsonHyperlegibleMono BigBlueTerminal CascadiaCode DroidSansMono Gohu InconsolataGo Iosevka IosevkaTerm JetBrainsMono Ubuntu UbuntuMono ZedMono
do
    if [ -d "$HOME/.fonts/$fontName" ]; then
        echo -e "$fontName \t is already installed."
        continue
    fi
    echo "$fontName is NOT already installed; installing now."
    wget -P ~/.fonts https://github.com/ryanoasis/nerd-fonts/releases/download/$fontVersion/$fontName.zip
    yes | unzip ~/.fonts/$fontName.zip  -d ~/.fonts/$fontName
done
# Removes ALL zip files in the fonts directory
rm ~/.fonts/*.zip

fc-cache -f -v

# List installed Fonts:
fc-list|awk '{$1=""}1'|cut -d: -f1|sort|uniq
