#!/bin/bash

# Get the new image name from an argument
NEW_IMAGE_NAME=${1}

# Path to your deployment file
DEPLOYMENT_FILE="/var/lib/jenkins/workspace/portfolio-ramesh/deploy/deployment.yaml"

# Update the deployment file with the new image name
sed -i "s|image: .*|image: ${NEW_IMAGE_NAME}|g" "${DEPLOYMENT_FILE}"

echo "Deployment file updated with new image name: ${NEW_IMAGE_NAME}"
