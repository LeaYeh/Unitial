# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

command -v starship > /dev/null 2>&1 && eval "$(starship init zsh)"

alias francinette=/Users/leayeh/francinette/tester.sh

alias paco=/Users/leayeh/francinette/tester.sh

# GHCR_TOKEN is provided by ~/.zshrc.secrets (sourced below); never hardcode it here
export GHCR_USERNAME=yehya

function open-webui() {
    local persist_dir="$HOME/open-webui"
    local container_name="open-webui"

    if [ "$1" = "stop" ]; then
        # Stop the container if it is running
        if docker ps --filter "name=$container_name" --format "{{.Names}}" | grep -q "^$container_name$"; then
            docker stop $container_name > /dev/null
            echo "$container_name container stopped"
        else
            echo "$container_name container is not running"
        fi
    else
        # Ensure the host directory exists
        if [ ! -d "$persist_dir" ]; then
            if mkdir -p "$persist_dir"; then
                echo "Directory $persist_dir created"
            else
                echo "Failed to create directory $persist_dir"
                return 1
            fi
        fi
        # Start the container if it is not running
        if docker ps --filter "name=$container_name" --format "{{.Names}}" | grep -q "^$container_name$"; then
            port=$(docker port $container_name 8080/tcp | cut -d : -f2)
            echo "$container_name container already running"
            echo "Open WebUI is running on http://localhost:$port"
        elif docker ps -a --filter "name=$container_name" --format "{{.Names}}" | grep -q "^$container_name$"; then
            if docker start $container_name > /dev/null; then
                port=$(docker port $container_name 8080/tcp | cut -d : -f2)
                echo "$container_name container started"
                echo "Open WebUI is now running on http://localhost:$port"
            else
                echo "Failed to start $container_name container"
                return 1
            fi
        else
            if docker run -d -p 3000:8080 -v "$persist_dir":/app/backend/data --name $container_name --restart always ghcr.io/open-webui/open-webui:main > /dev/null; then
                port=$(docker port $container_name 8080/tcp | cut -d : -f2)
                echo "$container_name container created and started"
                echo "Open WebUI is now running on http://localhost:$port"
            else
                echo "Failed to create and start $container_name container"
                return 1
            fi
        fi
    fi
}

function open-webui() {
    local persist_dir="$HOME/open-webui"
    local container_name="open-webui"
    local image_name="ghcr.io/open-webui/open-webui:main"

    # Nested function to handle updates
    function update_container() {
        echo "Checking for updates..."
        # Pull latest image
        if docker pull $image_name > /dev/null; then
            # Compare current container image ID with latest image ID
            local current_image=$(docker inspect --format '{{.Image}}' $container_name)
            local latest_image=$(docker inspect --format '{{.Id}}' $image_name)

            if [ "$current_image" != "$latest_image" ]; then
                echo "Update available. Recreating container..."
                # Stop the current container
                docker stop $container_name > /dev/null
                # Remove the old container
                docker rm $container_name > /dev/null
                # Create and start new container with the latest image
                if docker run -d -p 3000:8080 -v "$persist_dir":/app/backend/data --name $container_name --restart always $image_name > /dev/null; then
                    show_port
                    return 2  # Indicate update was applied
                else
                    echo "Failed to create new container"
                    return 1
                fi
            else
                echo "Container is already up to date"
                return 0
            fi
        else
            echo "Failed to check for updates"
            return 1
        fi
    }

    # Nested function to display the running port
    function show_port() {
        local port=$(docker port $container_name 8080/tcp | cut -d : -f2)
        echo "Open WebUI is running on http://localhost:$port"
    }

    if [ "$1" = "stop" ]; then
        # Stop the container if it is running
        if docker ps --filter "name=$container_name" --format "{{.Names}}" | grep -q "^$container_name$"; then
            docker stop $container_name > /dev/null
            echo "$container_name container stopped"
        else
            echo "$container_name container is not running"
        fi
    elif [ "$1" = "update" ]; then
        if docker ps -a --filter "name=$container_name" --format "{{.Names}}" | grep -q "^$container_name$"; then
            update_container
        else
            echo "Container doesn't exist. Run open-webui first to create it."
        fi
    else
        # Ensure the host directory exists
        if [ ! -d "$persist_dir" ]; then
            if mkdir -p "$persist_dir"; then
                echo "Directory $persist_dir created"
            else
                echo "Failed to create directory $persist_dir"
                return 1
            fi
        fi

        # Start or create the container
        if docker ps --filter "name=$container_name" --format "{{.Names}}" | grep -q "^$container_name$"; then
            echo "$container_name container already running"
            show_port
        elif docker ps -a --filter "name=$container_name" --format "{{.Names}}" | grep -q "^$container_name$"; then
            # Check for updates before starting the existing container
            update_container
            local update_status=$?

            if [ $update_status -eq 2 ]; then
                # Container was already updated and started by update_container
                return 0
            elif [ $update_status -eq 1 ]; then
                echo "Update failed, starting existing container..."
            fi

            # Start the existing container if no update was applied
            if docker start $container_name > /dev/null; then
                echo "$container_name container started"
                show_port
            else
                echo "Failed to start $container_name container"
                return 1
            fi
        else
            echo "Creating new container..."
            if docker run -d -p 3000:8080 -v "$persist_dir":/app/backend/data --name $container_name --restart always $image_name > /dev/null; then
                echo "$container_name container created and started"
                show_port
            else
                echo "Failed to create and start $container_name container"
                return 1
            fi
        fi
    fi
}

