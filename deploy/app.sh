#!/bin/bash

# # -------[ CHECK FOR ROOT PRIVILEGES ]-------
# if [ "$EUID" -ne 0 ]; then
#     echo "Please run this script as root or use sudo."
#     exit 1
# fi

# -------[ UPDATE SYSTEM PACKAGES ]-------
echo "Updating system packages..."
sudo yum update -y

# -------[ INSTALL REQUIRED APPLICATIONS ]-------

# -------[ GIT INSTALLATION ]-------
if command -v git &> /dev/null; then
    echo "Git is already installed."
else
    echo "Git is not installed. Installing Git..."
    sudo yum install git -y
    echo "Git is installed."
fi

# -------[ JENKINS INSTALLATION ]-------
if systemctl list-unit-files | grep -q jenkins; then
    echo "Jenkins is already installed."
else
    echo "Jenkins is not installed. Installing Jenkins..."
    
    sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
    sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
    
    sudo dnf install java-17-amazon-corretto -y
    sudo yum install jenkins -y
    
    sudo systemctl enable jenkins
    sudo systemctl start jenkins

    echo "Jenkins is installed."
fi

# -------[ DOCKER INSTALLATION ]-------
if command -v docker &> /dev/null; then
    echo "Docker is already installed."
else
    echo "Docker is not installed. Installing Docker..."
    
    sudo amazon-linux-extras install docker -y
    sudo yum install docker -y
    
    sudo service docker start
    sudo usermod -aG docker ec2-user
    
    echo "Docker installation and configuration is complete."
fi

# -------[ MINIKUBE INSTALLATION ]-------
if command -v minikube &> /dev/null; then
    echo "Minikube is already installed."
else
    echo "Minikube is not installed. Installing Minikube..."
    
    sudo yum update -y
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
    echo "Minikube installation is complete."
fi

# -------[ KUBECTL INSTALLATION ]-------
KUBECTL_VERSION=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)

if curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"; then
    echo "kubectl downloaded successfully."
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
    echo "kubectl installed successfully."
else
    echo "Failed to download kubectl. Exiting."
    exit 1
fi

# -------[ ADD USER TO DOCKER GROUP AND APPLY CHANGES ]-------
sudo usermod -aG docker $USER
newgrp docker
echo "User has been added to the docker group."

# -------[ START MINIKUBE WITH DOCKER DRIVER ]-------
echo "Starting Minikube..."
minikube start
if [ $? -eq 0 ]; then
    echo "Minikube started successfully."
    while true; do
        STATUS=$(minikube status --format='{{.Host}}')
        if [ "$STATUS" == "Running" ]; then
            echo "Minikube is running."
            break
        else
            echo "Minikube status: $STATUS. Retrying in 5 seconds..."
            sleep 5
        fi
    done
else
    echo "Failed to start Minikube. Exiting."
    exit 1
fi

# -------[ ADDING JENKINS USER TO DOCKER GROUP ]-------
if grep -q "^jenkins:" /etc/passwd; then
    if ! sudo grep -q "^jenkins " /etc/sudoers; then
        echo "jenkins ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers > /dev/null
        echo "Added Jenkins to sudoers."
    else
        echo "Jenkins already has sudo permissions."
    fi
else
    echo "Jenkins user not found."
fi

# -------[ SET JENKINS SHELL TO /bin/bash ]-------
PASSWD_FILE="/etc/passwd"
if grep -q "^jenkins:.*:/bin/false" "$PASSWD_FILE"; then
    sudo sed -i 's|^jenkins:.*:/bin/false|jenkins:x:992:992:Jenkins Automation Server:/var/lib/jenkins:/bin/bash|' "$PASSWD_FILE"
    echo "Jenkins shell changed to /bin/bash."
else
    echo "Jenkins shell already set to /bin/bash."
fi

# -------[ VERSION CHECK FOR APPLICATIONS ]-------
printf "%-12s | %-30s\n" "Tool" "Version / Status"
echo "============================================="
# Git version
if command -v git &> /dev/null; then
    printf "%-12s | %-30s\n" "Git" "$(git --version)"
else
    printf "%-12s | %-30s\n" "Git" "Not Installed"
fi
# Java version
if command -v java &> /dev/null; then
    printf "%-12s | %-30s\n" "Java" "$(java --version 2>&1 | head -n 1)"
else
    printf "%-12s | %-30s\n" "Java" "Not Installed"
fi
# Jenkins version
if command -v jenkins &> /dev/null; then
    printf "%-12s | %-30s\n" "Jenkins" "$(jenkins --version)"
else
    printf "%-12s | %-30s\n" "Jenkins" "Not Installed"
fi
# Docker version
if command -v docker &> /dev/null; then
    printf "%-12s | %-30s\n" "Docker" "$(docker --version)"
else
    printf "%-12s | %-30s\n" "Docker" "Not Installed"
fi
# Minikube status
if command -v minikube &> /dev/null; then
    printf "%-12s | %-30s\n" "Minikube" "$(minikube status | grep -i 'host')"
else
    printf "%-12s | %-30s\n" "Minikube" "Not Installed"
fi

echo "============================================="
echo "Version check complete."

# -------[ DISK SPACE CHECK ]-------
disk_data=($(df -h --output=source,pcent,target | tail -n +2))
echo -e "\n==== Disk Space Usage Map ====\n"
for ((i = 0; i < ${#disk_data[@]}; i+=3)); do
    source=${disk_data[i]}
    usage=${disk_data[i+1]}
    mount=${disk_data[i+2]}
    bar=$(printf "%-${usage//%/}s" | tr ' ' '=')
    echo -e "$source mounted on $mount"
    echo -e "[${bar//=/▓} ${usage}]\n"
done
echo "=============================="

# -------[ JENKINS INITIAL ADMIN PASSWORD ]-------
JENKINS_PASSWORD_FILE="/var/lib/jenkins/secrets/initialAdminPassword"
if [[ -f "$JENKINS_PASSWORD_FILE" ]]; then
    echo "Retrieving Jenkins Initial Admin Password..."
    sudo cat "$JENKINS_PASSWORD_FILE"
else
    echo "Jenkins initial admin password file not found!"
fi