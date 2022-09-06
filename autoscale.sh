#!/bin/bash

sudo dnf update -y
sudo yum update -y

# Install GitLab runner
curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.rpm.sh" | sudo bash
sudo yum install gitlab-runner -y

# Install Docker
dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
dnf install docker-ce --nobest -y
systemctl start docker
systemctl enable docker

#Install docker-machine
base=https://gitlab-docker-machine-downloads.s3.amazonaws.com/v0.16.2-gitlab.11 && curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine   && sudo mv /tmp/docker-machine /usr/local/bin/docker-machine   && chmod +x /usr/local/bin/docker-machine

echo ~/.bashrc <<-EOF 
    export PATH=/usr/local/bin:${PATH}
EOF