export PATH="/opt/homebrew/opt/rustup/bin:$PATH"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/leayeh/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/leayeh/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/leayeh/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/leayeh/Downloads/google-cloud-sdk/completion.zsh.inc'; fi
export PATH="$HOME/.local/bin:$PATH"

#load script
fpath=(~/ $fpath)

#unalias all the alias(es) before set anything
unalias -m "*"

#default charset and language
LANG='en_US.UTF-8'
LC_ALL='en_US.UTF-8'

#set default editor
export EDITOR='vim'

#GPG passphrase input workaround
export GPG_TTY=`tty`

#tmux color issue
alias tmux='\tmux -2'

#uniq unicode issue
alias uniq='LC_ALL=C uniq'

## Completions
autoload -U compinit
compinit -C

## case-insensitive (all),partial-word and then substring completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' \
    'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

###alias###

#ls
alias l='ls -C'
alias ll='ls -lh'
alias la='ls -A'
alias lal='ls -lha'

#grep
alias g='\grep --color=auto'
alias grep='\grep --color=auto'
alias fgrep='\fgrep --color=auto'
alias egrep='\egrep --color=auto'

#network tool
alias p='ping'
alias n='nslookup'
alias d='dig'
alias t='mtr'
alias ssh='ssh -v'

#cd
alias cd..='\cd ..'
alias cd...='\cd ../..'
alias ..='\cd ..'
alias ...='\cd ../..'
alias ....='\cd ../../..'
alias .....='\cd ../../../..'

#other alias
alias c='clear'
alias sudo='\sudo -E'
alias less='\less -R'
alias df='\df -hT'
alias du='\du -h'
alias free='\free -h'
alias wgetncc='wget --no-check-certificate'
alias last='\last | less'
alias tree='\tree -C'
alias optipng='\optipng -o7 -zm1-9 -preserve'

###alias###

source ~/.colorEcho

# color setting
alias ls='\ls -F'

#load script
fpath=(~/ $fpath)

#unalias all the alias(es) before set anything
unalias -m "*"

#default charset and language
LANG='en_US.UTF-8'
LC_ALL='en_US.UTF-8'

#set default editor
export EDITOR='vim'

#GPG passphrase input workaround
export GPG_TTY=`tty`

#tmux color issue
alias tmux='\tmux -2'

#uniq unicode issue
alias uniq='LC_ALL=C uniq'

## Completions
autoload -U compinit
compinit -C

## case-insensitive (all),partial-word and then substring completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' \
    'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

###alias###

#ls
alias l='ls -C'
alias ll='ls -lh'
alias la='ls -A'
alias lal='ls -lha'

#grep
alias g='\grep --color=auto'
alias grep='\grep --color=auto'
alias fgrep='\fgrep --color=auto'
alias egrep='\egrep --color=auto'

#network tool
alias p='ping'
alias n='nslookup'
alias d='dig'
alias t='mtr'
alias ssh='ssh -v'

#cd
alias cd..='\cd ..'
alias cd...='\cd ../..'
alias ..='\cd ..'
alias ...='\cd ../..'
alias ....='\cd ../../..'
alias .....='\cd ../../../..'

