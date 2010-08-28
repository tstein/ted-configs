# .zshrc configured for halberd
#######################################

# zsh options. Each group corresponds to a heading in the zshoptions manpage. {{{
# dir opts
setopt autocd chaselinks pushd_silent

# completion opts
setopt autolist autoparamkeys autoparamslash hashlistall listambiguous listpacked listtypes

# expansion and globbing
setopt extended_glob glob glob_dots

# history opts
setopt extendedhistory

# I/O
setopt aliases clobber correct hashcmds hashdirs ignoreeof rmstarsilent normstarwait

# job control
setopt autoresume notify

# prompting
setopt promptpercent

# scripts and functions
setopt cbases functionargzero localoptions multios

# ZLE
setopt nobeep zle
####################################### }}}



# zle configuration. {{{
# The following lines were added by compinstall a very long time ago.
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' matcher-list ''
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:*:kill:*:processes' command 'ps -axco pid,user,command'
zstyle :compinstall filename '/home/ted/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# autoload various functions provided with zsh
autoload -Uz sticky-note url-quote-magic zcalc zed zmv
zle -N self-insert url-quote-magic

# set up colors for prompt
autoload -U colors
colors
for color in RED GREEN BLUE YELLOW MAGENTA CYAN WHITE BLACK; do
    eval local PR_$color='%{$fg[${(L)color}]%}'
done
local PR_NO_COLOR="%{$terminfo[sgr0]%}"

# enable tetris - don't forget to bind it
autoload -Uz tetris
zle -N tetris
####################################### }}}



# Key bindings. {{{
bindkey -e
bindkey TAB expand-or-complete-prefix
bindkey '^K' delete-word
bindkey '^J' backward-delete-word
bindkey '[20~' tetris     # Press F9 to play.

# Can't count on these keys to be consistent. This switch sets the following:
#   <Delete>        :   delete-char
#   <Home>          :   beginning-of-line
#   <End>           :   end-of-line
#   <PageUp>        :   insert-last-word
#   <PageDown>      :   end-of-history
#   ^<LeftArrow>    :   backward-word
#   ^<RightArrow>   :   forward-word
case "$TERM" in
    'xterm'*)
    bindkey '[3~'     delete-char
    bindkey 'OH'      beginning-of-line
    bindkey 'OF'      end-of-line
    bindkey '[5~'     insert-last-word
    bindkey '[6~'     end-of-history
    bindkey '[1;5D'   backward-word
    bindkey '[1;5C'   forward-word
    ;;
    "rxvt"*)
    bindkey '[3~'     delete-char
    bindkey '[7~'     beginning-of-line
    bindkey '[8~'     end-of-line
    bindkey '[5~'     insert-last-word
    bindkey '[6~'     end-of-history
    bindkey 'Od'      backward-word
    bindkey 'Oc'      forward-word
    ;;
    'screen')
    bindkey '[3~'     delete-char
    bindkey '[1~'     beginning-of-line
    bindkey '[4~'     end-of-line
    bindkey '[5~'     insert-last-word
    bindkey '[6~'     end-of-history
    bindkey '[1;5D'   backward-word
    bindkey '[1;5C'   forward-word
    ;;
    'linux')
    bindkey '[3~'     delete-char
    bindkey '[1~'     beginning-of-line
    bindkey '[4~'     end-of-line
    bindkey '[5~'     insert-last-word
    bindkey '[6~'     end-of-history
    # mingetty doesn't distinguish between ^<LeftArrow> and <LeftArrow>.
    ;;
esac
####################################### }}}



# Aliases. {{{
# ... to add functionality.
alias chrome-get-rss='
    CHROME_RSS=0
    for num in `ps axwwo rss,command | grep -P "(google-|)chrome" | grep -v grep | sed "s/^\s*//g" | cut -d " " -f 1`
    do
        CHROME_RSS=$(($num * 1 + $CHROME_RSS))
    done
    print $CHROME_RSS; unset CHROME_RSS'
alias getip='wget -qO - http://www.whatismyip.com/automation/n09230945.asp'
alias sudo='sudo '  # This enables alias, but not function, expansion on the next word.

# ... to use alternative programs, if available.
if [ `whence inotail` ]; then
    alias tail='inotail'
fi

