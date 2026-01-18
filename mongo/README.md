# MongoDB & MongoExpress Deployment on Kubernetes

This guide explains how to deploy MongoDB and MongoExpress to your Kubernetes cluster. MongoExpress provides a web-based UI to manage your MongoDB databases.

## Prerequisites
- A running Kubernetes cluster (e.g., Minikube, Docker Desktop, or cloud provider)
- `kubectl` installed and configured to access your cluster
- For remote access: Minikube running on a remote VM (e.g., 194.35.13.113)

## Files
### MongoDB
- `mongodb-secret.yaml`: Contains MongoDB root username and password
- `mongodb-configmap.yaml`: MongoDB service host configuration
- `mongodb-deployment.yaml`: MongoDB Deployment definition
- `mongodb-service.yaml`: MongoDB Service (internal cluster access)

### MongoExpress
- `mongoexpress-secret.yaml`: MongoExpress web UI credentials
- `mongoexpress-deployment.yaml`: MongoExpress Deployment with MongoDB connection settings
- `mongoexpress-service.yaml`: MongoExpress NodePort Service for web access

## Setup Instructions

### Complete Setup from Scratch

**Step 1: Apply MongoDB Configuration**
```sh
kubectl apply -f mongodb-secret.yaml
kubectl apply -f mongodb-configmap.yaml
kubectl apply -f mongodb-deployment.yaml
kubectl apply -f mongodb-service.yaml
```

**Step 2: Apply MongoExpress Configuration**
```sh
kubectl apply -f mongoexpress-secret.yaml
kubectl apply -f mongoexpress-deployment.yaml
kubectl apply -f mongoexpress-service.yaml
```

**Or apply all at once:**
```sh
cd /home/akieres/repo/kubernetes-kubectl-commands
kubectl apply -f mongo/
```

**Step 3: Verify All Pods and Services**
```sh
kubectl get pods
kubectl get svc
```

You should see:
- `mongo-deployment-*` pod (MongoDB) - Running
- `mongo-express-*` pod (MongoExpress) - Running
- `mongodb-service` - ClusterIP (internal only)
- `mongoexpress-service` - NodePort (external access)

**Step 4: Set up permanent port-forwarding (for internet access)**

See **Option 3: Persistent Port-Forward as Systemd Service** below.

---

## Managing Your Deployment

### Starting Everything

If pods are not running or you want to start from a clean state:

```sh
# Apply all configurations
kubectl apply -f mongo/

# Wait for pods to be ready
kubectl wait --for=condition=ready pod -l app=mongodb --timeout=60s
kubectl wait --for=condition=ready pod -l app=mongoexpress --timeout=60s

# Start the port-forward service
sudo systemctl start kubectl-portforward.service
```

### Restarting Everything

**Restart all pods without changing configuration:**
```sh
kubectl rollout restart deployment/mongo-deployment
kubectl rollout restart deployment/mongo-express
```

**Restart with updated configuration:**
```sh
# Apply changes
kubectl apply -f mongo/

# Force restart pods
kubectl delete pod -l app=mongodb
kubectl delete pod -l app=mongoexpress
```

**Restart the port-forward service:**
```sh
sudo systemctl restart kubectl-portforward.service
```

**Complete restart (everything):**
```sh
# Restart Kubernetes deployments
kubectl rollout restart deployment/mongo-deployment
kubectl rollout restart deployment/mongo-express

# Wait for pods to be ready
sleep 10
kubectl get pods

# Restart port-forward service
sudo systemctl restart kubectl-portforward.service
```

### Stopping Everything

**Stop pods (scale to 0 replicas):**
```sh
kubectl scale deployment/mongo-deployment --replicas=0
kubectl scale deployment/mongo-express --replicas=0
```

**Stop the port-forward service:**
```sh
sudo systemctl stop kubectl-portforward.service
```

**Stop and prevent auto-start on boot:**
```sh
sudo systemctl stop kubectl-portforward.service
sudo systemctl disable kubectl-portforward.service
```

### Starting After Stop

**Start pods (scale back to 1 replica):**
```sh
kubectl scale deployment/mongo-deployment --replicas=1
kubectl scale deployment/mongo-express --replicas=1
```

**Start the port-forward service:**
```sh
sudo systemctl start kubectl-portforward.service
```

### Viewing Logs

**View MongoExpress logs:**
```sh
# Last 50 lines
kubectl logs -l app=mongoexpress --tail=50

# Follow logs in real-time
kubectl logs -l app=mongoexpress -f

# Logs from specific pod
kubectl logs mongo-express-<pod-id>
```

