# list of default settings to change how macOS functions

# change default screenshot name
defaults write com.apple.screencapture name 'Screenshot'

# change default screenshot type
defaults write com.apple.screencapture type jpg

# change default screenshot location
defaults write com.apple.screencapture location ~/Screenshots

# use touch ID on MacBook instead of sudo in terminal
# sudo nano /etc/pam.d/sudo
# then add:
# auth sufficient pam_tid.so

# don't create the .DS_Store files
defaults write com.apple.desktopservices DSDontWriteNetworkStores true

