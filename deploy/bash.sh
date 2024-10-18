#!/bin/bash

# Define variables for your pod and service
POD_NAME="portfolio"
SERVICE_NAME="portfolio-service"

# Function to set up port forwarding in the background
setup_port_forwarding() {
  echo "Setting up port forwarding on port 30050..."
  nohup kubectl port-forward service/${SERVICE_NAME} 30050:80 --address 0.0.0.0 > port_forward.log 2>&1 &
  disown  # Detach the process from the shell
}

# Function to delete existing deployment and service, but not the default service
cleanup() {
  echo "Deleting existing deployment and custom service..."
  kubectl delete deployment ${POD_NAME} || true
  kubectl delete service ${SERVICE_NAME} || true

  # Check for existing port forwarding processes and kill them
  if pgrep -f "kubectl port-forward"; then
    echo "Killing existing port forwarding..."
    pkill -f "kubectl port-forward"
  fi
}

# Check if Minikube is running
if minikube status | grep -q "Running"; then
  echo "Minikube is running."

  # Clean up existing resources
  cleanup

  # Apply the deployment and service
  echo "Applying deployment and service..."
  kubectl apply -f deployment.yaml
  kubectl apply -f service.yaml

  # Wait for the pod to be ready
  echo "Waiting for pod to be ready..."
  kubectl wait --for=condition=available --timeout=60s deployment/${POD_NAME}

  # Set up port forwarding
  setup_port_forwarding

else
  echo "Minikube is not running. Starting Minikube..."
  
  # Start Minikube
  minikube start

  # Clean up existing resources (if any)
  cleanup

  # Apply the deployment and service
  echo "Applying deployment and service..."
  kubectl apply -f deployment.yaml
  kubectl apply -f service.yaml

  # Wait for the pod to be ready
  echo "Waiting for pod to be ready..."
  kubectl wait --for=condition=available --timeout=60s deployment/${POD_NAME}

  # Set up port forwarding
  setup_port_forwarding
fi

# Optional: Keep the script running to maintain port forwarding
wait