# ... to save keystrokes.
alias -- \-='cd \-'
alias cep='call-embedded-perl'
alias chrome='google-chrome'
alias open='xdg-open'
alias rezsh='source ~/.zshrc'

# ... to enable 'default' options.
alias bc='bc -l'
alias emacs='emacs -nw'
alias fortune='fortune -c'
alias grep='grep --color=auto'
alias ls='ls --color=auto -F'
alias units='units --verbose'

# ... to compensate for me being an idiot.
alias rm='rm -i'
####################################### }}}



# Command functions. {{{
oh() {
    echo "oh $@"
}

update-rc() {
    update-zshrc
    update-vimrc
}

update-zshrc() {
    if [ ! `whence git` ]; then
        print -l "git is required to do this, but it is not in your path.";
        return 1;
    fi
    
    local TMPDIR=`uuidgen`-ted
    pushd
    mkdir ~/$TMPDIR
    cd ~/$TMPDIR
    
    git clone git://github.com/tstein/ted-configs.git
    cp ted-configs/zshrc ~/.zshrc
    
    popd
    rm -rf ~/$TMPDIR

    source ~/.zshrc
    return 0;
}

update-vimrc() {
    rsync -aLze "ssh -p54848" ted@halberd.dyndns.org:~/.vimrc ~/.vimrc
}

call-embedded-perl() {
    local DEBUG_CEP
    if [[ "$1" == "debug" ]]; then
        DEBUG_CEP="TRUE"
        shift
    fi
    
    if [[ $ARGC -eq 0 ]]; then
        print -l "Which script would you like to run?"
        return 0;
    fi
    local SCRIPT="$1"
    shift
    
    if [[ "$DEBUG_CEP" == "TRUE" ]]; then
        perl -ne "print $F if s/#$SCRIPT#//" ~/.zshrc
    else
        perl -ne "print $F if s/#$SCRIPT#//" ~/.zshrc | perl -w \- $@
    fi
}
####################################### }}}



# Embedded Perl scripts. {{{
#
# To create a new script, write it here, with each line prefixed with #NAME#. It will be callable
# with `call-embedded-perl NAME`.

#localinfo#  # {{{
#localinfo#  # TODO: switch from grep -P to perl proper.
#localinfo#  $sysinfo = "";
#localinfo#  $buffer = `uname -s`;
#localinfo#  chomp($buffer);
#localinfo#      $sysinfo .= "Operating system:      $buffer\n";
#localinfo#  if (-e '/etc/issue') {
#localinfo#      $buffer = `head -n 1 /etc/issue`;
#localinfo#      # Arch (at least) puts `clear` in its /etc/issue.
#localinfo#      # This monstrosity fixes that.
#localinfo#      if ($buffer =~ /\x1b\x5b\x48\x1b\x5b\x32\x4a/) {
#localinfo#          $buffer = `head -n 2 /etc/issue | tail -n 1`;
#localinfo#      }
#localinfo#      $buffer =~ s/\s*\\\S+//g;
#localinfo#      chomp($buffer);
#localinfo#      $sysinfo .= "Distro/release:        $buffer\n";
#localinfo#  }
#localinfo#  if (-e '/proc/cpuinfo') {
#localinfo#      $buffer = `grep -P '(?:model name|cpu\\s+:)' /proc/cpuinfo | head -n 1`;
#localinfo#      $buffer =~ s/^(?:model name|cpu)\s*:\s*(.+)/$1/;
#localinfo#      $buffer =~ s/\((?:R|TM)\)/ /gi;
#localinfo#      $buffer =~ s/CPU//;
#localinfo#      $buffer =~ s/\s{2,}/ /g;
#localinfo#      $buffer =~ s/[@\s]*[\d\.]+\s?[GM]Hz$//;
#localinfo#      chomp($buffer);
#localinfo#      $sysinfo .= "Processor:             $buffer\n";
#localinfo#      $buffer = `grep -P '(cpu MHz|clock)' /proc/cpuinfo | head -n 1`;
#localinfo#      $buffer =~ s/^(?:cpu MHz|clock)\s*:\s*(\d+).*/$1/;
#localinfo#      $buffer =~ s/MHz//;
#localinfo#      chomp($buffer);
#localinfo#      $sysinfo .= "Clock speed:           $buffer MHz\n";
#localinfo#      $buffer = `grep 'processor' /proc/cpuinfo | tail -n 1`;
#localinfo#      $buffer =~ s/^processor\s*:\s*(\d+)\s*\n[.\n]*/$1/;
#localinfo#      $buffer = $buffer + 1;
#localinfo#      $sysinfo .= "Count:                 $buffer\n";
#localinfo#  }
#localinfo#  if (-e '/proc/meminfo') {
#localinfo#      $buffer = `grep 'MemTotal' /proc/meminfo`;
#localinfo#      $buffer =~ s/^MemTotal:\s+(\d+).*$/$1/;
#localinfo#      $buffer = int($buffer / 1024);
#localinfo#      $sysinfo .= "Memory:                $buffer MB\n";
#localinfo#      $buffer = `grep 'SwapTotal' /proc/meminfo`;
#localinfo#      $buffer =~ s/^SwapTotal:\s+(\d+).*$/$1/;
#localinfo#      $buffer = int($buffer / 1024);
#localinfo#      $sysinfo .= "Swap:                  $buffer MB\n";
#localinfo#  }
#localinfo#  print $sysinfo;
#localinfo#  # }}}

