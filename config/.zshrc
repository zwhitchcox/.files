export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(
nvm
colored-man-pages
command-not-found
git
git-extras
node
z
direnv
)

# Export nvm completion settings for lukechilds/zsh-nvm plugin
# Note: This must be exported before the plugin is bundled
export NVM_DIR=${HOME}/.nvm
export NVM_COMPLETION=true

source $ZSH/oh-my-zsh.sh

# Bundle zsh plugins via antibody
alias update-antibody='antibody bundle < $HOME/.zsh_plugins.txt > $HOME/.zsh_plugins.sh'
# List out all globally installed npm packages
alias list-npm-globals='npm list -g --depth=0'
# use neovim instead of vim
alias vim='nvim'
# checkout branch using fzf
alias gcob='git branch | fzf | xargs git checkout'
# open vim config from anywhere
alias vimrc='vim ${HOME}/.config/nvim/init.vim'
# cat -> bat
alias cat='bat'
# colored ls output
alias ls='ls -al --color'
# copy to clipboard
alias copy='xclip -sel clip'

# DIRCOLORS (MacOS)
export CLICOLOR=1

# FZF
export FZF_DEFAULT_COMMAND="rg --files --hidden --glob '!.git'"
export FZF_DEFAULT_OPTS="--height=40% --layout=reverse --border --margin=1 --padding=1"

# PATH
# export PATH=${PATH}:/usr/local/go/bin
# export PATH=${PATH}:${HOME}/go/bin

export BAT_THEME="gruvbox-dark"

[ -f $HOME.rc.sh ] && source $HOME/.rc.sh
[ -f $HOME/local.rc.sh ] && source $HOME/local.rc.sh


export LUA_PATH="/usr/share/lua/5.4/?.lua;/usr/share/lua/5.4/?/init.lua;$HOME/.luarocks/share/lua/5.4/?.lua;$HOME/.luarocks/share/lua/5.4/?/init.lua;$HOME/.local/share/lua/5.4/?.lua;$HOME/.local/share/lua/5.4/?/init.lua;$LUA_PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# better pacman
pm() {
  local package="$1"
  shift
  if ! sudo pacman -S --noconfirm "$package" "$@"; then
    echo "Package '$package' not found. Searching for similar packages..."
    sudo pacman -Ss "$package"
  fi
}
export DIRENV_LOG_FORMAT=

export FLYCTL_INSTALL="/home/zwhitchcox/.fly"
if [ ! "$PATH" = "${PATH/$FLYCTL_INSTALL\/bin:/}" ]; then
  export PATH="${PATH/$FLYCTL_INSTALL\/bin:/}"
fi

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/zwhitchcox/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/zwhitchcox/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/home/zwhitchcox/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/zwhitchcox/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


activate_emscripten() {
  if [ -f "$HOME/emsdk/emsdk_env.sh" ]; then
    export EMSDK_QUIET=1
    source "$HOME/emsdk/emsdk_env.sh"
  else
    echo "Emscripten not found"
  fi
}

summarize_diff() {
  local diff="$(git diff --no-color $1 $2 | sed 's/^+//g' | sed 's/^-//g' | sed 's/^ //g' | sed '/^$/d' | sed 's/^/  /g')"
  local DIFF_PROMPT="Generate a thorough commit message for all of the following changes. Create a one sentence summary, with bullet points underneath if appropriate:\n\n"

  local prompt="$DIFF_PROMPT\n\n$diff\nCommit message:\n"
  local json_input=$(echo "$prompt" | jq -R -s -c '.')
  local promp_tokens=$(echo "$json_input" | wc -c)

  local prompt_chars=$(echo -n "$prompt" | wc -c)
  local max_tokens=$((4096 - prompt_chars/4 - 500))

  local RESPONSE="$(curl -s "https://api.openai.com/v1/completions" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -d @- << EOF
{
  "model": "text-davinci-003",
  "prompt": $json_input,
  "max_tokens": $max_tokens,
  "n": 1,
  "temperature": 0.5
}
EOF
)"


  local summary="$(echo -n "$RESPONSE" | perl -pe 's/([\x01-\x1f])/sprintf("\\u%04x", ord($1))/eg' | jq -r '.choices[0].text')"
  if [ "$summary" = "null" ]; then
    echo "Error: $(echo "$RESPONSE" | jq -r '.error.message')"
    return 1
  fi
  echo "$summary"
  echo "$summary" | tee | copy
}
