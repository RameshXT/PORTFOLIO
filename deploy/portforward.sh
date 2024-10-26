#! /bin/bash

# Port Forward
kubectl port-forward service/portfolio-service 30050:80 --address 0.0.0.0 &

# finish
echo "port forwarding"