#!/bin/bash

GREEN="\e[32m"
SKYBLUE="\e[32m"
RED="\e[31m"
NC="\e[0m"

echo -e "Starting port forwarding..."
kubectl port-forward service/portfolio-service 30050:80 --address 0.0.0.0 > port-forward.log 2>&1 &

sleep 5

# Check if the port forwarding command is running
if pgrep -f "kubectl port-forward" > /dev/null; then
    echo -e "${GREEN}Port forwarding established on port 30050${NC}"

    public_ip=$(curl -s https://ipinfo.io/ip)

    echo -e "You can access your application at: ${SKYBLUE}http://$public_ip:30050${NC}"
else
    echo -e "${RED}Failed to establish port forwarding. Check port-forward.log for errors.${NC}"
fi