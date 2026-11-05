#!/usr/bin/env bash
# Installs the tools that are not available as devcontainer features: kind and Ansible.
set -e
curl -fsSLo /tmp/kind https://kind.sigs.k8s.io/dl/v0.23.0/kind-linux-amd64
sudo install /tmp/kind /usr/local/bin/kind
pip install --user -q ansible docker requests
~/.local/bin/ansible-galaxy collection install community.docker
echo "Ready. Open LAB.md and follow the steps."