**View MongoDB logs:**
```sh
kubectl logs -l app=mongodb --tail=50
kubectl logs -l app=mongodb -f
```

**View port-forward service logs:**
```sh
# Last 50 lines
sudo journalctl -u kubectl-portforward.service -n 50

# Follow logs in real-time
sudo journalctl -u kubectl-portforward.service -f

# View logs since today
sudo journalctl -u kubectl-portforward.service --since today
```

### Checking Status

**Check credentials from command line:**

View MongoDB credentials:
```sh
# View username
kubectl get secret mongodb-secret -o jsonpath='{.data.MONGO_INITDB_ROOT_USERNAME}' | base64 -d && echo

# View password
kubectl get secret mongodb-secret -o jsonpath='{.data.MONGO_INITDB_ROOT_PASSWORD}' | base64 -d && echo

# View both at once
echo "MongoDB Username: $(kubectl get secret mongodb-secret -o jsonpath='{.data.MONGO_INITDB_ROOT_USERNAME}' | base64 -d)"
echo "MongoDB Password: $(kubectl get secret mongodb-secret -o jsonpath='{.data.MONGO_INITDB_ROOT_PASSWORD}' | base64 -d)"
```

View MongoExpress Web UI credentials:
```sh
# View username
kubectl get secret mongoexpress-secret -o jsonpath='{.data.ME_CONFIG_BASICAUTH_USERNAME}' | base64 -d && echo

# View password
kubectl get secret mongoexpress-secret -o jsonpath='{.data.ME_CONFIG_BASICAUTH_PASSWORD}' | base64 -d && echo

# View both at once
echo "MongoExpress Username: $(kubectl get secret mongoexpress-secret -o jsonpath='{.data.ME_CONFIG_BASICAUTH_USERNAME}' | base64 -d)"
echo "MongoExpress Password: $(kubectl get secret mongoexpress-secret -o jsonpath='{.data.ME_CONFIG_BASICAUTH_PASSWORD}' | base64 -d)"
```

View all secrets (base64 encoded):
```sh
# MongoDB secrets
kubectl get secret mongodb-secret -o yaml

# MongoExpress secrets
kubectl get secret mongoexpress-secret -o yaml
```

**Check all resources:**
```sh
kubectl get all
```

**Check pods status:**
```sh
kubectl get pods -o wide
```

**Check services:**
```sh
kubectl get svc
```

**Check deployments:**
```sh
kubectl get deployments
```

**Check detailed pod information:**
```sh
kubectl describe pod -l app=mongoexpress
kubectl describe pod -l app=mongodb
```

**Check port-forward service status:**
```sh
sudo systemctl status kubectl-portforward.service
```

**Check if port 8081 is listening:**
```sh
sudo netstat -tlnp | grep 8081
```

**Test local connectivity:**
```sh
curl -I http://localhost:8081
```

### Updating Secrets/Configuration

**After changing secrets:**
```sh
# Apply the updated secret
kubectl apply -f mongo/mongoexpress-secret.yaml

# Restart the pod to pick up new secrets
kubectl delete pod -l app=mongoexpress
```

**After changing deployment configuration:**
```sh
# Apply the updated deployment
kubectl apply -f mongo/mongoexpress-deployment.yaml

# Kubernetes will automatically roll out the change
# Or force immediate restart:
kubectl rollout restart deployment/mongo-express
```

### Cleaning Up Old Resources

**Remove old ReplicaSets (leftover from updates):**
```sh
# List old ReplicaSets
kubectl get replicasets

# Delete old ReplicaSets with DESIRED=0
kubectl delete replicaset <replicaset-name>
```

**Clean all old ReplicaSets at once:**
```sh
kubectl get replicasets -o json | jq -r '.items[] | select(.spec.replicas==0) | .metadata.name' | xargs -r kubectl delete replicaset
```

## Accessing MongoExpress

### Option 1: Internet Access via NodePort (Direct VM Access) - RECOMMENDED FOR PUBLIC ACCESS

This option exposes MongoExpress directly to the internet via the Minikube node's port 30001.

**From any browser on the internet, access:**
```
http://194.35.13.113:30001
```

**How it works:**
- The MongoExpress service is configured as `NodePort` type
- Kubernetes exposes the service on port `30001` on the Minikube node
- This port is directly accessible from the internet if your VM's firewall allows it

**Firewall Configuration Needed:**
Make sure your VM's firewall allows inbound traffic on port 30001:
```sh
# On the remote VM, if using UFW:
sudo ufw allow 30001/tcp

# Or for iptables:
sudo iptables -A INPUT -p tcp --dport 30001 -j ACCEPT
```

