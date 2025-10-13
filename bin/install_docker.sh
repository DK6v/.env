#!/bin/bash

# Script to install Docker on Ubuntu
set -e

echo "=== Docker Installation Script ==="

# Function to check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        echo "This script should not be run as root. Please run as regular user."
        exit 1
    fi
}

# Function to check Ubuntu version
check_ubuntu() {
    if ! command -v lsb_release &> /dev/null; then
        echo "lsb_release command not found. Please install lsb-release package first."
        exit 1
    fi
    
    if [[ $(lsb_release -is) != "Ubuntu" ]]; then
        echo "This script is intended for Ubuntu only."
        exit 1
    fi
}

# Function to install Docker
install_docker() {
    echo "Step 1: Updating package index and installing prerequisites..."
    sudo apt update
    sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release

    echo "Step 2: Adding Docker's official GPG key..."
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    echo "Step 3: Adding Docker repository..."
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    echo "Step 4: Installing Docker Engine..."
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    echo "Step 5: Starting and enabling Docker service..."
    sudo systemctl start docker
    sudo systemctl enable docker
}

# Function to add user to docker group
add_user_to_docker_group() {
    echo "Step 6: Adding user to docker group..."
    sudo usermod -aG docker $USER
    
    echo "Note: You need to log out and log back in for group changes to take effect."
    echo "Alternatively, you can run: newgrp docker"
}

# Function to verify installation
verify_installation() {
    echo "Step 7: Verifying installation..."
    docker --version
    sudo docker run --rm hello-world
}

# Main execution
main() {
    check_root
    check_ubuntu
    
    echo "Starting Docker installation..."
    install_docker
    add_user_to_docker_group
    
    echo "Installation completed successfully!"
    echo ""
    echo "To apply group changes without logging out, you can run:"
    echo "  newgrp docker"
    echo ""
    echo "Then test Docker without sudo:"
    echo "  docker run --rm hello-world"
}

# Run main function
main

