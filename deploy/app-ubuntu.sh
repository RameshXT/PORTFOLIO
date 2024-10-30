#!/bin/bash

# -------[ COLOUR ]-------
GREEN="\e[32m"
BLUE="\e[34m"
RED="\e[31m"
NC="\e[0m"

# -------[ UPDATE SYSTEM PACKAGES ]-------
echo -e "${GREEN}Updating system packages...${NC}"
sudo apt update && sudo apt upgrade -y

# -------[ INSTALL REQUIRED APPLICATIONS ]-------

# -------[ CRON INSTALLATION ]-------
# Check if cron is installed
if ! command -v cron &> /dev/null; then
    echo -e "${GREEN}Cron is not installed. Installing now...${NC}"
    
    # Update the package list and install cron
    sudo apt install -y cron
    
    # Enable and start the cron service
    sudo systemctl enable cron
    sudo systemctl start cron
    sleep 5

    echo -e "${GREEN}Cron installed successfully.${NC}"
else
    echo -e "${BLUE}Cron is already installed.${NC}"
fi

# -------[ CURL INSTALLATION ]-------
# Function to install curl
install_curl() {
    echo "Installing curl..."
    sudo apt install -y curl
}

# Check if curl is installed
if command -v curl >/dev/null 2>&1; then
    echo "${BLUE}curl is already installed.${NC}"
else
    install_curl
    if command -v curl >/dev/null 2>&1; then
        echo "${GREEN}curl has been installed successfully.${NC}"
    else
        echo "${RED}Failed to install curl.${NC}"
        exit 1
    fi
fi

# -------[ GIT INSTALLATION ]-------
if command -v git &> /dev/null; then
    echo -e "${BLUE}Git is already installed.${NC}"
else
    echo -e "${GREEN}Git is not installed. Installing Git...${NC}"
    sudo apt install -y git
    sleep 2
    echo -e "${GREEN}Git is installed.${NC}"
fi

# -------[ JENKINS INSTALLATION ]-------
if systemctl list-unit-files | grep -q jenkins; then
    echo -e "${BLUE}Jenkins is already installed.${NC}"
else
    echo -e "${GREEN}Jenkins is not installed. Installing Jenkins...${NC}"
    
    sudo apt install -y wget
    wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
    sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
    
    sudo apt update
    sudo apt install -y openjdk-17-jdk jenkins
    
    sudo systemctl enable jenkins
    sudo systemctl start jenkins
    sleep 10  # Wait for Jenkins service to start

    echo -e "${GREEN}Jenkins is installed.${NC}"
fi

# -------[ DOCKER INSTALLATION ]-------
if command -v docker &> /dev/null; then
    echo -e "${BLUE}Docker is already installed.${NC}"
else
    echo -e "${GREEN}Docker is not installed. Installing Docker...${NC}"
    
    sudo apt update
    sudo apt install -y docker.io
    
    sudo systemctl start docker
    sudo systemctl enable docker
    sleep 5  # Wait for Docker service to start
    sudo usermod -aG docker $USER
    
    echo -e "${GREEN}Docker installation and configuration is complete.${NC}"
fi

#!/bin/bash

# -------[ COLOUR ]-------
GREEN="\e[32m"
BLUE="\e[34m"
RED="\e[31m"
NC="\e[0m"

# -------[ KUBECTL INSTALLATION ]-------
if command -v kubectl &> /dev/null; then
    echo -e "${BLUE}kubectl is already installed.${NC}"
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
    echo -e "${BLUE}Minikube is already installed.${NC}"
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
        echo -e "${BLUE}Jenkins already has sudo permissions.${NC}"
    fi
else
    echo -e "${RED}Jenkins user not found.${NC}"
fi

# -------[ SET JENKINS SHELL TO /bin/bash ]-------
PASSWD_FILE="/etc/passwd"
if grep -q "^jenkins:.*:/bin/false" "$PASSWD_FILE"; then
    sudo sed -i 's|^jenkins:.*:/bin/false|jenkins:x:992:992:Jenkins Automation Server:/var/lib/jenkins:/bin/bash|' "$PASSWD_FILE"
    echo -e "${GREEN}Jenkins shell changed to /bin/bash.${NC}"
else
    echo -e "${BLUE}Jenkins shell already set to /bin/bash.${NC}"
fi

# -------[ CREATE A FILE FOR JENKINS IP CHANGE ]-------
# Define the file path
FILE_PATH="/home/ubuntu/jenkins-ip.sh"

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

# -------[ CREATE A FILE FOR PORTFORWARD ]-------
# Define the file path
FILE_PATH="/home/ubuntu/portforward.sh"

# Define the content to be written
CONTENT='#!/bin/bash

GREEN="\e[32m"
BLUE="\e[34m"
RED="\e[31m"
NC="\e[0m"

