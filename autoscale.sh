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
mv /usr/local/bin/docker-machine /usr/bin/docker-machine

#Register the runner
gitlab-runner register \
   --non-interactive \
   --request-concurrency 10 \
   --name "runners-tan" \
   --url "https://gitlab.com/" \
   --registration-token "GR1348941uPWW7DE4t9jj8zjXomsK" \
   --executor "docker+machine" \
   --tag-list "tanya-scale3" \
   --locked \
   --docker-privileged=false \
   --docker-image="alpine" \
   --machine-machine-driver "azure" \
   --machine-machine-name "tanya2-auto-scale-%s" \
   --machine-machine-options "azure-subscription-id=4dd4ee42-94d3-410c-9fcf-68354fcca1f8" \
   --machine-machine-options "azure-location=uksouth" \
   --machine-machine-options "azure-resource-group=cus-scr-ext" \
   --machine-machine-options "azure-size=Standard_B2s" \
   --machine-machine-options "azure-image=Canonical:0001-com-ubuntu-server-focal:20_04-lts:latest" 
   --machine-machine-options "azure-vnet=cus-scr-ext:script-extension-test-vnet" \
   --machine-machine-options "azure-subnet=default"

#Edit config.toml
sed 's/concurrent = 1/concurrent = 10/' /etc/gitlab-runner/config.toml > tmp.txt && mv tmp.txt /etc/gitlab-runner/config.toml

service gitlab-runner restart
