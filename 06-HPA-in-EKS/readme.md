# Horizontal Pod Autoscaler (HPA) on Amazon EKS – Quick Tutorial

## What is HPA?

The **Horizontal Pod Autoscaler (HPA)** automatically adjusts the number of pods in a **Kubernetes Deployment**, **ReplicaSet**, or **StatefulSet** based on CPU/memory usage or custom metrics.

- **Goal**: Keep resource utilization around a target (e.g., 50% CPU)
- **Example**: If pods are under high CPU load, HPA adds more pods to handle traffic

## Prerequisites

- An EKS cluster created with `eksctl`
- `kubectl` configured to access your cluster
- Metrics Server is **already included** with `eksctl`-based clusters

Test it:
```bash
kubectl top nodes
kubectl top pods
kubectl get deployment -n kube-system
```

You should see the ``metrics-server`` available and ready (2/2)

## Deploy a sample app with HPA in EKS cluster

Now, create a file called `nginx-deploy-hpa.yaml`. In this file, you have:

- a deployment – to define your application.
- a Service  (optional) – to expose your app.
- a HPA – to scale your pods based on CPU or memory usage. you can use the `kubectl autoscale` command but this is not a best practice.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx
          ports:
            - containerPort: 80
          resources:
            requests:
              cpu: "100m"
              memory: "128Mi"
            limits:
              cpu: "500m"
              memory: "256Mi"
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: NodePort
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: nginx-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx-deployment
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 20
```

Apply the manifest in the cluster

```bash
kubectl apply -f nginx-deploy-hpa.yaml
kubectl get deploy
kubectl get svc
kubectl get hpa
kubectl get pods
```

- **cpu-percent=20**: The target average CPU utilization
- **min=2**: The lower limit for the number of pods that can be set by the autoscaler
- **max=5**: The upper limit for the number of pods that can be set by the autoscaler

**WARNING**: You probably will see <unknown>/20% for 1-2 minutes and then you should be able to see 0%/20%

## 4. Generate load to trigger the autoscaling

Open another Gitbash terminal run a load generator pod

```bash
kubectl run -i --tty load-generator --rm --image=busybox:1.28 --restart=Never -- sh 
```

```bash
#Execute a while loop to generate the load
while true; do wget -q -O - http://nginx-service; done
```

Note you can open another Gitbash terminal to run a second load generator pod.

In the first terminal, watch the HPA with the following command
```bash
kubectl get pods
kubectl top pods
kubectl get hpa -w
```
Stop the load generation in the second terminal with CTRL + C and watch the HPA behaviour

```bash
kubectl get pods
kubectl top pods
```
**Note:** It might take some time before the number of pods comes back to the minimum specified in the hpa.

# Clean Up

Delete all the objects created.

