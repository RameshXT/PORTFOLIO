#!/bin/bash

# -------[ COLOUR ]-------
GREEN="\e[32m"
NC="\e[0m"

# -------[ UPDATE SYSTEM PACKAGES ]-------
echo -e "${GREEN}Updating system packages...${NC}"
sudo yum update -y

# -------[ INSTALL REQUIRED APPLICATIONS ]-------

# -------[ CROND INSTALLATION ]-------
# Check if crond is installed
if ! command -v crond &> /dev/null; then
    echo -e "${GREEN}Cron is not installed. Installing now...${NC}"
    
    # Update the package list and install cronie
    sudo yum install cronie -y
    
    # Enable and start the crond service
    sudo systemctl enable crond
    sudo systemctl start crond
    sleep 5

    echo -e "${GREEN}Cron installed successfully.${NC}"
else
    echo -e "${GREEN}Cron is already installed.${NC}"
fi



# -------[ GIT INSTALLATION ]-------
if command -v git &> /dev/null; then
    echo -e "${GREEN}Git is already installed.${NC}"
else
    echo -e "${GREEN}Git is not installed. Installing Git...${NC}"
    sudo yum install git -y
    sleep 2
    echo -e "${GREEN}Git is installed.${NC}"
fi


# -------[ JENKINS INSTALLATION ]-------
if systemctl list-unit-files | grep -q jenkins; then
    echo -e "${GREEN}Jenkins is already installed.${NC}"
else
    echo -e "${GREEN}Jenkins is not installed. Installing Jenkins...${NC}"
    
    sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
    sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
    
    sudo dnf install java-17-amazon-corretto -y
    sudo yum install jenkins -y
    
    sudo systemctl enable jenkins
    sudo systemctl start jenkins
    sleep 10  # Wait for Jenkins service to start

    echo -e "${GREEN}Jenkins is installed.${NC}"
fi


# -------[ DOCKER INSTALLATION ]-------
if command -v docker &> /dev/null; then
    echo -e "${GREEN}Docker is already installed.${NC}"
else
    echo -e "${GREEN}Docker is not installed. Installing Docker...${NC}"
    
    sudo amazon-linux-extras install docker -y
    sudo yum install docker -y
    
    sudo service docker start
    sleep 5  # Wait for Docker service to start
    sudo usermod -aG docker ec2-user
    
    echo -e "${GREEN}Docker installation and configuration is complete.${NC}"
fi


# -------[ KUBECTL INSTALLATION ]-------
if command -v kubectl &> /dev/null; then
    echo -e "${GREEN}kubectl is already installed.${NC}"
else
    echo -e "${GREEN}kubectl is not installed. Installing kubectl...${NC}"
    
    curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"

    chmod +x ./kubectl
    sudo mv ./kubectl /usr/local/bin/kubectl
    echo -e "${GREEN}kubectl installed successfully.${NC}"
    kubectl version --client
fi


# -------[ MINIKUBE INSTALLATION ]-------
if command -v minikube &> /dev/null; then
    echo -e "${GREEN}Minikube is already installed.${NC}"
else
    echo -e "${GREEN}Minikube is not installed. Installing Minikube...${NC}"
    
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    chmod +x minikube-linux-amd64
    sudo mv minikube-linux-amd64 /usr/local/bin/minikube
    echo -e "${GREEN}Minikube installation is complete.${NC}"
fi


# -------[ CONFIGURATIONS AND PERMISSIONS ]-------


# -------[ ADDING SUDO PERMISSION FOR JENKINS ]-------
if grep -q "^jenkins:" /etc/passwd; then
    if ! sudo grep -q "^jenkins " /etc/sudoers; then
        echo -e "jenkins ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers > /dev/null
        echo -e "${GREEN}Added Jenkins to sudoers.${NC}"
    else
        echo -e "${GREEN}Jenkins already has sudo permissions.${NC}"
    fi
else
    echo -e "${GREEN}Jenkins user not found.${NC}"
fi