#other alias
alias c='clear'
alias sudo='\sudo -E'
alias less='\less -R'
alias df='\df -hT'
alias du='\du -h'
alias free='\free -h'
alias wgetncc='wget --no-check-certificate'
alias last='\last | less'
alias tree='\tree -C'
alias optipng='\optipng -o7 -zm1-9 -preserve'

###alias###

source ~/.colorEcho

# color setting
alias ls='\ls -F'

#load script
fpath=(~/ $fpath)

#unalias all the alias(es) before set anything
unalias -m "*"

#default charset and language
LANG='en_US.UTF-8'
LC_ALL='en_US.UTF-8'

#set default editor
export EDITOR='vim'

#GPG passphrase input workaround
export GPG_TTY=`tty`

#tmux color issue
alias tmux='\tmux -2'

#uniq unicode issue
alias uniq='LC_ALL=C uniq'

## Completions
autoload -U compinit
compinit -C

## case-insensitive (all),partial-word and then substring completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' \
    'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

###alias###

#ls
alias l='ls -C'
alias ll='ls -lh'
alias la='ls -A'
alias lal='ls -lha'

#grep
alias g='\grep --color=auto'
alias grep='\grep --color=auto'
alias fgrep='\fgrep --color=auto'
alias egrep='\egrep --color=auto'

#network tool
alias p='ping'
alias n='nslookup'
alias d='dig'
alias t='mtr'
alias ssh='ssh -v'

#cd
alias cd..='\cd ..'
alias cd...='\cd ../..'
alias ..='\cd ..'
alias ...='\cd ../..'
alias ....='\cd ../../..'
alias .....='\cd ../../../..'

#other alias
alias c='clear'
alias sudo='\sudo -E'
alias less='\less -R'
alias df='\df -hT'
alias du='\du -h'
alias free='\free -h'
alias wgetncc='wget --no-check-certificate'
alias last='\last | less'
alias tree='\tree -C'
alias optipng='\optipng -o7 -zm1-9 -preserve'

###alias###

source ~/.colorEcho

#color setting
alias ls='\ls -F'

#load script
fpath=(~/ $fpath)

#unalias all the alias(es) before set anything
unalias -m "*"

#default charset and language
LANG='en_US.UTF-8'
LC_ALL='en_US.UTF-8'

#set default editor
export EDITOR='vim'

#GPG passphrase input workaround
export GPG_TTY=`tty`

#tmux color issue
alias tmux='\tmux -2'

#uniq unicode issue
alias uniq='LC_ALL=C uniq'

## Completions
autoload -U compinit
compinit -C

## case-insensitive (all),partial-word and then substring completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' \
    'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

###alias###

#ls
alias l='ls -C'
alias ll='ls -lh'
alias la='ls -A'
alias lal='ls -lha'

#grep
alias g='\grep --color=auto'
alias grep='\grep --color=auto'
alias fgrep='\fgrep --color=auto'
alias egrep='\egrep --color=auto'

#network tool
alias p='ping'
alias n='nslookup'
alias d='dig'
alias t='mtr'
alias ssh='ssh -v'

#cd
alias cd..='\cd ..'
alias cd...='\cd ../..'
alias ..='\cd ..'
alias ...='\cd ../..'
alias ....='\cd ../../..'
alias .....='\cd ../../../..'

#other alias
alias c='clear'
alias sudo='\sudo -E'
alias less='\less -R'
alias df='\df -hT'
alias du='\du -h'
alias free='\free -h'
alias wgetncc='wget --no-check-certificate'
alias last='\last | less'
alias tree='\tree -C'
alias optipng='\optipng -o7 -zm1-9 -preserve'

###alias###

source ~/.colorEcho

#color setting
alias ls='\ls -F'

#load script
fpath=(~/ $fpath)

#unalias all the alias(es) before set anything
unalias -m "*"

#default charset and language
LANG='en_US.UTF-8'
LC_ALL='en_US.UTF-8'

#set default editor
export EDITOR='vim'

#GPG passphrase input workaround
export GPG_TTY=`tty`

#tmux color issue
alias tmux='\tmux -2'

#uniq unicode issue
alias uniq='LC_ALL=C uniq'

## Completions
autoload -U compinit
compinit -C

## case-insensitive (all),partial-word and then substring completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' \
    'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

###alias###

#ls
alias l='ls -C'
alias ll='ls -lh'
alias la='ls -A'
alias lal='ls -lha'

#grep
alias g='\grep --color=auto'
alias grep='\grep --color=auto'
alias fgrep='\fgrep --color=auto'
alias egrep='\egrep --color=auto'

