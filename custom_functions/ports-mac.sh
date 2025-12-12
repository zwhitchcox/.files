# Show process listening on a port
port() {
  if [[ -z "$1" ]]; then
    echo "usage: port <port>"
    return 1
  fi

  local pid
  pid=$(lsof -t -iTCP:$1 -sTCP:LISTEN)

  if [[ -z "$pid" ]]; then
    echo "nothing listening on port $1"
    return 0
  fi

  echo "PID $pid listening on port $1"
  ps -p $pid -o pid,ppid,user,start,time,command
}

# Kill process listening on a port
killport() {
  if [[ -z "$1" ]]; then
    echo "usage: killport <number>"
    return 1
  fi
  lsof -t -iTCP:$1 -sTCP:LISTEN | xargs -r kill -9
}
