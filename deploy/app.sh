#!/bin/bash

# -------[ UPDATE SYSTEM PACKAGES ]-------
sudo yum update

# -------[ INSTALL REQUIRED APPLICATIONS ]-------

# -------[ GIT INSTALLATION ]-------
if command -v git &> /dev/null
then
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
    
    # Add Jenkins repository and import the key
    sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
    sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
    
    # Install Java (Amazon Corretto 17) and Jenkins
    sudo dnf install java-17-amazon-corretto -y
    sudo yum install jenkins -y
    
    # Enable and start Jenkins service
    sudo systemctl enable jenkins
    sudo systemctl start jenkins

    echo "Jenkins is installed."
fi

# -------[ DOCKER INSTALLATION ]-------
if command -v docker &> /dev/null
then
    echo "Docker is already installed."
else
    echo "Docker is not installed. Installing Docker..."
    
    # Install Docker using amazon-linux-extras and yum
    sudo amazon-linux-extras install docker -y
    sudo yum install -y docker
    
    # Start Docker service
    sudo service docker start
    
    # Add the current user (ec2-user) to the docker group
    sudo usermod -aG docker ec2-user
    
    echo "Docker installation and configuration is complete."
fi

# -------[ MINIKUBE INSTALLATION ]-------
if command -v minikube &> /dev/null
then
    echo "Minikube is already installed."
else
    echo "Minikube is not installed. Installing Minikube..."
    
    # Update yum packages
    sudo yum update -y
    
    # Download Minikube
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    
    # Install Minikube
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
    
    echo "Minikube installation is complete."
fi

# -------[ START MINIKUBE WITH DOCKER DRIVER ]-------
echo "Starting Minikube with Docker driver..."
minikube start --driver=docker &

# Wait for the Minikube process to finish
wait $!
if [ $? -eq 0 ]; then
    echo "Minikube started successfully."

    # Get the latest version of kubectl
    KUBECTL_VERSION=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)
    
    # Download kubectl
    curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
    
    # Make kubectl executable and move it to /usr/local/bin
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
    
    echo "kubectl installation is complete."
else
    echo "Error: Minikube failed to start."
fi

# -------[ ADDING JENKINS USER TO DOCKER GROUP ]-------

# Helper function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Define box dimensions for output formatting
box_width=45
border="="
padding=" "

# Print version information box
printf "%${box_width}s\n" "$border" | tr ' ' "$border"
echo -e "${padding:0:1} Checking Versions $(date '+%Y-%m-%d %H:%M:%S') ${padding:0:1}"
printf "%${box_width}s\n" "$border" | tr ' ' "$border"

# -------[ VERSION CHECK FOR APPLICATIONS ]-------
printf "%-12s | %-30s\n" "Tool" "Version / Status"
printf "%${box_width}s\n" "$border" | tr ' ' "$border"

# Git version check
if command_exists git; then
    printf "%-12s | %-30s\n" "Git" "$(git --version)"
else
    printf "%-12s | %-30s\n" "Git" "Not Installed"
fi

# Java version check
if command_exists java; then
    printf "%-12s | %-30s\n" "Java" "$(java --version 2>&1 | head -n 1)"
else
    printf "%-12s | %-30s\n" "Java" "Not Installed"
fi

# Jenkins version check
if command_exists jenkins; then
    printf "%-12s | %-30s\n" "Jenkins" "$(jenkins --version)"
else
    printf "%-12s | %-30s\n" "Jenkins" "Not Installed"
fi

# Docker version check
if command_exists docker; then
    printf "%-12s | %-30s\n" "Docker" "$(docker --version)"
else
    printf "%-12s | %-30s\n" "Docker" "Not Installed"
fi

# Minikube status check
if command_exists minikube; then
    printf "%-12s | %-30s\n" "Minikube" "$(minikube status | grep -i 'host')"
else
    printf "%-12s | %-30s\n" "Minikube" "Not Installed"
fi

# Print footer for version check
printf "%${box_width}s\n" "$border" | tr ' ' "$border"
echo -e "${padding:0:1} Version check complete. ${padding:0:1}"
printf "%${box_width}s\n" "$border" | tr ' ' "$border"

# -------[ JENKINS INITIAL ADMIN PASSWORD ]-------
GREEN='\033[0;32m'  # Green for success
RED='\033[0;31m'    # Red for error
BLUE='\033[0;34m'   # Blue for headers
NC='\033[0m'        # No Color

# Function to check if Jenkins initial admin password file exists
check_jenkins_password_file() {
    local password_file="/var/lib/jenkins/secrets/initialAdminPassword"
    
    if [[ -f "$password_file" ]]; then
        echo -e "${BLUE}Retrieving Jenkins Initial Admin Password...${NC}"
        local password=$(sudo cat "$password_file")
        echo -e "${GREEN}Initial Admin Password: $password${NC}"
    else
        echo -e "${RED}Error: Jenkins initial admin password file not found!${NC}"
    fi
}

# Execute the function to retrieve Jenkins password
sudo bash -c "$(declare -f check_jenkins_password_file); check_jenkins_password_file"

# -------[ GIVING PERMISSION FOR JENKINS USER /etc/sudoers ]-------
USER="jenkins"

# Check if the user exists in /etc/passwd
if grep -q "^$USER:" /etc/passwd; then
    # Check if the user already has sudo permissions
    if ! sudo grep -q "^$USER " /etc/sudoers; then
        # Use visudo to safely edit the sudoers file
        echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers > /dev/null
        echo "Added $USER to sudoers with no password requirement."
    else
        echo "$USER already has sudo permissions."
    fi
else
    echo "User $USER not found in /etc/passwd."
fi

# Verify the change
if sudo grep -q "^$USER " /etc/sudoers; then
    echo "$USER has been successfully added to sudoers."
else
    echo "Failed to add $USER to sudoers."
fi

# -------[ GIVING COMMAND RUN PERMISSION FOR JENKINS /etc/passwd ]-------
# Define the file to be modified
PASSWD_FILE="/etc/passwd"

# Check if the Jenkins user's shell is already /bin/bash
if grep -q "^jenkins:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:/bin/bash" "$PASSWD_FILE"; then
    echo "Jenkins user shell is already set to /bin/bash."
else
    # Use sed to replace '/bin/false' with '/bin/bash' for the Jenkins user
    sudo sed -i 's|^jenkins:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:/bin/false|jenkins:x:992:992:Jenkins Automation Server:/var/lib/jenkins:/bin/bash|' "$PASSWD_FILE"
    echo "Replaced /bin/false with /bin/bash for the Jenkins user."
fi


# -------[ DISK SPACE CHECK ]-------
disk_data=($(df -h --output=source,pcent,target | tail -n +2))

# Loop through the disk data and display a custom "map"
echo -e "\n==== Disk Space Usage Map ====\n"
for ((i = 0; i < ${#disk_data[@]}; i+=3)); do
    source=${disk_data[i]}    # Filesystem source (e.g., /dev/sda1)
    usage=${disk_data[i+1]}   # Usage percentage (e.g., 42%)
    mount=${disk_data[i+2]}   # Mount point (e.g., /home)

    # Display the map with a unique visual representation
    bar=$(printf "%-${usage//%/}s" | tr ' ' '=')
    
    echo -e "$source mounted on $mount"
    echo -e "[${bar//=/▓} ${usage}]\n"
done
echo "=============================="