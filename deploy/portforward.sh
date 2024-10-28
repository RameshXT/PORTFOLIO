#!/bin/bash

GREEN="\e[32m"
BLUE="\e[34m"
RED="\e[31m"
NC="\e[0m"

echo "Starting port forwarding..."
kubectl port-forward service/portfolio-service 30050:80 --address 0.0.0.0 > port-forward.log 2>&1 &

sleep 5

# Check if the port forwarding command is running
if pgrep -f "kubectl port-forward" > /dev/null; then
    echo "${GREEN}Port forwarding established on port 30050${NC}"
    
    public_ip=$(curl -s ifconfig.co)

    echo "You can access your application at: ${BLUE}http://$public_ip:30050${NC}"
else
    echo "${RED}Failed to establish port forwarding. Check port-forward.log for errors.${NC}"
fi