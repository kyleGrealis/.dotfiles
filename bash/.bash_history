df -h
sudo mount /dev/sdb1 /mnt
ls -lah /mnt/
cp /mnt/home-backup.tar.gz /home/kyle/
ls -la
tar -tzvf /home/kyle/home-backup.tar.gz | head -n 20
tar -tzvf /home/kyle/home-backup.tar.gz | grep -E "Documents|.bashrc|.config"
tar -tzvf /home/kyle/home-backup.tar.gz | head -n 20
sudo tar -xzvf /home/kyle/home-backup.tar.gz -C /home
ls
ls -la
sudo chown -R kyle:kyle /home/kyle
sudo reboot
ls -la
ls -la .ssh/
sudo tar -xzvf /home/kyle/home-backup.tar.gz -C /home --overwrite
ls -la
ls .config
sudo mount /dev/sda1 /mnt
kyle
cd /mnt
ls -la
cd linux-setup/
cat setup-1.sh 
ls
ls -la
ls -la .ssh/
nano setup-1.sh 
bash setup-1.sh 
nano setup-1.sh 
bash setup-1.sh 
ls ~
nano setup-1.sh 
bash setup-1.sh 
nano setup-1.sh 
bash setup-1.sh 
xclip -sel clip < ~/.ssh/id_ed25519.pub
nano setup-1.sh 
bash setup-1.sh 
sudo apt modernize-sources 
sudo cat /etc/apt/sources.list.d/debian.sources 
sudo nano /etc/apt/sources.list.d/debian-backports.sources 
sudo apt update
sudo tailscale up --accept-routes=true
cat setup-1.sh 
cat ~/.config/froggeR/config.yml 
flatpak install flathub org.mozilla.Thunderbird com.slack.Slack com.spotify.Client 	 md.obsidian.Obsidian com.discordapp.Discord com.bitwarden.desktop -y
ls
ls -la
ls -la .ssh/
bash setup-1.sh 
bash setup-1.sh 
ls ~
bash setup-1.sh 
bash setup-1.sh 
xclip -sel clip < ~/.ssh/id_ed25519.pub
bash setup-1.sh 
sudo apt modernize-sources 
sudo cat /etc/apt/sources.list.d/debian.sources 
sudo nano /etc/apt/sources.list.d/debian-backports.sources 
sudo apt update
sudo tailscale up --accept-routes=true
cat setup-1.sh 
cat ~/.config/froggeR/config.yml 
flatpak install flathub org.mozilla.Thunderbird com.slack.Slack com.spotify.Client 	 md.obsidian.Obsidian com.discordapp.Discord com.bitwarden.desktop -y
tailscale status
flatpak install flathub com.nextcloud.desktopclient.nextcloud -y
positron 
positron --headless &
positron &
rsync -azh ~/.config/Positron/ pi5:/home/kyle/t9/dot-backups/Positron/
ssh pi5
cd ~/.local/share/gnome-shell/extensions/
cd
# List all your .config directories with sizes
sudo apt remove evolution -y
du -sh ~/.config/* | sort -hr
rm -rf .config/evolution/
rsync -azh --info=progress2     --exclude='.cache'     --exclude='*.log'     ~/.config/{Positron,quarto-writer,ibus,dconf,pulse,gtk-3.0,gtk-4.0,gnome-session,froggeR,nautilus}     pi5:/home/kyle/t9/config-backups/
ssh pi5 
# Export your current perfect setup
dconf dump / > dconf-settings.ini
rsync -azh dconf-settings.ini pi5:/home/kyle/t9/dot-backups/
nano /mnt/linux-setup/setup-1.sh 
history | tail -n 20
history | tail -n 35
cd /mnt/linux-setup/
nano initial-setup.sh
xclip -sel clip < setup-1.sh 
nano setup-1.sh 
mv setup-1.sh setup.sh 
ls .ssh/
cat initial-setup.sh 
nano initial-setup.sh 
xclip -sel clip < initial-setup.sh 
nano setup.sh 
xclip -sel clip < setup.sh 
ls
sudo reboot
