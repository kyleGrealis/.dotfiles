This is my repository for my GNU `stow` folders.

* sync dot files across devices
* easily manage changes to dot files & configurations
* version control for when I screw up... which will happen

Usage:

```
# Clone dotfiles
git clone https://github.com/kyleGrealis/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
   
# Restore packages
sudo pacman -S --needed - < arch-packages.txt
yay -S --needed - < aur-packages.txt
   
# Stow configs
stow -vt $HOME <directory> <directory2>...
```