**Security Note:** This exposes MongoExpress to the entire internet. Consider:
- Using HTTPS (requires reverse proxy/ingress)
- Implementing Web Application Firewall (WAF)
- Using strong authentication credentials
- Restricting access to specific IP ranges

---

### Option 2: Internet Access via Port-Forward (Alternative)

If you prefer to use port-forward instead of direct NodePort access:

**Step 1: SSH into the remote VM:**
```sh
ssh user@194.35.13.113
```

**Step 2: Start the port-forward on the VM (run this in the background or in a separate terminal):**
```sh
kubectl port-forward --address 0.0.0.0 svc/mongoexpress-service 8081:8081
```

Or run it as a background process:
```sh
kubectl port-forward --address 0.0.0.0 svc/mongoexpress-service 8081:8081 &
```

**Step 3: From any browser on the internet, access:**
```
http://194.35.13.113:8081
```

**How it works:**
- `--address 0.0.0.0` binds the port to all network interfaces on the VM (not just localhost)
- `svc/mongoexpress-service` forwards traffic to the MongoExpress service in Kubernetes
- `8081:8081` maps port 8081 on the VM to port 8081 in the container
- This allows external access from anywhere to the service running on the remote VM

**Firewall Configuration Needed:**
```sh
# Allow port 8081
sudo ufw allow 8081/tcp
```

**Note:** Keep this port-forward running while you want to access MongoExpress. If you close the terminal or kill the process, the connection will be lost. Use `&` to run in background or use `nohup`.

---

### Option 3: Persistent Port-Forward as Systemd Service (RECOMMENDED FOR PRODUCTION)

For a permanent, auto-starting solution that survives VM reboots, set up a systemd service.

**Step 1: Create the wrapper script:**
```sh
sudo tee /usr/local/bin/kubectl-portforward.sh > /dev/null << 'EOF'
#!/bin/bash
exec /usr/local/bin/kubectl port-forward --address 0.0.0.0 svc/mongoexpress-service 8081:8081
EOF
sudo chmod +x /usr/local/bin/kubectl-portforward.sh
```

**Step 2: Create the systemd service file:**
```sh
sudo tee /etc/systemd/system/kubectl-portforward.service > /dev/null << 'EOF'
[Unit]
Description=Kubernetes Port Forward for MongoExpress
After=network.target

[Service]
Type=simple
User=<your-username>
ExecStart=/usr/local/bin/kubectl-portforward.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
```

Replace `<your-username>` with your actual username (e.g., `akieres`).

**Step 3: Enable and start the service:**
```sh
sudo systemctl daemon-reload
sudo systemctl enable kubectl-portforward.service
sudo systemctl start kubectl-portforward.service
```

**Step 4: Verify the service is running:**
```sh
sudo systemctl status kubectl-portforward.service
```

You should see:
```
● kubectl-portforward.service - Kubernetes Port Forward for MongoExpress
     Loaded: loaded (/etc/systemd/system/kubectl-portforward.service; enabled; vendor preset: enabled)
     Active: active (running)
   Main PID: XXXX (kubectl)
     Memory: 11.7M
```

**Step 5: Access from anywhere on the internet:**
```
http://194.35.13.113:8081
```

**Managing the service:**

Check status:
```sh
sudo systemctl status kubectl-portforward.service
```

Stop the service:
```sh
sudo systemctl stop kubectl-portforward.service
```

Start the service:
```sh
sudo systemctl start kubectl-portforward.service
```

Restart the service:
```sh
sudo systemctl restart kubectl-portforward.service
```

View logs in real-time:
```sh
sudo journalctl -u kubectl-portforward.service -f
```

View recent logs:
```sh
sudo journalctl -u kubectl-portforward.service -n 50
```

**How it works:**
- The wrapper script is a simple shell script that runs the kubectl port-forward command
- The systemd service manages the wrapper script as a daemon
- `Restart=always` ensures the service automatically restarts if it crashes
- `enabled` means the service will auto-start when the VM reboots
- `--address 0.0.0.0` binds to all network interfaces, making it accessible from the internet

**Security Considerations:**
- MongoExpress is now exposed to the internet - ensure you use strong authentication
- Consider implementing additional security measures:
  - Use a reverse proxy (nginx/Apache) with SSL/TLS
  - Implement IP whitelisting at the firewall level
  - Use Web Application Firewall (WAF)
  - Monitor access logs regularly

### Option 2: Local Minikube on Mac (using tunnel)

**Step 1: Start minikube tunnel in one terminal:**
```sh
minikube tunnel
```

**Step 2: In another terminal, access:**
```sh
http://localhost:8081
```

