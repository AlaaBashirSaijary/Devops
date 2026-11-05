#!/usr/bin/env bash
# One-shot setup for a throw-away online Linux box (Killercoda). Installs Terraform and Ansible, clones the repo.
set -e
sudo apt-get update -qq
sudo apt-get install -y -qq git curl unzip python3-pip gnupg software-properties-common >/dev/null
if ! command -v terraform >/dev/null; then
  curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list >/dev/null
  sudo apt-get update -qq && sudo apt-get install -y -qq terraform >/dev/null
fi
pip install -q --break-system-packages ansible docker requests 2>/dev/null || pip install -q ansible docker requests
ansible-galaxy collection install community.docker >/dev/null
[ -d Devops ] || git clone -q https://github.com/AlaaBashirSaijary/Devops.git
echo "Ready: cd Devops, then follow LAB.md"