# -------[ SET JENKINS SHELL TO /bin/bash ]-------
PASSWD_FILE="/etc/passwd"
if grep -q "^jenkins:.*:/bin/false" "$PASSWD_FILE"; then
    sudo sed -i 's|^jenkins:.*:/bin/false|jenkins:x:992:992:Jenkins Automation Server:/var/lib/jenkins:/bin/bash|' "$PASSWD_FILE"
    echo -e "${GREEN}Jenkins shell changed to /bin/bash.${NC}"
else
    echo -e "${GREEN}Jenkins shell already set to /bin/bash.${NC}"
fi



# -------[ CREATE A FILE FOR JENKINS IP CHANGE ]-------

# Define the file path
FILE_PATH="/home/ec2-user/jenkins-ip.sh"

# Define the content to be written
CONTENT='#!/bin/bash

# Fetch the instance public IP address
NEW_IP=$(curl -s ifconfig.me)

# Define the path to the Jenkins configuration file
JENKINS_CONFIG="/var/lib/jenkins/jenkins.model.JenkinsLocationConfiguration.xml"

# Check if the configuration file exists
if [ -f "$JENKINS_CONFIG" ]; then
    # Use sed to replace the old IP with the new IP in the jenkinsUrl line
    sudo sed -i "s|<jenkinsUrl>http://[0-9.]*:8080/</jenkinsUrl>|<jenkinsUrl>http://$NEW_IP:8080/</jenkinsUrl>|" "$JENKINS_CONFIG"
    echo -e "${GREEN}Updated jenkinsUrl to http://$NEW_IP:8080/${NC}"
    
    # Restart Jenkins service
    sudo systemctl restart jenkins

    echo -e "${GREEN}Jenkins has been restarted.${NC}"
else
    echo -e "${GREEN}Jenkins configuration file not found: $JENKINS_CONFIG${NC}"
fi'

# Create the file and write the content
echo "$CONTENT" > "$FILE_PATH"

# Make the file executable
chmod +x "$FILE_PATH"

echo -e "${GREEN}File created at $FILE_PATH with executable permissions.${NC}"


# -------[ ADDING STARTUP COMMANDS ]-------
# Temporary file to hold current crontab
temp_cron=$(mktemp)

# Get current crontab and save to temporary file
crontab -l > "$temp_cron"

# Define the new cron jobs
new_jobs=(
    "@reboot /usr/local/bin/minikube start"
    "@reboot /home/ec2-user/jenkins-ip.sh"
    "@reboot nohup kubectl port-forward service/portfolio-service 30050:80 --address 0.0.0.0 > ~/workspace/port-forward.log 2>&1 &"
)

# Flag to check if any jobs were added
jobs_added=false

# Check if each job is already present in the crontab
for job in "${new_jobs[@]}"; do
    if ! grep -Fxq "$job" "$temp_cron"; then
        echo "$job" >> "$temp_cron"
        jobs_added=true
    fi
done

# Install the new crontab from the temporary file if jobs were added
if [ "$jobs_added" = true ]; then
    crontab "$temp_cron"
    echo -e "${GREEN}New cron jobs added successfully.${NC}"
else
    echo -e "${YELLOW}No new cron jobs were added; they already exist.${NC}"
fi

# Remove the temporary file
rm "$temp_cron"


# -------[ START MINIKUBE WITH DOCKER GROUP ]-------
echo -e "${GREEN}Switching to docker group and starting Minikube...${NC}"

newgrp docker <<EOF
minikube start
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Minikube started successfully.${NC}"
else
    echo -e "${GREEN}Failed to start Minikube. Exiting.${NC}"
    exit 1
fi
EOF

# -------[ CONTINUE WITH THE REST OF YOUR SCRIPT BELOW ]-------



# -------[ VERSION CHECK FOR APPLICATIONS ]-------
printf "%-12s | %-30s\n" "Tool" "Version / Status"
echo -e "${GREEN}=============================================${NC}"
# Git version
if command -v git &> /dev/null; then
    printf "%-12s | %-30s\n" "Git" "$(git --version)"