### Option 3: Port-Forward Locally
```sh
kubectl port-forward svc/mongoexpress-service 8081:8081
```
Then access: `http://localhost:8081`

## Verify MongoDB Connection

Check MongoExpress pod logs to confirm MongoDB connection is successful:
```sh
kubectl logs -l app=mongoexpress
```

You should see:
```
Welcome to mongo-express
Mongo Express server listening at http://0.0.0.0:8081
```

## Internet Firewall Configuration

To allow internet access to MongoExpress, configure your VM's firewall:

**For UFW (Ubuntu Uncomplicated Firewall):**
```sh
# Allow port 8081
sudo ufw allow 8081/tcp

# Verify the rule was added
sudo ufw status
```

**For iptables:**
```sh
# Add rule to allow port 8081
sudo iptables -A INPUT -p tcp --dport 8081 -j ACCEPT

# Save the rule (if using iptables-persistent)
sudo sh -c 'iptables-save > /etc/iptables/rules.v4'
```

**For AWS Security Groups:**
- Allow inbound TCP traffic on port 8081 from your IP or 0.0.0.0/0 (if public access is intended)

**For Azure Network Security Groups:**
- Add an inbound rule for port 8081/TCP

## Accessing MongoDB Directly

If you need to connect to MongoDB from your local machine:
```sh
kubectl port-forward svc/mongodb-service 27017:27017
```
Then connect with:
- Host: `localhost`
- Port: `27017`
- Username: See secret files for credentials
- Password: See secret files for credentials

## Cleanup

### Temporary Cleanup (Keep Configuration)

**Stop services but keep configuration:**
```sh
# Scale down to 0 replicas
kubectl scale deployment/mongo-deployment --replicas=0
kubectl scale deployment/mongo-express --replicas=0

# Stop port-forward service
sudo systemctl stop kubectl-portforward.service
```

### Complete Removal

**Remove all Kubernetes resources:**
```sh
kubectl delete -f mongoexpress-service.yaml
kubectl delete -f mongoexpress-deployment.yaml
kubectl delete -f mongoexpress-secret.yaml
kubectl delete -f mongodb-service.yaml
kubectl delete -f mongodb-deployment.yaml
kubectl delete -f mongodb-configmap.yaml
kubectl delete -f mongodb-secret.yaml
```

**Or remove all at once:**
```sh
kubectl delete -f mongo/
```

**Remove the systemd port-forward service:**
```sh
# Stop and disable the service
sudo systemctl stop kubectl-portforward.service
sudo systemctl disable kubectl-portforward.service

# Remove service files
sudo rm /etc/systemd/system/kubectl-portforward.service
sudo rm /usr/local/bin/kubectl-portforward.sh

# Reload systemd
sudo systemctl daemon-reload
```

**Remove firewall rule:**
```sh
sudo ufw delete allow 8081/tcp
```

**Verify everything is removed:**
```sh
kubectl get all
kubectl get secrets
kubectl get configmaps
sudo systemctl status kubectl-portforward.service
```

---

## Complete Operational Workflow

### Daily Operations

**Check if everything is running:**
```sh
kubectl get pods
sudo systemctl status kubectl-portforward.service
```

**Access MongoExpress:**
```
http://194.35.13.113:8081
```
- Username: `admin`
- Password: `Express@Admin2024`

### When Something Goes Wrong

**MongoExpress not accessible:**
```sh
# Check pod status
kubectl get pods

# Check logs
kubectl logs -l app=mongoexpress --tail=30

# Check port-forward service
sudo systemctl status kubectl-portforward.service
sudo journalctl -u kubectl-portforward.service -n 30

# Check if port is listening
sudo netstat -tlnp | grep 8081

# Restart everything
kubectl rollout restart deployment/mongo-express
sudo systemctl restart kubectl-portforward.service
```

**Authentication failures:**
```sh
# Check secrets are correct
kubectl get secret mongoexpress-secret -o yaml
kubectl get secret mongodb-secret -o yaml

# Decode secrets to verify
kubectl get secret mongoexpress-secret -o jsonpath='{.data.ME_CONFIG_BASICAUTH_USERNAME}' | base64 -d
kubectl get secret mongoexpress-secret -o jsonpath='{.data.ME_CONFIG_BASICAUTH_PASSWORD}' | base64 -d

# After fixing secrets, restart pod
kubectl apply -f mongo/mongoexpress-secret.yaml
kubectl delete pod -l app=mongoexpress
```

**Pods in CrashLoopBackOff or Error state:**
```sh
# Check pod details
kubectl describe pod <pod-name>

# Check logs
kubectl logs <pod-name>

# Delete and let it recreate
kubectl delete pod <pod-name>
```

