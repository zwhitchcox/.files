kill_port_process() {
  kill -9 $(lsof -t -i :$1)
}
