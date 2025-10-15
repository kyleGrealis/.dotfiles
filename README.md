This is my repository for my GNU `stow` folders.

* sync dot files across devices
* easily manage changes to dot files & configurations
* version control for when I screw up... which will happen

## Main configurations

```bash
# Clone dotfiles
git clone https://github.com/kyleGrealis/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
   
# Restore Arch packages
sudo pacman -S --needed - < arch-packages.txt
yay -S --needed - < aur-packages.txt
   
# Stow configs
stow -vt $HOME <directory> <directory2>...
```

---

## System configurations

Some configs require sudo and can't be stowed. Copy manually:
```bash
# GRUB configuration
sudo cp ~/.dotfiles/system/etc/default/grub /etc/default/grub

# Rebuild GRUB
update-grub  # if .dotfiles/local-bin has been stowed already, or...
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

---

## SSH keys & configurations

... are stored in a private repo for security.