**Port-forward service not starting:**
```sh
# Check service logs
sudo journalctl -u kubectl-portforward.service -n 50

# Check if port is already in use
sudo netstat -tlnp | grep 8081

# Kill conflicting process if needed
sudo kill <pid>

# Restart service
sudo systemctl restart kubectl-portforward.service
```

### After VM Reboot

Everything should auto-start because:
- Kubernetes deployments are persistent
- Port-forward service is enabled (auto-start)

**Verify after reboot:**
```sh
# Check pods
kubectl get pods

# Check port-forward service
sudo systemctl status kubectl-portforward.service

# If service didn't start
sudo systemctl start kubectl-portforward.service
```

### Quick Troubleshooting Commands

```sh
# Full status check
kubectl get all
kubectl get pods -o wide
sudo systemctl status kubectl-portforward.service
sudo netstat -tlnp | grep 8081

# Full restart
kubectl rollout restart deployment/mongo-deployment
kubectl rollout restart deployment/mongo-express
sudo systemctl restart kubectl-portforward.service

# View all logs
kubectl logs -l app=mongoexpress --tail=50
kubectl logs -l app=mongodb --tail=50
sudo journalctl -u kubectl-portforward.service -n 50

# Test connectivity
curl -I http://localhost:8081
curl -I http://194.35.13.113:8081
```

## Troubleshooting

### Common Issues and Solutions

#### Issue: "This site can't be reached" (194.35.13.113:8081)

**Diagnosis:**
```sh
# Check if port-forward service is running
sudo systemctl status kubectl-portforward.service

# Check if port is listening
sudo netstat -tlnp | grep 8081

# Check if pods are running
kubectl get pods

# Check firewall
sudo ufw status | grep 8081
```

**Solutions:**
```sh
# Solution 1: Restart port-forward service
sudo systemctl restart kubectl-portforward.service

# Solution 2: Check firewall
sudo ufw allow 8081/tcp

# Solution 3: Restart MongoExpress pod
kubectl delete pod -l app=mongoexpress

# Solution 4: Test local connectivity first
curl http://localhost:8081
# If local works but remote doesn't, it's a firewall/network issue

# Solution 5: Complete restart
kubectl rollout restart deployment/mongo-express
sudo systemctl restart kubectl-portforward.service
sleep 10
sudo systemctl status kubectl-portforward.service
```

#### Issue: MongoExpress Cannot Connect to MongoDB

**Symptoms:**
- MongoExpress pod in Error or CrashLoopBackOff state
- Logs show "Authentication failed" or "Could not connect to database"

**Diagnosis:**
```sh
kubectl describe pod -l app=mongoexpress
kubectl logs -l app=mongoexpress --tail=30
```

**Solutions:**
```sh
# Check MongoDB is running
kubectl get pods -l app=mongodb

# Verify MongoDB credentials match in connection string
kubectl get secret mongodb-secret -o yaml

# Check MongoExpress deployment has correct connection URL
kubectl get deployment mongo-express -o yaml | grep MONGODB_URL

# Restart both MongoDB and MongoExpress
kubectl rollout restart deployment/mongo-deployment
kubectl rollout restart deployment/mongo-express
```

#### Issue: Cannot Log In to MongoExpress Web UI

**Diagnosis:**
```sh
# Check credentials
kubectl get secret mongoexpress-secret -o jsonpath='{.data.ME_CONFIG_BASICAUTH_USERNAME}' | base64 -d && echo
kubectl get secret mongoexpress-secret -o jsonpath='{.data.ME_CONFIG_BASICAUTH_PASSWORD}' | base64 -d && echo
```

**Solutions:**
```sh
# If credentials are wrong, update the secret file and apply
kubectl apply -f mongo/mongoexpress-secret.yaml

# Restart MongoExpress pod to pick up new credentials
kubectl delete pod -l app=mongoexpress

# Wait for new pod to start
kubectl get pods -w

# Clear browser cache and try again
# Or try in incognito/private browsing mode
```

#### Issue: Port-Forward Service Won't Start

**Diagnosis:**
```sh
# Check service status
sudo systemctl status kubectl-portforward.service

# View detailed logs
sudo journalctl -u kubectl-portforward.service -n 50

# Check if port is already in use
sudo lsof -i :8081
```