#rpmstats#   # {{{
#rpmstats#   if (! -e '/bin/rpm') {
#rpmstats#       print("rpm not found. Are you sure this is an rpm-based system?\n");
#rpmstats#       exit(1);
#rpmstats#   }
#rpmstats#   print "Gathering info on installed rpms... This may take a few.\n";
#rpmstats#   @rpms = split(/\n/, `/bin/rpm -qa`);
#rpmstats#   foreach $rpm (@rpms) {
#rpmstats#       if ($rpm =~ /fc(\d{1,2})\.(\w+)$/) {
#rpmstats#           $rel = $1;
#rpmstats#           $arch = $2;
#rpmstats#           $releases{$rel} = () unless ($releases{$rel});
#rpmstats#           push(@{$releases{$rel}}, \$rpm);
#rpmstats#               $arches{$arch} = () unless ($arches{$arch});
#rpmstats#           push(@{$arches{$arch}}, \$rpm);
#rpmstats#       } else {
#rpmstats#           push(@unsortable, \$rpm);
#rpmstats#       }
#rpmstats#   }
#rpmstats#   print("\nFound $#rpms packages.\n");
#rpmstats#   print("By release:\n");
#rpmstats#   foreach $rel (sort {$b <=> $a} keys %releases) {
#rpmstats#       printf("    fc$rel: %d packages\n", $#{$releases{$rel}} + 1);
#rpmstats#   }
#rpmstats#   print("\nBy arch:\n");
#rpmstats#   foreach $arch (sort keys %arches) {
#rpmstats#       printf("    $arch: %d packages\n", $#{$arches{$arch}} + 1);
#rpmstats#   }
#rpmstats#   printf("\n%d packages unsorted.\n", $#unsortable);
#rpmstats#   # }}}
####################################### }}}



# Space expansion: cause a space to expand to certain text given what's already on the line. {{{
typeset -A abbreviations
abbreviations=(
    'df'                'df -hT --total'
    'lame'              'lame -V 0 -q 0 -m j --replaygain-accurate --add-id3v2'
    'ps'                'ps axwwo user,pid,ppid,pcpu,cputime,nice,pmem,rss,lstart=START,stat,tname,command'
    'pacman'            'pacman-color'
    'sudo pacman'       'sudo pacman-color'
    'sudo yum remove'   'sudo yum remove --remove-leaves'
)

