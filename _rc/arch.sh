add_bin_to_path "$HOME/dev/$USER/bin/"{unix,linux,git,project_management,sessions,desktop}
add_bin_to_path $HOME/dev/$USER/devops/scripts
KEY_DIR=/run/media/$USER/KEY
if [ "$status_shown" != true ] && [ -n "$VIMRUNTIME" ] && [ -n "$TMUX" ] ; then
  status
  export status_shown=true
fi