**Solutions:**
```sh
# Solution 1: Kill process using port 8081
sudo lsof -i :8081  # Get PID
sudo kill <PID>
sudo systemctl start kubectl-portforward.service

# Solution 2: Reload and restart
sudo systemctl daemon-reload
sudo systemctl restart kubectl-portforward.service

# Solution 3: Check script permissions
ls -la /usr/local/bin/kubectl-portforward.sh
sudo chmod +x /usr/local/bin/kubectl-portforward.sh

# Solution 4: Manually test the command
/usr/local/bin/kubectl port-forward --address 0.0.0.0 svc/mongoexpress-service 8081:8081
# If it works manually, restart the service
```

#### Issue: Pods Stuck in "Pending" State

**Diagnosis:**
```sh
kubectl describe pod <pod-name>
```

**Solutions:**
```sh
# Check if Minikube is running
minikube status

# Start Minikube if needed
minikube start

# Delete and recreate pod
kubectl delete pod <pod-name>
```

#### Issue: Old ReplicaSets Cluttering Output

**Solution:**
```sh
# List all ReplicaSets
kubectl get replicasets

# Delete old ReplicaSets with DESIRED=0
kubectl get replicasets -o json | jq -r '.items[] | select(.spec.replicas==0) | .metadata.name' | xargs -r kubectl delete replicaset

# Or manually delete each one
kubectl delete replicaset <replicaset-name>
```

#### Issue: Changes to Secrets Not Taking Effect

**Solution:**
```sh
# Apply the secret
kubectl apply -f mongo/mongoexpress-secret.yaml

# IMPORTANT: Restart the pod to pick up new secrets
kubectl delete pod -l app=mongoexpress

# Or force rollout restart
kubectl rollout restart deployment/mongo-express

# Verify new pod is running
kubectl get pods -w
```

#### Issue: Service Not Starting After VM Reboot

**Diagnosis:**
```sh
# Check if service is enabled
sudo systemctl is-enabled kubectl-portforward.service

# Check service status
sudo systemctl status kubectl-portforward.service

# Check Minikube status
minikube status
```

**Solutions:**
```sh
# Start Minikube if needed
minikube start

# Enable and start the service
sudo systemctl enable kubectl-portforward.service
sudo systemctl start kubectl-portforward.service

# Verify pods are running
kubectl get pods
```

### Verification Checklist

Run these commands to verify everything is working:

```sh
# 1. Check pods are running
kubectl get pods
# Expected: Both mongo-deployment and mongo-express pods in "Running" state

# 2. Check services
kubectl get svc
# Expected: mongodb-service (ClusterIP) and mongoexpress-service (NodePort)

# 3. Check port-forward service
sudo systemctl status kubectl-portforward.service
# Expected: Active (running)

# 4. Check port is listening
sudo netstat -tlnp | grep 8081
# Expected: kubectl process listening on 0.0.0.0:8081

# 5. Test local connectivity
curl -I http://localhost:8081
# Expected: HTTP 401 (authentication required - this is good!)

# 6. Check MongoExpress logs
kubectl logs -l app=mongoexpress --tail=5
# Expected: "Mongo Express server listening at http://0.0.0.0:8081"

# 7. Check firewall
sudo ufw status | grep 8081
# Expected: 8081/tcp ALLOW Anywhere

# 8. Test from external browser
# Open: http://194.35.13.113:8081
# Expected: Login dialog appears
```

### Emergency Recovery

If everything is broken and you need to start fresh:

```sh
# 1. Delete everything
kubectl delete -f mongo/

# 2. Stop port-forward service
sudo systemctl stop kubectl-portforward.service

# 3. Wait for cleanup
sleep 10

# 4. Reapply everything
kubectl apply -f mongo/

# 5. Wait for pods to be ready
kubectl wait --for=condition=ready pod -l app=mongodb --timeout=60s
kubectl wait --for=condition=ready pod -l app=mongoexpress --timeout=60s

# 6. Restart port-forward service
sudo systemctl restart kubectl-portforward.service

# 7. Verify everything
kubectl get pods
sudo systemctl status kubectl-portforward.service
curl -I http://localhost:8081
```

---

## Implementation Summary: Internet Access Setup

### Files Created on the Remote VM (194.35.13.113)

#### 1. Systemd Service File
**Location:** `/etc/systemd/system/kubectl-portforward.service`