# Port Forwarding
echo "Starting port forwarding..."
kubectl port-forward service/portfolio-service 30050:80 --address 0.0.0.0 > port-forward.log 2>&1 &

# Give it some time to establish the port forwarding
sleep 5

# Check if the port forwarding command is running
if pgrep -f "kubectl port-forward" > /dev/null; then
    echo "${GREEN}Port forwarding established on port 30050${NC}"
    
    # Fetch the public IP of the instance
    public_ip=$(curl -s ifconfig.co)

    # Display the full access URL
    echo "You can access your application at: ${BLUE}http://$public_ip:30050${NC}"
else
    echo "${RED}Failed to establish port forwarding. Check port-forward.log for errors.${NC}"
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
    "@reboot /home/ubuntu/jenkins-ip.sh"
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
    echo -e "${BLUE}No new cron jobs were added; they already exist.${NC}"
fi

# Remove the temporary file
rm "$temp_cron"


# -------[ START MINIKUBE WITH DOCKER GROUP ]-------
echo -e "${GREEN}Adding ubuntu user to docker group...${NC}"
sudo usermod -aG docker ubuntu

echo -e "${GREEN}Switching to docker group and starting Minikube...${NC}"

newgrp docker <<EOF
minikube start
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Minikube started successfully.${NC}"
else
    echo -e "${RED}Failed to start Minikube. Exiting.${NC}"
    exit 1
fi
EOF


# -------[ KUBE CONFIGURATION WITH JENKINS ]-------
# Define source and destination directories
src_kube="/home/ubuntu/.kube"
src_minikube="/home/ubuntu/.minikube"
dest_kube="/var/lib/jenkins/.kube"
dest_minikube="/var/lib/jenkins/.minikube"
config_file="$dest_kube/config"

# Check if the source directories exist
if [ -d "$src_kube" ] && [ -d "$src_minikube" ]; then
    # Copy .kube and .minikube directories to Jenkins' home
    sudo cp -r "$src_kube" "$dest_kube"
    sudo cp -r "$src_minikube" "$dest_minikube"

    # Change ownership of the copied directories to the jenkins user
    sudo chown -R jenkins:jenkins "$dest_kube"
    sudo chown -R jenkins:jenkins "$dest_minikube"

    # Update paths in the config file if it exists
    if [ -f "$config_file" ]; then
        sudo sed -i 's|certificate-authority: /home/ubuntu/.minikube/ca.crt|certificate-authority: /var/lib/jenkins/.minikube/ca.crt|' "$config_file"
        sudo sed -i 's|client-certificate: /home/ubuntu/.minikube/profiles/minikube/client.crt|client-certificate: /var/lib/jenkins/.minikube/profiles/minikube/client.crt|' "$config_file"
        sudo sed -i 's|client-key: /home/ubuntu/.minikube/profiles/minikube/client.key|client-key: /var/lib/jenkins/.minikube/profiles/minikube/client.key|' "$config_file"
    else
        echo "Config file not found at $config_file. Skipping path updates."
    fi
else
    echo "Source directories do not exist. Please check the paths."
    if [ ! -d "$src_kube" ]; then
        echo "Missing: $src_kube"
    fi
    if [ ! -d "$src_minikube" ]; then
        echo "Missing: $src_minikube"
    fi
fi
echo "${GREEN}Kube files have been configured.${NC}"

# -------[ VERSION CHECK FOR APPLICATIONS ]-------
printf "%-12s | %-30s\n" "Tool" "Version / Status"
echo -e "${GREEN}=============================================${NC}"

# Git version
if command -v git &> /dev/null; then
    printf "%-12s | %-30s\n" "Git" "$(git --version)"
else
    printf "%-12s | %-30s\n" "Git" "Not Installed"
fi

# Crond status
if systemctl list-unit-files | grep -q cron; then
    status=$(systemctl is-active cron)
    printf "%-12s | %-30s\n" "Cron" "$status"
else
    printf "%-12s | %-30s\n" "Cron" "Not Installed"
fi

# Curl
if command -v curl > /dev/null; then
    printf "%-12s | %-30s\n" "Curl" "Installed"
else
    printf "%-12s | %-30s\n" "Curl" "Not Installed"
fi

# Jenkins version
if systemctl list-unit-files | grep -q jenkins; then
    printf "%-12s | %-30s\n" "Jenkins" "$(systemctl is-active jenkins)"
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
    kubectl_version=${kubectl_version:-"Unknown Version"}
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
    bar_length=${usage//%/}
    bar=$(printf "%-${bar_length}s" | tr ' ' '=')
    
    echo -e "${GREEN}$source mounted on $mount${NC}"
    echo -e "[${GREEN}${bar//=/▓}${NC} ${usage}]\n"
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
        echo -e "${RED}Failed to retrieve the password.${NC}"
    fi
else
    echo -e "${RED}Jenkins initial admin password file not found!${NC}"
fi
