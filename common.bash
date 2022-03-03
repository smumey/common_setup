# history settings
HISTFILESIZE=10000
HISTSIZE=10000
HISTCONTROL=ignorespace:ignoredups:erasedups
PROMPT_COMMAND="history -a; history -r"

shopt -s histappend
shopt -s direxpand 2>/dev/null # not in RHEL6 bash

tabs -4 2>/dev/null || true
alias less="less -x4 -R"

function config_prompt {
	local color_black="\[$(tput setaf 0)\]"
	local color_red="\[$(tput setaf 1)\]"
	local color_green="\[$(tput setaf 2)\]"
	local color_yellow="\[$(tput setaf 3)\]"
	local color_blue="\[$(tput setaf 4)\]"
	local color_magenta="\[$(tput setaf 5)\]"
	local color_cyan="\[$(tput setaf 6)\]"
	local color_white="\[$(tput setaf 7)\]"
	local reset="\[$(tput sgr0)\]"
	local titlebar
	case $TERM in
		xterm*|rxvt*)
			title_bar="\[\e]2;\W (\h)\a\]"
			;;
		*)
			title_bar=""
			;;
	esac
	local gitPrompt="\$(__git_ps1 (%s))"
	PS1="$titleString${color_cyan}\A ${color_green}\u@\h ${color_yellow}\w\n${color_red}\\\$ ${reset}"
}
config_prompt

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
