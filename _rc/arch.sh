add_bin_to_path $HOME/bin/{unix,linux,git,project_management,sessions,desktop}
KEY_DIR=/run/media/$USER/KEY
eval `get_env`
if [ "$status_shown" != true ] && [ -n "$VIMRUNTIME" ] && [ -n "$TMUX" ] ; then
  status
  export status_shown=true
fi

