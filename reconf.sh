#!/bin/bash

echo "Fixing GitHub SSH host key verification in Jenkins..."

# Остановить Jenkins (если нужно)
# docker stop jenkins-master

# Добавить host keys
docker exec -u root jenkins-master bash -c "
# Создать backup существующего known_hosts
if [ -f /var/jenkins_home/.ssh/known_hosts ]; then
    cp /var/jenkins_home/.ssh/known_hosts /var/jenkins_home/.ssh/known_hosts.backup
fi

# Добавить GitHub keys
mkdir -p /var/jenkins_home/.ssh
ssh-keyscan -t rsa github.com > /tmp/github_keys
ssh-keyscan -t ed25519 github.com >> /tmp/github_keys
ssh-keyscan -t ecdsa github.com >> /tmp/github_keys

cat /tmp/github_keys >> /var/jenkins_home/.ssh/known_hosts
rm -f /tmp/github_keys

# Настроить права
chown -R jenkins:jenkins /var/jenkins_home/.ssh
chmod 700 /var/jenkins_home/.ssh
chmod 600 /var/jenkins_home/.ssh/known_hosts

echo '=== Added GitHub keys ==='
grep 'github.com' /var/jenkins_home/.ssh/known_hosts
"

# Перезапустить Jenkins
docker restart jenkins-master

echo "✅ Jenkins restarted with GitHub host keys"
echo "📋 Now re-scan your Multibranch pipeline"