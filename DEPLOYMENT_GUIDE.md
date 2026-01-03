# AWS EC2 Deployment Guide (Cost-Effective)

Complete step-by-step guide for setting up a **single AWS EC2 instance** to host Dev, Test, and Production environments efficiently.

## Prerequisites

- AWS Account
- AWS CLI installed (optional but recommended)
- SSH client
- Docker Hub account
- GitHub account with repository access

## Part 1: AWS EC2 Instance Setup

### Step 1: Launch Single EC2 Instance

You will create **1 EC2 instance** to host all three environments.

#### 1.1 Login to AWS Console
- Go to https://console.aws.amazon.com/
- Navigate to EC2 Dashboard

#### 1.2 Launch Instance

1. Click **"Launch Instance"**

2. **Name and Tags**:
   - Name: `devops-app-server`

3. **Application and OS Images**:
   - Choose **Ubuntu Server 22.04 LTS** (Recommended) or Amazon Linux 2023
   - Architecture: 64-bit (x86)

4. **Instance Type**:
   - Select **t3.micro** or **t2.micro** (Free Tier eligible)
   - These instances have 1GB RAM, which is sufficient for 3 small Node.js containers

5. **Key Pair**:
   - Create new key pair or use existing
   - Name: `devops-key`
   - Type: RSA
   - Format: .pem (for Mac/Linux) or .ppk (for Windows)
   - **Download and save securely**

6. **Network Settings**:
   - Create security group or use existing
   - Allow SSH traffic from: **Your IP** (recommended)
   - Add custom TCP rules for all environments:
     - **Port 3000** (Production) - Source: Anywhere (0.0.0.0/0)
     - **Port 3001** (Development) - Source: Anywhere (0.0.0.0/0)
     - **Port 3002** (Test/Staging) - Source: Anywhere (0.0.0.0/0)

7. **Configure Storage**:
   - 8-10 GB gp3 (Free tier allows up to 30GB)

8. Click **"Launch Instance"**

#### 1.3 Note Down Instance Details

After launching, note down:
- **Public IPv4 Address**: `xx.xx.xx.xx` (This will be your `AWS_EC2_HOST`)

### Step 2: Connect to EC2 Instance

#### 2.1 Set Key Permissions
```bash
chmod 400 ~/Downloads/devops-key.pem
mv ~/Downloads/devops-key.pem ~/.ssh/
```

#### 2.2 SSH into Instance
```bash
ssh -i ~/.ssh/devops-key.pem ubuntu@<PUBLIC_IP>
```

### Step 3: Install Docker

```bash
# Update packages
sudo apt-get update

# Install Docker
sudo apt-get install -y docker.io

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group (avoids sudo for docker commands)
sudo usermod -aG docker ubuntu

# Logout and login again for group changes to take effect
exit
```

**Verify Installation:**
```bash
# SSH back in
ssh -i ~/.ssh/devops-key.pem ubuntu@<PUBLIC_IP>

# Test Docker
docker run hello-world
```

## Part 2: GitHub Configuration

### Step 1: Configure GitHub Secrets

1. Go to your repository on GitHub
2. Navigate to **Settings → Secrets and variables → Actions**
3. Add the following secrets:

#### Docker Hub Secrets

| Secret Name | Value |
|------------|-------|
| `DOCKER_USERNAME` | Your Docker Hub username |
| `DOCKER_PASSWORD` | Docker Hub access token |

#### AWS EC2 Secrets

| Secret Name | Value | Description |
|------------|-------|-------------|
| `AWS_EC2_HOST` | `<PUBLIC_IP>` | The public IP of your single EC2 instance |
| `AWS_EC2_USER` | `ubuntu` | Username for the instance |
| `AWS_EC2_SSH_KEY` | `-----BEGIN RSA...` | Content of your private key file |

### Step 2: Branch Setup

Ensure your repository has the following branches:
- `main` (Production)
- `test` (Testing)
- `dev` (Development)

```bash
git checkout -b dev
git push -u origin dev

git checkout -b test
git push -u origin test
```

## Part 3: Deployment Strategy

Your single EC2 instance will host three isolated containers running on different ports:

| Environment | Port | URL |
|-------------|------|-----|
| **Production** | 3000 | `http://<IP>:3000` |
| **Development** | 3001 | `http://<IP>:3001` |
| **Test/Staging** | 3002 | `http://<IP>:3002` |

### Automated Workflows

1. **Dev Deployment**: Pushing to `dev` branch deploys to port 3001.
2. **Test Deployment**: Merging PR into `test` branch deploys to port 3002.
3. **Prod Deployment**: Pushing to `main` branch deploys to port 3000.

## Part 4: Verification & Monitoring

### Check Running Containers
```bash
# SSH into your instance
ssh -i ~/.ssh/devops-key.pem ubuntu@<PUBLIC_IP>

# View all running containers
docker ps

# Output should show 3 containers (once fully deployed):
# devops-app-prod (0.0.0.0:3000->3000/tcp)
# devops-app-dev  (0.0.0.0:3001->3001/tcp)
# devops-app-test (0.0.0.0:3002->3002/tcp)
```

### View Logs
```bash
# Production logs
docker logs -f devops-app-prod

# Dev logs
docker logs -f devops-app-dev

# Test logs
docker logs -f devops-app-test
```

### Resource Monitoring
Since we are using a micro instance, monitor resource usage to ensure stability:
```bash
docker stats
```

## Troubleshooting

### "Bind for 0.0.0.0:xxxx failed: port is already allocated"
This means a container is already running on that port. The deployment script handles this automatically, but you can manually fix it:
```bash
docker stop <container_name>
docker rm <container_name>
```

### "Connection refused"
- Check Security Group rules in AWS Console. Ensure ports 3000, 3001, 3002 are open.
- Check if Docker containers are running (`docker ps`).

### "Host key verification failed"
If you restart/recreate the EC2 instance, the IP might match but the fingerprint changes.
```bash
ssh-keygen -R <PUBLIC_IP>
```

---

**Note**: This setup is optimized for cost savings (Free Tier). For high-traffic applications, consider separating environments into different instances or using a container orchestration service like ECS or Kubernetes.
