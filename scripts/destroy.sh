#!/bin/bash

# Configuration
APP_NAME="devops-app"

# Function to print usage
print_usage() {
    echo "Usage: ./destroy.sh [env]"
    echo "Environments: dev, test, prod, all (default)"
    echo "Example: ./destroy.sh dev"
}

# Set environment (default to all)
ENVIRONMENT=${1:-all}

destroy_container() {
    local env=$1
    local container_name="${APP_NAME}-${env}"
    
    if docker ps -a --format '{{.Names}}' | grep -q "^${container_name}$"; then
        echo "🛑 Stopping and removing $container_name..."
        docker stop $container_name >/dev/null 2>&1 || true
        docker rm $container_name >/dev/null 2>&1 || true
        echo "✅ Removed $container_name"
    else
        echo "ℹ️  Container $container_name not found."
    fi
}

echo "🗑️  Starting Destroy Script for: $ENVIRONMENT"
echo "----------------------------------------"

case $ENVIRONMENT in
    dev|development)
        destroy_container "dev"
        ;;
    test|staging)
        destroy_container "test"
        ;;
    prod|production)
        destroy_container "prod"
        ;;
    all)
        destroy_container "dev"
        destroy_container "test"
        destroy_container "prod"
        ;;
    *)
        echo "❌ Invalid environment: $ENVIRONMENT"
        print_usage
        exit 1
        ;;
esac

echo "----------------------------------------"
echo "✨ Cleanup complete!"
