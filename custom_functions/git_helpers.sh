summarize_diff() {
  local choices=${1:-1}
  local diff="$(git diff --no-color $2 $3)"
  local DIFF_PROMPT="Generate a thorough commit message for all of the following changes. Create a one sentence summary, with bullet points underneath if appropriate:\n\n"

  local prompt="$DIFF_PROMPT\n\n$diff\nCommit message:\n"
  local json_input=$(echo "$prompt" | jq -R -s -c '.')
  local prompt_chars=$(echo -n "$prompt" | wc -c)
  local max_tokens=$((4096 - prompt_chars/4 - 1000))

  local RESPONSE="$(curl -s "https://api.openai.com/v1/completions" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -d @- << EOF
{
  "model": "text-davinci-003",
  "prompt": $json_input,
  "max_tokens": $max_tokens,
  "n": 3,
  "temperature": 0.5
}
EOF
)"
echo $RESPONSE 1>&2

  local summaries=$(echo -n "$RESPONSE" | perl -pe 's/([\x01-\x1f])/sprintf("\\u%04x", ord($1))/eg' | jq -r '.choices | map(.text) | join("---")')
  if [ "$(echo "$summaries" | head -n 1)" = "null" ]; then
    echo "Error: $(echo "$RESPONSE" | jq -r '.error.message')" 1>&2
    return 1
  fi
  echo "$summaries" 1>&2
  echo "$summaries"
}



smart_commit() {
  local choice_count=3
  local choice_arg_regex="^-c[[:digit:]]+$"

  if [[ $1 =~ $choice_arg_regex ]]; then
    choice_count=${1#-c}
    shift
  fi

  # Stage all changes (additions, modifications, and deletions)
  git add --all

  # Generate initial commit messages
  local commit_messages
  commit_messages=$(summarize_diff $choice_count $1 $2)

  local commit_message

  while true; do
    echo "Generated commit messages:"
    local idx=1
    local IFS='---'
    for msg in $commit_messages; do
      echo "$idx. $msg"
      idx=$((idx+1))
    done

    echo -n "Enter the number of the commit message you want to use (or 'r' to regenerate, 'm' for manual entry, 'a' to abort): "
    read -r choice

    case $choice in
      [1-3])
        commit_message=$(echo "$commit_messages" | sed -n "${choice}p")
        ;;
      r|R)
        commit_messages=$(summarize_diff $1 $2)
        continue
        ;;
      m|M)
        echo "Enter your commit message:"
        read -r commit_message
        ;;
      a|A)
        echo "Commit aborted."
        return 1
        ;;
      *)
        echo "Invalid choice. Try again."
        continue
        ;;
    esac

    # If we reach this point, the user has selected a valid commit message
    break
  done

  # Commit with the selected message
  git commit -m "$commit_message"
}

