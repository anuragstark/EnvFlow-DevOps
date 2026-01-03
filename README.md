# Anurag Stark - [LinkedIn](https://www.linkedin.com/in/anuragstark/)

## 🔗 Repository
[https://github.com/anuragstark/EnvFlow-DevOps.git](https://github.com/anuragstark/EnvFlow-DevOps.git)

# DevOps Project - Multi-Environment Deployment

A complete DevOps workflow demonstration with Node.js application, Docker containerization, and automated CI/CD pipelines for Dev, Test, and Production environments using a single cost-effective AWS EC2 instance.

## Project Overview

This project demonstrates a production-ready DevOps setup optimized for cost efficiency:
- **Environment Separation**: Dev (3001), Test (3002), and Production (3000) on single host
- **Containerization**: Docker with multi-stage builds
- **CI/CD Automation**: GitHub Actions workflows
- **Cloud Deployment**: Single AWS EC2 instance with automated deployments
- **Testing**: Automated unit tests and smoke tests
- **Security**: Security audits and best practices

## Architecture

```
┌───────────────────────────────────────────┐
│              AWS EC2 Instance             │
│  ┌───────────┐ ┌───────────┐ ┌──────────┐ │
│  │    PROD   │ │    DEV    │ │   TEST   │ │
│  │ Container │ │ Container │ │ Container│ │
│  │ Port 3000 │ │ Port 3001 │ │ Port 3002│ │
│  └───────────┘ └───────────┘ └──────────┘ │
└───────────────────────────────────────────┘
                     ▲
                     │
              GitHub Actions
                     │
              ┌──────┴──────┐
              │  Docker Hub │
              └─────────────┘
```

## 📁 Project Structure

```
devops-project/
├── src/
│   ├── app.js          # Express application
│   ├── server.js       # Server entry point
│   └── config.js       # Configuration loader
├── tests/
│   └── app.test.js     # Unit tests
├── scripts/
│   └── deploy.sh       # Deployment script
├── .github/
│   └── workflows/
│       ├── dev-deploy.yml   # Dev pipeline
│       ├── test-deploy.yml  # Test pipeline
│       └── prod-deploy.yml  # Prod pipeline
├── .env.dev            # Dev environment config
├── .env.test           # Test environment config
├── .env.prod           # Prod environment config
├── Dockerfile          # Container definition
├── .dockerignore       # Docker ignore rules
├── .gitignore          # Git ignore rules
└── package.json        # Node.js dependencies
```

## Quick Start

### Prerequisites

- Node.js 18+
- Docker
- Git
- AWS EC2 instance (Ubuntu recommended for cost)
- Docker Hub account

### Local Development

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd devops-project
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Run in development mode**
   ```bash
   npm run dev
   ```
   Access at: http://localhost:3000

4. **Run tests**
   ```bash
   npm test
   ```

## 🐳 Docker Usage

### Build Images

```bash
# Development
docker build -t devops-app:dev .

# Test
docker build -t devops-app:test .

# Production
docker build -t devops-app:prod .
```

### Run Containers

```bash
# Production (port 3000)
docker run -d -p 3000:3000 -e NODE_ENV=production --name devops-prod devops-app:prod

# Development (port 3001)
docker run -d -p 3001:3001 -e NODE_ENV=development --name devops-dev devops-app:dev

# Test (port 3002)
docker run -d -p 3002:3002 -e NODE_ENV=test --name devops-test devops-app:test
```

### Using Deployment Script

```bash
# Deploy to dev
./scripts/deploy.sh dev yourusername/devops-app:dev

# Deploy to test
./scripts/deploy.sh test yourusername/devops-app:test

# Deploy to prod
./scripts/deploy.sh prod yourusername/devops-app:prod
```

## 🔧 Environment Configuration

### Development (.env.dev)
- **Port**: 3001
- **Debug**: Enabled
- **Log Level**: debug
- **Database**: Local MongoDB

### Test (.env.test)
- **Port**: 3002
- **Debug**: Disabled
- **Log Level**: info
- **Database**: Staging MongoDB

### Production (.env.prod)
- **Port**: 3000
- **Debug**: Disabled
- **Log Level**: error
- **Database**: Production MongoDB

##  CI/CD Pipeline

### Branching Strategy

```
main (production)
  ↑
  └── test (staging)
        ↑
        └── dev (development)
```

### Workflows

#### 1. Dev Deployment (`dev-deploy.yml`)
- **Trigger**: Push to `dev` branch
- **Steps**:
  1. Unit tests
  2. Build/Push Docker image
  3. Deploy to EC2 (Port 3001)
  4. Health check

#### 2. Test Deployment (`test-deploy.yml`)
- **Trigger**: PR merge to `test` branch
- **Steps**:
  1. Full tests suite
  2. Build/Push Docker image
  3. Deploy to EC2 (Port 3002)
  4. Smoke tests

#### 3. Production Deployment (`prod-deploy.yml`)
- **Trigger**: Push to `main` branch or GitHub release
- **Steps**:
  1. Strict security audit
  2. Build/Push Prod Docker image
  3. Deploy to EC2 (Port 3000)
  4. Production validation

##  GitHub Secrets Configuration

Configure these secrets in your GitHub repository (Settings → Secrets and variables → Actions):

| Secret Name | Description |
|------------|-------------|
| `DOCKER_USERNAME` | Docker Hub username |
| `DOCKER_PASSWORD` | Docker Hub password/token |
| `AWS_EC2_HOST` | Single EC2 public IP/hostname |
| `AWS_EC2_SSH_KEY` | Private SSH key for EC2 access |
| `AWS_EC2_USER` | EC2 username (e.g., `ec2-user` or `ubuntu`) |

##  AWS EC2 Setup (Cheapest Option)

### 1. Launch Single EC2 Instance
- **OS**: Ubuntu Server 22.04 LTS (recommended)
- **Instance Type**: t3.micro or t2.micro (Free Tier eligible)
- **Storage**: 8GB gp3 (Free Tier eligible)

### 2. Configure Security Group
Allow inbound traffic on:
- **SSH**: Port 22 (Your IP)
- **Prod App**: Port 3000 (Anywhere)
- **Dev App**: Port 3001 (Anywhere)
- **Test App**: Port 3002 (Anywhere)

##  API Endpoints

| Endpoint | Description |
|----------|-------------|
| `GET /` | Welcome message with environment info |
| `GET /health` | Health check endpoint |
| `GET /info` | Detailed application information |

## 🔍 Verification

Check all environments on the single host:
- **Prod**: `http://<EC2-IP>:3000/info`
- **Dev**: `http://<EC2-IP>:3001/info`
- **Test**: `http://<EC2-IP>:3002/info`

##  License

ISC

## 👤 Author
Anurag Stark - [LinkedIn](https://www.linkedin.com/in/anuragstark/)
