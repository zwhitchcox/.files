#!/usr/bin/env bash

addgroup --gid 30000 --system nixbld
for i in $(seq 1 30) ; do \
  adduser --system --no-create-home --uid $((30000 + i)) --gecos "Nix build user $i"  --gid 30000 nixbld$i & \
done && \
wait

user=$1

adduser --gecos "" --disabled-password --shell /bin/bash --uid 1000 $user
usermod -aG sudo $user
chown -R $user:$user /home/$user
touch /home/$HOME/.sudo_as_admin_successful

mkdir -m 0755 /nix
mkdir -m 0755 /etc/nix
echo 'sandbox = false' > /etc/nix/nix.conf
chown -R ${user}:${user} /nix
chown -R ${user}:${user} /etc/nix
