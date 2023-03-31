summarize_diff() {
  set -e
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
    echo "Error: $(echo "$RESPONSE" | jq -r '.error.message')" 1>&2
    return 1
  fi
  echo "$summary"
  set +e
}


smart_commit() {
  echo 'Smart committing...'
  # Stage all changes (additions, modifications, and deletions)
  git add --all

  # Generate initial commit message
  local commit_message
  commit_message=$(summarize_diff $1 $2)
  if [ $? -ne 0 ]; then
    echo "Commit aborted."
    return 1
  fi

  # Loop until the user is satisfied with the commit message
  while true; do
    echo opening editor 1>&2
    # Open editor for the user to approve or modify the commit message
    commit_message=$(echo "$commit_message" | ${EDITOR:-vim} --stdin)
    echo edited 1>&2

    # If the user saved the commit message, proceed with the commit
    if [ $? -eq 0 ]; then
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
          commit_message=$(summarize_diff HEAD~1 HEAD~2)
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
