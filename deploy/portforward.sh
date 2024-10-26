#!/bin/bash

# Port Forwarding
kubectl port-forward service/portfolio-service 30050:80 --address 0.0.0.0 > /dev/null 2>&1 &

# Give it some time to establish the port forwarding
sleep 5

# Finish
echo "Port forwarding established on port 30050"
