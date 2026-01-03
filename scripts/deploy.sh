#!/bin/bash

# Deployment script for DevOps application
# Usage: ./deploy.sh <environment> <docker-image>
# Example: ./deploy.sh dev myusername/devops-app:dev

set -e

ENVIRONMENT=$1
DOCKER_IMAGE=$2
CONTAINER_NAME="devops-app-${ENVIRONMENT}"

# Validate arguments
if [ -z "$ENVIRONMENT" ] || [ -z "$DOCKER_IMAGE" ]; then
    echo "Usage: ./deploy.sh <environment> <docker-image>"
    echo "Example: ./deploy.sh dev myusername/devops-app:dev"
    exit 1
fi

# Set port based on environment
case $ENVIRONMENT in
    dev|development)
        PORT=3001
        NODE_ENV=development
        ;;
    test|staging)
        PORT=3002
        NODE_ENV=test
        ;;
    prod|production)
        PORT=3000
        NODE_ENV=production
        ;;
    *)
        echo "Invalid environment: $ENVIRONMENT"
        echo "Valid options: dev, test, prod"
        exit 1
        ;;
esac

echo "🚀 Deploying to $ENVIRONMENT environment..."
echo "📦 Docker image: $DOCKER_IMAGE"
echo "🔌 Port: $PORT"

# Stop and remove existing container
echo "🛑 Stopping existing container..."
docker stop $CONTAINER_NAME 2>/dev/null || true
docker rm $CONTAINER_NAME 2>/dev/null || true

# Pull latest image
echo "⬇️  Pulling latest image..."
docker pull $DOCKER_IMAGE

# Run new container
echo "▶️  Starting new container..."
docker run -d \
    --name $CONTAINER_NAME \
    --restart unless-stopped \
    -p $PORT:$PORT \
    -e NODE_ENV=$NODE_ENV \
    $DOCKER_IMAGE

# Wait for container to start
echo "⏳ Waiting for container to start..."
sleep 5

# Verify container is running
if docker ps | grep -q $CONTAINER_NAME; then
    echo "✅ Container is running"
else
    echo "❌ Container failed to start"
    docker logs $CONTAINER_NAME
    exit 1
fi

# Health check
echo "🏥 Performing health check..."
MAX_RETRIES=10
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if curl -f http://localhost:$PORT/health > /dev/null 2>&1; then
        echo "✅ Health check passed!"
        echo "🌐 Application is available at: http://localhost:$PORT"
        exit 0
    fi
    
    RETRY_COUNT=$((RETRY_COUNT + 1))
    echo "⏳ Waiting for application to be ready... (attempt $RETRY_COUNT/$MAX_RETRIES)"
    sleep 3
done

echo "❌ Health check failed after $MAX_RETRIES attempts"
echo "📋 Container logs:"
docker logs $CONTAINER_NAME
exit 1
