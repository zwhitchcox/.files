summarize_diff() {
  set -e
  local diff="$(git diff --staged --no-color $1 $2 | sed 's/^+//g' | sed 's/^-//g' | sed 's/^ //g' | sed '/^$/d' | sed 's/^/  /g')"

  if [ -z "$(echo "$diff" | sed '/^$/d')" ]; then
    echo "No changes to commit." >&2
    return 1
  fi
  local DIFF_PROMPT="Generate a thorough commit message for all of the following changes. Create a one sentence summary, with bullet points underneath if appropriate:\n\n"

  local prompt="$DIFF_PROMPT\n\n$diff\nCommit message:\n\n"
  local json_input=$(echo "$prompt" | jq -Rsc '.')
  local promp_tokens=$(echo "$json_input" | wc -c)

  local prompt_chars=$(echo -n "$prompt" | wc -c)
  local max_tokens=$((4096 - prompt_chars/4 - 500))
  local data="$(cat <<EOF
{
  "model": "text-davinci-003",
  "prompt": $json_input,
  "max_tokens": $max_tokens,
  "n": 1,
  "temperature": 0.5
}
EOF
)"
  local tmp_file=$(mktemp)


  curl -s "https://api.openai.com/v1/completions" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -d "$data" > "$tmp_file"

  local error=$(cat "$tmp_file" | jq -r '.error')
  cat $tmp_file >&2

# Now you can use the RESPONSE variable with jq without any issues
  if [ "$error" != "null" ]; then
    echo "Error: $error" 1>&2
    return 1
  fi

  local summary="$(cat "$tmp_file" | jq -r '.choices[0].text')"
  echo "$summary"
  set +e
}
smart_commit() {
  # Stage all changes (additions, modifications, and deletions)
  git add --all

  # Generate initial commit message
  local commit_message
  commit_message=$(summarize_diff $1 $2)
  if [ $? -ne 0 ]; then
    return 1
  fi

  # Loop until the user is satisfied with the commit message
  while true; do
    # Create a temporary file to hold the commit message
    local tmp_file=$(mktemp)

    # Write the commit message to the temporary file
    echo "$commit_message" > "$tmp_file"

    # Open the temporary file with Neovim
    nvim "$tmp_file"
    local nvim_exit_status=$?

    # Read the modified commit message from the temporary file
    commit_message=$(cat "$tmp_file")

    # Remove the temporary file
    rm "$tmp_file"

    # If the user saved the commit message, proceed with the commit
    if [ $nvim_exit_status -eq 0 ]; then
      git commit -m "$commit_message"
      break
    else
      echo "Commit aborted. Do you want to:"
      echo "1. Regenerate the commit message"
      echo "2. Manually enter a commit message"
      echo "3. Abort the commit"
      echo -n "Enter your choice (1/2/3): "
      read -r choice

      case $choice in
        1)
          commit_message=$(summarize_diff $1 $2)
          ;;
        2)
          echo "Enter your commit message:"
          read -r commit_message
          ;;
        3)
          echo "Commit aborted."
          break
          ;;
        *)
          echo "Invalid choice. Commit aborted."
          break
          ;;
      esac
    fi
  done
}


