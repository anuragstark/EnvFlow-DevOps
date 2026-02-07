#!/bin/bash


# ./scripts/local_run.sh [env]
# # Example:
# ./scripts/local_run.sh dev   # Runs on port 3001
# ./scripts/local_run.sh test  # Runs on port 3002
# ./scripts/local_run.sh prod  # Runs on port 3000

# ./scripts/destroy.sh [env]
# # Example:
# ./scripts/destroy.sh dev     # Destroys dev container
# ./scripts/destroy.sh all     # Destroys dev, test, and prod containers


# Configuration
APP_NAME="devops-app"

# Function to print usage
print_usage() {
    echo "Usage: ./local_run.sh [env]"
    echo "Environments: dev (default), test, prod"
    echo "Example: ./local_run.sh test"
}

# Set environment (default to dev)
ENVIRONMENT=${1:-dev}

# Set configuration based on environment
case $ENVIRONMENT in
    dev|development)
        PORT=3001
        NODE_ENV=development
        TAG="dev"
        ;;
    test|staging)
        PORT=3002
        NODE_ENV=test
        TAG="test"
        ;;
    prod|production)
        PORT=3000
        NODE_ENV=production
        TAG="prod"
        ;;
    *)
        echo "❌ Invalid environment: $ENVIRONMENT"
        print_usage
        exit 1
        ;;
esac

CONTAINER_NAME="${APP_NAME}-${TAG}"
IMAGE_NAME="${APP_NAME}:${TAG}"

echo "🚀 Starting Local Run Script for: $ENVIRONMENT"
echo "----------------------------------------"
echo "📦 Image: $IMAGE_NAME"
echo "🔌 Port: $PORT"
echo "📝 Node Env: $NODE_ENV"
echo "----------------------------------------"

# 1. Cleanup existing container
echo "🧹 Cleaning up old container..."
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "   Stopping and removing $CONTAINER_NAME..."
    docker stop $CONTAINER_NAME >/dev/null 2>&1 || true
    docker rm $CONTAINER_NAME >/dev/null 2>&1 || true
    echo "   ✅ Cleanup complete."
else
    echo "   No existing container found."
fi

# 2. Build Docker Image
echo "🔨 Building Docker image..."
if docker build -t $IMAGE_NAME .; then
    echo "   ✅ Build successful."
else
    echo "   ❌ Build failed."
    exit 1
fi

# 3. Run Container
echo "▶️  Starting container..."
docker run -d \
    --name $CONTAINER_NAME \
    -p $PORT:$PORT \
    -e NODE_ENV=$NODE_ENV \
    -e PORT=$PORT \
    $IMAGE_NAME

# 4. Verification
echo "⏳ Waiting for application to start..."
sleep 5

if docker ps | grep -q $CONTAINER_NAME; then
    echo "✅ Container is running!"
    echo "   URL: http://localhost:$PORT"
    echo "   Health Check: http://localhost:$PORT/health"
    
    # Optional: Follow logs
    echo ""
    echo "To view logs: docker logs -f $CONTAINER_NAME"
    echo "To stop: docker stop $CONTAINER_NAME"
else
    echo "❌ Container failed to start."
    docker logs $CONTAINER_NAME
    exit 1
fi