magic-abbrev-expand() {
    local MATCH
    LBUFFER=${LBUFFER%%(#m)[_a-zA-Z0-9 ]#}
    LBUFFER+=${abbreviations[$MATCH]:-$MATCH}
    zle self-insert
}

no-magic-abbrev-expand() {
    LBUFFER+=' '
}

zle -N magic-abbrev-expand
zle -N no-magic-abbrev-expand
bindkey " " magic-abbrev-expand
bindkey "^x" no-magic-abbrev-expand
####################################### }}}



# Interface functions. {{{
# Designed to be called on first run, as decided by the presence or absence of a .zlocal.
get-comfy() {
    trap 'trap 2; return 1' 2
    if [[ -f ~/.zlocal ]]; then
        print -l "You have a .zlocal on this machine. If you really intended to run this function,\n
        delete it manually and try again."
        return 1
    fi
    print -l "\nLooks like it's your first time here.\n"
    print -l ".zlocal for "`hostname`" created on `date`" >> ~/.zlocal
    print -l "configuration:\n" >> ~/.zlocal
    call-embedded-perl localinfo | tee -a ~/.zlocal
    sed -i -e 's/.*/# &/' ~/.zlocal
    print >> ~/.zlocal
    print -l "\nWhat color would you like your prompt on this machine to be? Pick one."
    print -n "[red|green|blue|cyan|magenta|yellow|white|black]: "
    local CHOICE=""
    read CHOICE
    case "$CHOICE" in
        'red')
        print -l 'PR_COLOR=$PR_RED\n' >> ~/.zlocal
        ;;
        'green')
        print -l 'PR_COLOR=$PR_GREEN\n' >> ~/.zlocal
        ;;
        'blue')
        print -l 'PR_COLOR=$PR_BLUE\n' >> ~/.zlocal
        ;;
        'cyan')
        print -l 'PR_COLOR=$PR_CYAN\n' >> ~/.zlocal
        ;;
        'magenta')
        print -l 'PR_COLOR=$PR_MAGENTA\n' >> ~/.zlocal
        ;;
        'yellow')
        print -l 'PR_COLOR=$PR_YELLOW\n' >> ~/.zlocal
        ;;
        'white')
        print -l 'PR_COLOR=$PR_WHITE\n' >> ~/.zlocal
        ;;
        'black')
        print -l "Really? If you say so..."
        print -l 'PR_COLOR=$PR_BLACK\n' >> ~/.zlocal
        ;;
        *)
        print -l "You get blue. Set PR_COLOR in .zlocal later if you want anything else."
        ;;
    esac
    print -l
    trap 2
}

# cornmeter is a visual battery meter meant for a prompt. {{{
# This function spits out the meter as it should appear at call time.
drawCornMeter() {
    for var in WIDTH STEP LEVEL CHARGING; do; eval local $var=""; done
    WIDTH=$1
    STEP=$((100.0 / $WIDTH))
    LEVEL=`acpi -b | perl -ne '/(\d{1,3}\%)/; $LVL = $1; $LVL =~ s/\%//; print $LVL;'`
    CHARGING=`acpi -a | perl -ne 'if (/on-line/) { print $1; }'`
    LEVEL=$(($LEVEL * 1.0))
    print -n $PR_WHITE"["
    if (($LEVEL <= 30.0)); then
        print -n $PR_RED
    else
        print -n $PR_YELLOW
    fi
    if (($LEVEL >= 95.0)); then
        print -n $PR_WHITE
    fi
    for (( i = 0; i < $WIDTH; i++ ))
    do
        if (($(($i + 1)) == $WIDTH)); then
            if [ `acpi -a | grep -o on-line` ]; then
                print -n "C"
                continue
            fi
        fi

        if (($LEVEL >= 0.0)); then
            if (($LEVEL <= $(($STEP / 2.0)))); then
                print -n "\-"
            else
                print -n "="
            fi
        else
            print -n " "
        fi
        LEVEL=$(($LEVEL - $STEP)) 
    done
    print -n $PR_WHITE"]"
} # }}}

# If we're in a repo, print some info. Intended for use in a prompt. {{{
# TODO: Switch from precmd_functions to chpwd_functions
rprompt_git_status() {
    local GITBRANCH=""
    git status &> /dev/null
    if (( $? != 128 )); then
        GITBRANCH=$(git symbolic-ref HEAD 2>/dev/null)
        print -n " git:${GITBRANCH#refs/heads/}"
        if [ ! "`git status | grep clean`" ]; then
            print -n "(*)"
        fi
    fi
}

rprompt_hg_status() {
    hg status &> /dev/null
    if (( $? != 255 )); then
        print -n " hg:"
        print -n `hg summary | perl -ne 'if (/^branch: (.*)$/) { print $1; }'`
        if [ ! "`hg summary | grep clean`" ]; then
            print -n "(*)"
        fi
    fi
}
# }}}

