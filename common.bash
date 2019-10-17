export LANG=en_CA.UTF-8
export XMLLINT_INDENT="	"

# history settings
export HISTFILESIZE=10000
export HISTSIZE=10000
export HISTCONTROL=ignorespace:ignoredups:erasedups
export PROMPT_COMMAND="history -a; history -r"
shopt -s histappend

shopt -s direxpand 2>/dev/null # not in RHEL6 bash

tabs -4 2>/dev/null || true
alias less="less -x4 -R"

color_black="\[$(tput setaf 0)\]"
color_red="\[$(tput setaf 1)\]"
color_green="\[$(tput setaf 2)\]"
color_yellow="\[$(tput setaf 3)\]"
color_blue="\[$(tput setaf 4)\]"
color_magenta="\[$(tput setaf 5)\]"
color_cyan="\[$(tput setaf 6)\]"
color_white="\[$(tput setaf 7)\]"
reset="\[$(tput sgr0)\]"
bold=
# echo "before _PATH=$_PATH"
_PATH=${_PATH:-${PATH}}
# echo "after _PATH=$_PATH"

COMMON_SETUP=$HOME/common_setup
PATH=$COMMON_SETUP/scripts:$_PATH

if [ -z "$DISPLAY" ]
then
	titleString=
else
	titleString="\[\e]2;\W (\h)\a\]"
fi

PS1="$titleString${color_cyan}\A ${color_green}\u@\h ${color_yellow}\w\n${color_red}\\\$ ${reset}"

alias cgrep="grep -E --exclude-dir='*.svn' --exclude-dir='.metadata' --exclude='*.class' --exclude='*.jar' --exclude='*.war' --exclude='*.ear' --exclude='*.log' --exclude='*.log.*'"
alias disable_move_key_repeat='for k in 25 38 39 40; do xset -r $k; done'

function collatePDF {
	odd="$1"
	even="$2"
	output="$3"
	if [[ -z "$output" ]]
	then
		output=$(echo "$1" | sed -r 's/(.+)_\w+.pdf/\1.pdf/')
	fi
	if [[ -z "$odd" || -z "$even" || -z "$output" || "$output" == "$odd" ]]
	then
		echo "invalid input odd=$odd even=$even output=$output" >&2
		return 1;
	fi
	if [ -e "$output" ]
	then
		echo "file $output exists, not overwriting" >&2
		return 1;
	fi
	echo $output
	pdftk A="$odd" B="$even" shuffle A Bend-1south output "$output"
}

function git_stash_reverse {
	git stash show -p | git apply --reverse
}

function clean_downloads {
	find $HOME/Downloads -mindepth 1 -maxdepth 1 -mtime +90 -exec rm -rf {} \;
}

SSH_ENV="$HOME/.ssh/environment.$HOSTNAME"

function start_agent {
	echo "Initialising new SSH agent..."
	/usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
	echo succeeded
	chmod 600 "${SSH_ENV}"
	. "${SSH_ENV}" > /dev/null
	/usr/bin/ssh-add;
}

# Source SSH settings, if applicable
if [ -z "${DISPLAY}" ]
then
	if [ -f "${SSH_ENV}" ]
	then
		. "${SSH_ENV}" > /dev/null
		#ps ${SSH_AGENT_PID} doesn't work under cywgin
		ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
		start_agent;
	}
	else
		start_agent;
	fi
fi

if [ -r $HOME/.bash.local.$HOSTNAME ]
then
	. $HOME/.bash.local.$HOSTNAME
fi

wine_disassociate() {
	find $HOME/.local/share/applications -name "wine-extension-*" | grep -Ev -e '\b(acsm|azw|azw4|vbs|odm)\b' | xargs rm
}

svn_mv_after() {
	if ! [ -e "$2" ]; then
		echo "non-existent destination, check order" 1>&2
		return
	fi
	if [ -e "$1" ]; then
		echo "source exists, correct" 1>&2
		return
	fi
	mv "$2" "$1"
	svn mv "$1" "$2"
}

zip_summarize() {
	fields=5
	flags=-l
	sort=1
	if [ "$1" == "-l" ]
	then
		shift
		flags='-vl'
		fields=8,9
		sort=2
	fi
	unzip $flags "$1" | tr -s ' ' | cut -d' ' -f$fields | tail -n+4 | sort -k$sort
}

vim_stdin_files() {
	xargs sh -c 'vim "$@" < /dev/tty' vim
}
