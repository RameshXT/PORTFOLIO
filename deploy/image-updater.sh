#!/bin/bash

# Define the file to modify
FILE="/var/lib/jenkins/workspace/portfolio-ramesh/deploy/deployment.yaml" # Update path if needed

# Replace UPDATE-IMAGE with the new image tag
sed -i "s|UPDATE-IMAGE|rameshxt/portfolio-ramesh:v1.0.0.${BUILD_NUMBER}|g" "$FILE"

# Optionally, echo a message to indicate the replacement was successful
echo "Replaced 'UPDATE-IMAGE' with 'rameshxt/portfolio-ramesh:v1.0.0.${BUILD_NUMBER}' in $FILE"