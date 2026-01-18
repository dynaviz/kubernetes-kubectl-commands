# MongoDB Deployment on Kubernetes

This guide explains how to deploy MongoDB to your Kubernetes cluster using the provided YAML files.

## Prerequisites
- A running Kubernetes cluster (e.g., Minikube, Docker Desktop, or cloud provider)
- `kubectl` installed and configured to access your cluster

## Files
- `mongodb-secret.yaml`: Contains the secret for MongoDB root username and password
- `mongodb-deployment.yaml`: Defines the MongoDB Deployment
- `mongodb-service.yaml`: Exposes MongoDB as a Service

## Steps

1. **Apply the Secret**
   
   This file stores the MongoDB root username and password as Kubernetes secrets. Edit the file if you want to change credentials.
   
   ```sh
   kubectl apply -f mongodb-secret.yaml
   ```

2. **Apply the Deployment**
   
   This file creates the MongoDB Deployment using the secret for credentials.
   
   ```sh
   kubectl apply -f mongodb-deployment.yaml
   ```

3. **Apply the Service**
   
   This file exposes MongoDB on the cluster network.
   
   ```sh
   kubectl apply -f mongodb-service.yaml
   ```

## Verify

Check that the pods and service are running:

```sh
kubectl get pods
kubectl get svc
```

## Accessing MongoDB

- For local development, you can port-forward the service:
  ```sh
  kubectl port-forward svc/mongodb-service 27017:27017
  ```
  Then connect to `localhost:27017` using your MongoDB client.

## Cleanup

To remove all resources:
```sh
kubectl delete -f mongodb-service.yaml
kubectl delete -f mongodb-deployment.yaml
kubectl delete -f mongodb-secret.yaml
```
