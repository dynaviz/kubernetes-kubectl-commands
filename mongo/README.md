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

## Credentials

**MongoDB:**
- Username: `mongoadmin`
- Password: `password`

**MongoExpress Web UI:**
- Username: `admin`
- Password: `adminpass`

## Setup Instructions

### Step 1: Apply MongoDB Configuration
```sh
kubectl apply -f mongodb-secret.yaml
kubectl apply -f mongodb-configmap.yaml
kubectl apply -f mongodb-deployment.yaml
kubectl apply -f mongodb-service.yaml
```

### Step 2: Apply MongoExpress Configuration
```sh
kubectl apply -f mongoexpress-secret.yaml
kubectl apply -f mongoexpress-deployment.yaml
kubectl apply -f mongoexpress-service.yaml
```

### Step 3: Verify All Pods and Services
```sh
kubectl get pods
kubectl get svc
```

You should see:
- `mongo-deployment-*` pod (MongoDB) - Running
- `mongo-express-*` pod (MongoExpress) - Running
- `mongodb-service` - ClusterIP (internal only)
- `mongoexpress-service` - NodePort (external access)

## Accessing MongoExpress

### Option 1: Local Mac Accessing Remote Minikube on VM (194.35.13.113)

**Step 1: SSH into the remote VM and start port-forward:**
```sh
ssh user@194.35.13.113
kubectl port-forward --address 0.0.0.0 svc/mongoexpress-service 8081:8081
```

**Step 2: From your Mac, open browser:**
```
http://194.35.13.113:8081
```

Login with:
- Username: `admin`
- Password: `adminpass`

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

## Accessing MongoDB Directly

If you need to connect to MongoDB from your local machine:
```sh
kubectl port-forward svc/mongodb-service 27017:27017
```
Then connect with:
- Host: `localhost`
- Port: `27017`
- Username: `mongoadmin`
- Password: `password`

## Cleanup

To remove all resources:
```sh
kubectl delete -f mongoexpress-service.yaml
kubectl delete -f mongoexpress-deployment.yaml
kubectl delete -f mongoexpress-secret.yaml
kubectl delete -f mongodb-service.yaml
kubectl delete -f mongodb-deployment.yaml
kubectl delete -f mongodb-configmap.yaml
kubectl delete -f mongodb-secret.yaml
```

Or remove all at once:
```sh
kubectl delete -f mongo/
```

## Troubleshooting

### MongoExpress Cannot Connect to MongoDB
Check the deployment environment variables:
```sh
kubectl describe pod -l app=mongoexpress
```

Verify MongoDB pod is running:
```sh
kubectl describe pod -l app=mongodb
```

### Cannot Access Web UI
1. Ensure the service is NodePort type: `kubectl get svc mongoexpress-service`
2. Check if port-forward is running correctly
3. Verify no firewall is blocking port 8081

### Check Service Discovery
Verify MongoDB service is discoverable:
```sh
kubectl get svc mongodb-service
```

Should return internal IP (e.g., 10.102.36.235)
