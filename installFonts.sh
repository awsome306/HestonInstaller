for fontName in BigBlueTerminal DroidSansMono Ubuntu UbuntuMono CascadiaCode JetBrainsMono InconsolataGo Gohu Iosevka IosevkaTerm AtkinsonHyperlegibleMono
do
    wget -P ~/.fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v3.5.1/$fontName.zip
    yes | unzip ~/.fonts/$fontName.zip  -d ~/.fonts/$fontName
done
# Removes ALL zip files in the fonts directory
rm ~/.fonts/*.zip

fc-cache -f -v

# List installed Fonts:
fc-list|awk '{$1=""}1'|cut -d: -f1|sort|uniq