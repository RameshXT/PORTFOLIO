#!/bin/bash

# Port Forwarding
echo "Starting port forwarding..."
kubectl port-forward service/portfolio-service 30050:80 --address 0.0.0.0 > port-forward.log 2>&1 &

# Give it some time to establish the port forwarding
sleep 5

# Check if the port forwarding command is running
if pgrep -f "kubectl port-forward" > /dev/null; then
    echo "Port forwarding established on port 30050"
else
    echo "Failed to establish port forwarding. Check port-forward.log for errors."
fi