#network tool
alias p='ping'
alias n='nslookup'
alias d='dig'
alias t='mtr'
alias ssh='ssh -v'

#cd
alias cd..='\cd ..'
alias cd...='\cd ../..'
alias ..='\cd ..'
alias ...='\cd ../..'
alias ....='\cd ../../..'
alias .....='\cd ../../../..'

#other alias
alias c='clear'
alias sudo='\sudo -E'
alias less='\less -R'
alias df='\df -hT'
alias du='\du -h'
alias free='\free -h'
alias wgetncc='wget --no-check-certificate'
alias last='\last | less'
alias tree='\tree -C'
alias optipng='\optipng -o7 -zm1-9 -preserve'

###alias###

source ~/.colorEcho

#color setting
alias ls='\ls -F'

#load script
fpath=(~/ $fpath)

#unalias all the alias(es) before set anything
unalias -m "*"

#default charset and language
LANG='en_US.UTF-8'
LC_ALL='en_US.UTF-8'

#set default editor
export EDITOR='vim'

#GPG passphrase input workaround
export GPG_TTY=`tty`

#tmux color issue
alias tmux='\tmux -2'

#uniq unicode issue
alias uniq='LC_ALL=C uniq'

## Completions
autoload -U compinit
compinit -C

## case-insensitive (all),partial-word and then substring completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' \
    'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

###alias###

#ls
alias l='ls -C'
alias ll='ls -lh'
alias la='ls -A'
alias lal='ls -lha'

#grep
alias g='\grep --color=auto'
alias grep='\grep --color=auto'
alias fgrep='\fgrep --color=auto'
alias egrep='\egrep --color=auto'

#network tool
alias p='ping'
alias n='nslookup'
alias d='dig'
alias t='mtr'
alias ssh='ssh -v'

#cd
alias cd..='\cd ..'
alias cd...='\cd ../..'
alias ..='\cd ..'
alias ...='\cd ../..'
alias ....='\cd ../../..'
alias .....='\cd ../../../..'

#other alias
alias c='clear'
alias sudo='\sudo -E'
alias less='\less -R'
alias df='\df -hT'
alias du='\du -h'
alias free='\free -h'
alias wgetncc='wget --no-check-certificate'
alias last='\last | less'
alias tree='\tree -C'
alias optipng='\optipng -o7 -zm1-9 -preserve'

###alias###

source ~/.colorEcho

#color setting
alias ls='\ls -F'
command -v npm > /dev/null 2>&1 && export PATH="$(npm root -g | sed s/node_modules/bin/):$PATH"

#load script
fpath=(~/ $fpath)

#unalias all the alias(es) before set anything
unalias -m "*"

#default charset and language
LANG='en_US.UTF-8'
LC_ALL='en_US.UTF-8'

#set default editor
export EDITOR='vim'

#GPG passphrase input workaround
export GPG_TTY=`tty`

#tmux color issue
alias tmux='\tmux -2'

#uniq unicode issue
alias uniq='LC_ALL=C uniq'

## Completions
autoload -U compinit
compinit -C

## case-insensitive (all),partial-word and then substring completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' \
    'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

###alias###

#ls
alias l='ls -C'
alias ll='ls -lh'
alias la='ls -A'
alias lal='ls -lha'

#grep
alias g='\grep --color=auto'
alias grep='\grep --color=auto'
alias fgrep='\fgrep --color=auto'
alias egrep='\egrep --color=auto'

#network tool
alias p='ping'
alias n='nslookup'
alias d='dig'
alias t='mtr'
alias ssh='ssh -v'

#cd
alias cd..='\cd ..'
alias cd...='\cd ../..'
alias ..='\cd ..'
alias ...='\cd ../..'
alias ....='\cd ../../..'
alias .....='\cd ../../../..'

#other alias
alias c='clear'
alias sudo='\sudo -E'
alias less='\less -R'
alias df='\df -hT'
alias du='\du -h'
alias free='\free -h'
alias wgetncc='wget --no-check-certificate'
alias last='\last | less'
alias tree='\tree -C'
alias optipng='\optipng -o7 -zm1-9 -preserve'

###alias###

source ~/.colorEcho

#color setting
alias ls='\ls -F'

#load script
fpath=(~/ $fpath)

#unalias all the alias(es) before set anything
unalias -m "*"

