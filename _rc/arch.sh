add_bin_to_path $HOME/bin/{unix,linux,git,project_management,sessions,desktop}
KEY_DIR=/run/media/$USER/KEY
switch_env $(cat $ENV_FILE)
if [ "$status_shown" != true ] && [ -n "$VIMRUNTIME" ] && [ -n "$TMUX" ] ; then
  export status_shown=true
fi