# When on a laptop, enable cornmeter.
update_rprompt() {
    RPROMPT=$PR_CYAN'%B[%~'

    if [ `whence git` ]; then
        RPROMPT+=`rprompt_git_status`
    fi

    if [ `whence hg` ]; then
        RPROMPT+=`rprompt_hg_status`
    fi

    RPROMPT+=']%(?..{%?})'

    if [ $AM_LAPTOP ]; then
        if (( $BATT_METER_WIDTH > 0 )); then
            RPROMPT+=`drawCornMeter $BATT_METER_WIDTH`
        else
            RPROMPT+=`drawCornMeter $(($COLUMNS / 10))`
        fi
    fi

    RPROMPT+='%b'
}

# For terms known to support it, print some info to the terminal title.
case "$TERM" in
    xterm|xterm*|screen)
    precmd_update_title() {
        print -Pn "\e]0;%(!.--==.)%n@%m%(!.==--.) (%y)\a"
    }
    preexec_update_title() {
        print -Pn "\e]0;%(!.--==.)%n@%m%(!.==--.) <%30>...>$1%<<> (%y)\a"
    }
    ;;
esac



NOTIFY_COMMAND='notify-send -t $(($NOTIFY_TIMEOUT * 1000)) -i $NOTIFY_ICON "Returned: $LBUFFER"'
NOTIFY_THRESHOLD=0
NOTIFY_TIMEOUT=5
NOTIFY_ICON=~/.face

notify_preexec() {
    NOTIFY_START=`date +%s`
    NOTIFY_START=$(($NOTIFY_START * 1))
    NOTIFY_CMD=$_
}

notify_precmd() {
    NOTIFY_END=`date +%s`
    NOTIFY_END=$(($NOTIFY_END * 1))
    if (( $NOTIFY_END - $NOTIFY_START >= $NOTIFY_THRESHOLD )); then
        eval $NOTIFY_COMMAND
    fi
}
####################################### }}}



# Shell configuration. {{{
# zsh vars
WORDCHARS="${WORDCHARS:s#/#}" # consider / as a word separator

# history-related variables
HISTFILE=~/.zhistfile
HISTSIZE=5000
SAVEHIST=1000000

# default programs
export EDITOR=vim
if [ `whence most` ]; then
    export PAGER=most
fi

# Test for laptoppiness. $AM_LAPTOP will be true if there are batteries detected by acpi.
# TODO: acpi 1.5.1 introduced the possibility of text output from acpi -b when
# no battery is present.
AM_LAPTOP=`whence acpi`
if [ $AM_LAPTOP ]; then
    AM_LAPTOP=`acpi -b`
fi

# If notify-send is available, we can make use of it.
HAVE_NOTIFY=`whence notify-send`

# How wide the RPROMPT battery meter should be - for automatic width, set this to 0.
BATT_METER_WIDTH=0

# better to accidentally deny access than grant it
umask 077

# .zlocal is a file of my creation - contains site-specific anything so I don't have to modify this
# file for every machine. If needed, default values go first so that the source call overwrites
# them.
PR_COLOR=$PR_BLUE
ssh_key_list=()
if test ! -e ~/.zlocal; then
    get-comfy
fi
if test -f ~/.zlocal; then
    source ~/.zlocal
fi
####################################### }}}



# Finally, let's set up our interface. {{{
PROMPT=$PR_COLOR"%B[%n@%m %D{%H:%M}]%(2L.{$SHLVL}.)\%#%b "
PROMPT2=$PR_GREEN'%B%_>%b '
RPROMPT=$PR_CYAN'%B[%~]%(?..{%?})%b' # For reference only. This is clobbered by update_rprompt().
SPROMPT=$PR_MAGENTA'zsh: correct '%R' to '%r'? '$PR_NO_COLOR

precmd_functions=(precmd_update_title notify_precmd update_rprompt)
preexec_functions=(preexec_update_title notify_preexec)

#TODO: Check if we are a login shell. This could hang a script without that.
if [ `whence keychain` ]; then
    keychain -Q -q $ssh_key_list
    source ~/.keychain/${HOST}-sh
fi

####################################### }}}
# ZSH IS GO
#######################################
# vim:filetype=zsh foldmethod=marker autoindent expandtab shiftwidth=4
# Local variables:
# mode: sh
# End:

