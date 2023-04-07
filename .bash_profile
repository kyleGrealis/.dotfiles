
[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion
PATH="/usr/local/bin:PATH"

export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin

if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi


eval "$(/usr/local/bin/brew shellenv)"