else
    printf "%-12s | %-30s\n" "Git" "Not Installed"
fi

# Jenkins version
if systemctl list-unit-files | grep -q jenkins; then
    printf "%-12s | %-30s\n" "Jenkins" "$(systemctl status jenkins | grep 'Active:' | awk '{print $2}')"
else
    printf "%-12s | %-30s\n" "Jenkins" "Not Installed"
fi

# Docker version
if command -v docker &> /dev/null; then
    printf "%-12s | %-30s\n" "Docker" "$(docker --version)"
else
    printf "%-12s | %-30s\n" "Docker" "Not Installed"
fi

# kubectl version
if command -v kubectl &> /dev/null; then
    kubectl_version=$(kubectl version --client 2>/dev/null | grep 'Client Version' | awk '{print $3}' | tr -d 'v')
    if [ -z "$kubectl_version" ]; then
        kubectl_version="Not Installed"
    fi
    printf "%-12s | %-30s\n" "kubectl" "$kubectl_version"
else
    printf "%-12s | %-30s\n" "kubectl" "Not Installed"
fi

# Minikube version
if command -v minikube &> /dev/null; then
    minikube_version=$(minikube version --short 2>/dev/null)
    printf "%-12s | %-30s\n" "Minikube" "${minikube_version:-Not Installed}"
else
    printf "%-12s | %-30s\n" "Minikube" "Not Installed"
fi
echo -e "${GREEN}=============================================${NC}"
echo -e "${GREEN}Setup complete!${NC}"


# -------[ DISK SPACE CHECK ]-------
disk_data=($(df -h --output=source,pcent,target | tail -n +2))
echo -e "${GREEN}\n==== Disk Space Usage Map ====\n${NC}"
for ((i = 0; i < ${#disk_data[@]}; i+=3)); do
    source=${disk_data[i]}
    usage=${disk_data[i+1]}
    mount=${disk_data[i+2]}
    bar_length=${usage//%/}  # Extract the percentage as an integer
    bar=$(printf "%-${bar_length}s" | tr ' ' '=')  # Create a bar of '=' characters
    
    echo -e "${GREEN}$source mounted on $mount${NC}"
    echo -e "[${GREEN}${bar//=/▓}${NC} ${usage}]\n"  # Display the bar in green
done
echo -e "${GREEN}==============================${NC}"



# -------[ JENKINS INITIAL ADMIN PASSWORD ]-------
JENKINS_PASSWORD_FILE="/var/lib/jenkins/secrets/initialAdminPassword"
TEMP_PASSWORD_FILE="/tmp/jenkins_password.txt"

# Check if the password file exists and fetch it using sudo
if sudo test -f "$JENKINS_PASSWORD_FILE"; then
    echo -e "${GREEN}Retrieving Jenkins Initial Admin Password...${NC}"
    
    # Create a temporary file with the password
    sudo cat "$JENKINS_PASSWORD_FILE" > "$TEMP_PASSWORD_FILE"
    
    # Check if the temporary file was created successfully
    if [[ -f "$TEMP_PASSWORD_FILE" ]]; then
        echo -e "${GREEN}Password retrieved successfully:${NC}"
        cat "$TEMP_PASSWORD_FILE"
        # Optionally, remove the temporary file afterward
        rm -f "$TEMP_PASSWORD_FILE"
    else
        echo -e "${GREEN}Failed to retrieve the password.${NC}"
    fi
else
    echo -e "${GREEN}Jenkins initial admin password file not found!${NC}"
fi



# minikube start
# sudo cp -r /home/ec2-user/.kube /var/lib/jenkins/
# sudo cp -r /home/ec2-user/.minikube /var/lib/jenkins/
# sudo chown -R jenkins:jenkins /var/lib/jenkins/.kube
# sudo chown -R jenkins:jenkins /var/lib/jenkins/.minikube
# sudo nano /var/lib/jenkins/.kube/config  # Update paths in this file
# sudo -u jenkins kubectl get nodes
# sudo systemctl restart jenkins  # If needed