#default charset and language
LANG='en_US.UTF-8'
LC_ALL='en_US.UTF-8'

#set default editor
export EDITOR='vim'

#GPG passphrase input workaround
export GPG_TTY=`tty`

#tmux color issue
alias tmux='\tmux -2'

#uniq unicode issue
alias uniq='LC_ALL=C uniq'

## Completions
autoload -U compinit
compinit -C

## case-insensitive (all),partial-word and then substring completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' \
    'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

###alias###

#ls
alias l='ls -C'
alias ll='ls -lh'
alias la='ls -A'
alias lal='ls -lha'

#grep
alias g='\grep --color=auto'
alias grep='\grep --color=auto'
alias fgrep='\fgrep --color=auto'
alias egrep='\egrep --color=auto'

#network tool
alias p='ping'
alias n='nslookup'
alias d='dig'
alias t='mtr'
alias ssh='ssh -v'

#cd
alias cd..='\cd ..'
alias cd...='\cd ../..'
alias ..='\cd ..'
alias ...='\cd ../..'
alias ....='\cd ../../..'
alias .....='\cd ../../../..'

#other alias
alias c='clear'
alias sudo='\sudo -E'
alias less='\less -R'
alias df='\df -hT'
alias du='\du -h'
alias free='\free -h'
alias wgetncc='wget --no-check-certificate'
alias last='\last | less'
alias tree='\tree -C'
alias optipng='\optipng -o7 -zm1-9 -preserve'

###alias###

source ~/.colorEcho

#color setting
alias ls='\ls -F'

#load script
fpath=(~/ $fpath)

#unalias all the alias(es) before set anything
unalias -m "*"

#default charset and language
LANG='en_US.UTF-8'
LC_ALL='en_US.UTF-8'

#set default editor
export EDITOR='vim'

#GPG passphrase input workaround
export GPG_TTY=`tty`

#tmux color issue
alias tmux='\tmux -2'

#uniq unicode issue
alias uniq='LC_ALL=C uniq'

## Completions
autoload -U compinit
compinit -C

## case-insensitive (all),partial-word and then substring completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' \
    'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

###alias###

#ls
alias l='ls -C'
alias ll='ls -lh'
alias la='ls -A'
alias lal='ls -lha'

#grep
alias g='\grep --color=auto'
alias grep='\grep --color=auto'
alias fgrep='\fgrep --color=auto'
alias egrep='\egrep --color=auto'

#network tool
alias p='ping'
alias n='nslookup'
alias d='dig'
alias t='mtr'
alias ssh='ssh -v'

#cd
alias cd..='\cd ..'
alias cd...='\cd ../..'
alias ..='\cd ..'
alias ...='\cd ../..'
alias ....='\cd ../../..'
alias .....='\cd ../../../..'

#other alias
alias c='clear'
alias sudo='\sudo -E'
alias less='\less -R'
alias df='\df -hT'
alias du='\du -h'
alias free='\free -h'
alias wgetncc='wget --no-check-certificate'
alias last='\last | less'
alias tree='\tree -C'
alias optipng='\optipng -o7 -zm1-9 -preserve'

###alias###

source ~/.colorEcho

#color setting
alias ls='\ls -F'

# Claude account switcher
[[ -f ~/.zshrc.secrets ]] && source ~/.zshrc.secrets

function claude-personal() {
  export ANTHROPIC_AUTH_TOKEN="$CLAUDE_TOKEN_PERSONAL"
  export CLAUDE_CURRENT_ACCOUNT="personal (smile2140@gmail.com)"
  echo "Claude account: $CLAUDE_CURRENT_ACCOUNT"
}

function claude-work() {
  export ANTHROPIC_AUTH_TOKEN="$CLAUDE_TOKEN_WORK"
  export CLAUDE_CURRENT_ACCOUNT="work (office@c-sense.at)"
  echo "Claude account: $CLAUDE_CURRENT_ACCOUNT"
}

function claude-whoami() {
  echo "Claude account: ${CLAUDE_CURRENT_ACCOUNT:-personal (smile2140@gmail.com)}"
}

[[ -n "$CLAUDE_TOKEN_PERSONAL" ]] && export ANTHROPIC_AUTH_TOKEN="$CLAUDE_TOKEN_PERSONAL"
export CLAUDE_CURRENT_ACCOUNT="personal (smile2140@gmail.com)"

# omnara
path=("/Users/leayeh/.omnara/bin" $path)
