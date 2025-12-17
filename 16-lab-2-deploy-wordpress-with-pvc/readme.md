**Note: In this lab we will use the cluster deployed with eksctl in EKS. You will also need to enable dynamic storage provisioning using EBS**

# Lab 3: Deploying WordPress and MySQL with Persistent Volumes (updated)

In this Lab, we will deploy wordpress and mysql in Kubernetes using persistent storage.

## Prerequites
- Get a cluster up and running. 
**Note: In this lab we will use the cluster deployed with eksctl in EKS**
- Have knowledge on kubernetes objects (Pods, deployment, service, PV, PVC, Configmap and secret)

Note: This lab can be done on Minikube as well

## Enable dynamic storage provisioning in eks

**Note:** The cluster used here is the cluster create in AWS with eksctl.

To be able to create persistent volumes for our apps, we need to make sure dynamic provisioning is enabled.
Check the folder on persistent volumes to do that.(`11-persistent-storage`). Use `EFS` volumes. 

## Create and apply the YAML files to deploy the app
```bash
kubectl apply -f 01-secret.yaml
kubectl apply -f 02-configmap.yaml
kubectl apply -f 03-mysql-deployment.yaml
kubectl apply -f 04-wordpress-deployment.yaml
```
## Verify the objects created

To list all the objects created, use the command
```bash
kubectl get secret,cm,deployment,pods,svc
```

## Test the app
List the services and check the EXTERNAL-IP field to pick the external IP and the port of the wordpress service
```bash
kubectl get svc
```
You can access the app from your browser
```bash
http://<EXTERNAL-IP>:<PORT>
```
**Note:** If you used a service of Type **LoadBalancer**, you just need to use the Loadbalancer name provided.

### Expected result:
![wordpress](wordpress.png)

## Clean up

Delete all the resources created
```bash
kubectl delete -f 01-secret.yaml
kubectl delete -f 02-configmap.yaml
kubectl delete -f 03-mysql-deployment.yaml
kubectl delete -f 04-wordpress-deployment.yaml
```
Note: If you created a specific directory to hold all your yaml files, you can delete the corresponding objects created with one command:

```bash
kubectl delete -f .
```
