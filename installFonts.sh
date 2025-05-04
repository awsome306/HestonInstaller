for fontName in BigBlueTerminal DroidSansMono Ubuntu UbuntuMono CascadiaCode JetBrainsMono
do
    wget -P ~/.fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/$fontName.zip
    yes | unzip ~/.fonts/$fontName.zip  -d ~/.fonts
done
rm ~/.fonts/*.zip

fc-cache -f -v

# List installed Fonts:
fc-list|awk '{$1=""}1'|cut -d: -f1|sort|uniq