**Content:**
```ini
[Unit]
Description=Kubernetes Port Forward for MongoExpress
After=network.target

[Service]
Type=simple
User=akieres
ExecStart=/usr/local/bin/kubectl-portforward.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

**Purpose:** Manages the port-forward process as a system service that:
- Automatically starts when the VM boots
- Restarts if the process crashes
- Runs as the `akieres` user with appropriate permissions

#### 2. Wrapper Shell Script
**Location:** `/usr/local/bin/kubectl-portforward.sh`

**Content:**
```bash
#!/bin/bash
exec /usr/local/bin/kubectl port-forward --address 0.0.0.0 svc/mongoexpress-service 8081:8081
```

**Permissions:** `755` (executable)

**Purpose:** A simple wrapper that:
- Executes the kubectl port-forward command
- Uses absolute path to kubectl (`/usr/local/bin/kubectl`)
- Binds to all network interfaces (`0.0.0.0`) for internet accessibility
- Forwards traffic from VM port 8081 to Kubernetes service port 8081

### Commands Executed to Set Up

**Step 1: Create and install the wrapper script**
```sh
cat > /tmp/kubectl-portforward.sh << 'EOF'
#!/bin/bash
exec /usr/local/bin/kubectl port-forward --address 0.0.0.0 svc/mongoexpress-service 8081:8081
EOF

sudo cp /tmp/kubectl-portforward.sh /usr/local/bin/kubectl-portforward.sh
sudo chmod +x /usr/local/bin/kubectl-portforward.sh
```

**Step 2: Create the systemd service file**
```sh
cat > /tmp/kubectl-portforward.service << 'EOF'
[Unit]
Description=Kubernetes Port Forward for MongoExpress
After=network.target

[Service]
Type=simple
User=akieres
ExecStart=/usr/local/bin/kubectl-portforward.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

sudo cp /tmp/kubectl-portforward.service /etc/systemd/system/kubectl-portforward.service
```

**Step 3: Register and start the service**
```sh
sudo systemctl daemon-reload
sudo systemctl enable kubectl-portforward.service
sudo systemctl start kubectl-portforward.service
```

**Step 4: Configure firewall (UFW)**
```sh
sudo ufw allow 8081/tcp
```

### Kubernetes Configuration Files Modified

#### 1. `mongodb-secret.yaml`
**Changes:** Updated with new base64-encoded credentials
```yaml
data:
  MONGO_INITDB_ROOT_USERNAME: bW9uZ29hZG1pbg==          # mongoadmin
  MONGO_INITDB_ROOT_PASSWORD: TM9uZ29AMjAyNFNlY3VyZQ==  # Mongo@2024Secure
```

#### 2. `mongoexpress-secret.yaml`
**Changes:** Updated with web UI credentials
```yaml
data:
  ME_CONFIG_BASICAUTH_USERNAME: YWRtaW4=                  # admin
  ME_CONFIG_BASICAUTH_PASSWORD: RXhwcmVzc0BAZG1pbjIwMjQ=  # Express@Admin2024
```

#### 3. `mongoexpress-deployment.yaml`
**Changes:** Updated MongoDB connection configuration
```yaml
env:
  - name: ME_CONFIG_MONGODB_URL
    value: "mongodb://mongoadmin:password@mongodb-service:27017/"
  - name: ME_CONFIG_BASICAUTH_USERNAME
    valueFrom:
      secretKeyRef:
        name: mongoexpress-secret
        key: ME_CONFIG_BASICAUTH_USERNAME
  - name: ME_CONFIG_BASICAUTH_PASSWORD
    valueFrom:
      secretKeyRef:
        name: mongoexpress-secret
        key: ME_CONFIG_BASICAUTH_PASSWORD
  - name: ME_CONFIG_SITE_COOKIESECURE
    value: "false"
  - name: ME_CONFIG_SITE_BASEURL
    value: "/"
```

#### 4. `mongoexpress-service.yaml`
**Changes:** Service type changed from LoadBalancer to NodePort
```yaml
spec:
  type: NodePort
  ports:
    - protocol: TCP
      port: 8081
      targetPort: 8081
      nodePort: 30001
```

**Reason:** NodePort works better with Minikube on remote VMs. The actual external access is achieved through kubectl port-forward binding to 0.0.0.0.

### How It Works: Network Flow

```
Internet (Mac/Browser)
        ↓
194.35.13.113:8081 (VM Public IP)
        ↓
kubectl port-forward (running in systemd service)
        ↓
192.168.49.2:8081 (Minikube internal IP)
        ↓
mongoexpress-service (Kubernetes Service)
        ↓
