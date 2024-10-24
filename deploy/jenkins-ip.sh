#!/bin/bash

# Fetch the instance public IP address
NEW_IP=$(curl -s ifconfig.me)

# Define the path to the Jenkins configuration file
JENKINS_CONFIG="/var/lib/jenkins/jenkins.model.JenkinsLocationConfiguration.xml"

# Check if the configuration file exists
if [ -f "$JENKINS_CONFIG" ]; then
    # Use sed to replace the old IP with the new IP in the jenkinsUrl line
    sudo sed -i "s|<jenkinsUrl>http://[0-9.]*:8080/</jenkinsUrl>|<jenkinsUrl>http://$NEW_IP:8080/</jenkinsUrl>|" "$JENKINS_CONFIG"
    echo "Updated jenkinsUrl to http://$NEW_IP:8080/"
    
    # Restart Jenkins service
    sudo systemctl restart jenkins

    echo "Jenkins has been restarted."
else
    echo "Jenkins configuration file not found: $JENKINS_CONFIG"
fi