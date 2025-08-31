#!/bin/bash
# cronjob to fix disk space issues on the k3s node
# place this script in /usr/local/bin/k3s_cleanup.sh and make it executable
# add a cronjob like this to run it weekly:
# 0 3 * * 0 /usr/local/bin/k3s_cleanup.sh >> /var/log/k3s_cleanup.log 2>&1
set -e

echo "==> Removing stopped containers..."
sudo k3s crictl ps -a | grep -E 'Exited|Created' | awk '{print $1}' | xargs -r sudo k3s crictl rm

echo "==> Removing old pod sandboxes..."
sudo k3s crictl pods -a | grep -E 'NotReady|Exited|Unknown' | awk '{print $1}' | xargs -r sudo k3s crictl rmp

echo "==> Removing unused container images..."
sudo k3s crictl images -q | xargs -r -n 50 sudo k3s crictl rmi || true

echo "==> Running containerd garbage collection..."
sudo k3s ctr -n k8s.io images prune || true

echo "==> Compaction of k3s server DB (etcd/SQLite)..."
if [ -d "/var/lib/rancher/k3s/server/db" ]; then
    sudo k3s etcd-snapshot save
    sudo k3s etcd-snapshot prune
fi

echo "==> Cleaning old systemd journal logs (7 days retention)..."
sudo journalctl --vacuum-time=7d

echo "==> Cleanup done!"