mongo-express-* pod (Container Port 8081)
```

### System Architecture

```
┌─────────────────────────────────────────────┐
│   Remote Ubuntu VM (194.35.13.113)          │
│  ┌───────────────────────────────────────┐  │
│  │ Systemd Service Manager               │  │
│  │ kubectl-portforward.service (enabled) │  │
│  └────────────┬────────────────────────┘  │
│               │                            │
│  ┌────────────▼────────────────────────┐  │
│  │ Wrapper Script                      │  │
│  │ /usr/local/bin/kubectl-portforward  │  │
│  └────────────┬────────────────────────┘  │
│               │                            │
│  ┌────────────▼────────────────────────┐  │
│  │ kubectl port-forward                │  │
│  │ --address 0.0.0.0                   │  │
│  │ svc/mongoexpress-service 8081:8081  │  │
│  └────────────┬────────────────────────┘  │
│               │                            │
│  ┌────────────▼────────────────────────┐  │
│  │ Minikube Docker Network             │  │
│  │ 192.168.49.2:8081                   │  │
│  └────────────┬────────────────────────┘  │
│               │                            │
│  ┌────────────▼────────────────────────┐  │
│  │ Kubernetes Service                  │  │
│  │ mongoexpress-service (NodePort)     │  │
│  └────────────┬────────────────────────┘  │
│               │                            │
│  ┌────────────▼────────────────────────┐  │
│  │ MongoExpress Pod                    │  │
│  │ Port 8081                           │  │
│  └─────────────────────────────────────┘  │
└─────────────────────────────────────────────┘
```

### Service Management Commands

All these commands are available to manage the port-forward service:

```sh
# View service status
sudo systemctl status kubectl-portforward.service

# Start the service
sudo systemctl start kubectl-portforward.service

# Stop the service
sudo systemctl stop kubectl-portforward.service

# Restart the service
sudo systemctl restart kubectl-portforward.service

# View live logs
sudo journalctl -u kubectl-portforward.service -f

# View last 50 lines of logs
sudo journalctl -u kubectl-portforward.service -n 50

# Check if service is enabled (auto-start on boot)
sudo systemctl is-enabled kubectl-portforward.service

# Disable auto-start
sudo systemctl disable kubectl-portforward.service

# Enable auto-start
sudo systemctl enable kubectl-portforward.service
```

### Verification Commands

Verify the setup is working:

```sh
# Check that port 8081 is listening on 0.0.0.0
sudo netstat -tlnp | grep 8081

# Check the process details
ps aux | grep "kubectl port-forward"

# Check firewall allows port 8081
sudo ufw status

# Test connectivity locally
curl http://localhost:8081

# Test from another machine on the network
curl http://194.35.13.113:8081
```

### Files in Repository

All Kubernetes configuration files are stored in the `mongo/` directory:

```
mongo/
├── README.md                      # This documentation
├── mongodb-secret.yaml            # MongoDB credentials
├── mongodb-configmap.yaml         # MongoDB configuration
├── mongodb-deployment.yaml        # MongoDB deployment
├── mongodb-service.yaml           # MongoDB service (internal)
├── mongoexpress-secret.yaml       # MongoExpress web UI credentials
├── mongoexpress-deployment.yaml   # MongoExpress deployment with MongoDB connection
└── mongoexpress-service.yaml      # MongoExpress service (NodePort)
```

### Deployment Command

Apply all configurations to the Kubernetes cluster:

```sh
kubectl apply -f mongo/
```

This creates:
- Secrets for credentials
- ConfigMaps for configuration
- Deployments for MongoDB and MongoExpress
- Services for network exposure

### Removing the Service

To stop MongoExpress from being accessible from the internet:

**Disable auto-start but keep the service installed:**
```sh
sudo systemctl stop kubectl-portforward.service
sudo systemctl disable kubectl-portforward.service
```

**Completely remove the service:**
```sh
sudo systemctl stop kubectl-portforward.service
sudo systemctl disable kubectl-portforward.service
sudo rm /etc/systemd/system/kubectl-portforward.service
sudo rm /usr/local/bin/kubectl-portforward.sh
sudo systemctl daemon-reload
```

**Remove firewall rule:**
```sh
sudo ufw delete allow 8081/tcp
```

### Future Modifications

If you need to update the port-forward binding or add HTTPS:

**Change the port (e.g., to 9000):**
1. Edit `/etc/systemd/system/kubectl-portforward.service`
2. Change `/usr/local/bin/kubectl-portforward.sh` to update the port in the script
3. Edit `/usr/local/bin/kubectl-portforward.sh` and change `8081:8081` to `9000:8081`
4. Run `sudo systemctl daemon-reload && sudo systemctl restart kubectl-portforward.service`
5. Update firewall: `sudo ufw delete allow 8081/tcp && sudo ufw allow 9000/tcp`

**For HTTPS with reverse proxy (nginx):**
1. Install nginx: `sudo apt install nginx`
2. Configure nginx as reverse proxy to localhost:8081
3. Set up SSL certificate with Let's Encrypt
4. Expose nginx on port 443 instead of kubectl port-forward on 8081
