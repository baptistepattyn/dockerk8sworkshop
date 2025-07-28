
# K8S Exercises

## Get connected to the Cluster

```sh

az account set --subscription a476a434-0f2f-45db-bf17-cf278ef08379

az aks get-credentials --resource-group rg-containerworkshop-001 --name bpatestcluster --overwrite-existing

kubectl get ns

```

## Create your own namespace

```sh

kubectl create namespace <name>

kubectl config set-context --current --namespace=<name>

```
## Create and explore a pod

```yaml

apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
spec:
  containers:
    - name: nginx
      image: nginx
      ports:
        - containerPort: 80
```

```sh
kubectl apply -f pod.yml
kubectl get pods
kubectl describe pods nginx-pod
kubectl logs nginx-pod
kubctl delete pod nginx-pod
```

## Create a Deployment

```yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deploy
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
```

### Apply deployment

```sh
kubectl apply -f deployment.yaml
kubectl get deployments
kubectl get rs
kubectl get pods <-l app=nginx>
```

### Scale the deployment

```sh
kubectl scale deployment nginx-deploy --replicas=5
```

### Update deployment

```yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deploy
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
          image: nginx:1.25
          ports:
            - containerPort: 80
```

```sh

kubectl get pods -w
kubectl rollout history deployment nginx-deploy
kubectl rollout history deployment nginx-deploy --revision=2
```

### Break the deployment


```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deploy
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
          image: nginx:badtag
          ports:
            - containerPort: 80
```

### Repair the deployment

```sh

kubectl set image deployment/nginx-deploy nginx=nginx

```
## Expose deployment with a service

### Deploy the service

```yml

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
  type: ClusterIP

```

```sh

kubectl apply -f service.yml
kubectl get svc
```

### Test the service with ClusterIP

```sh

kubectl run test-client --image=busybox --restart=Never -it -- sh
wget -qO- nginx-service
exit
```

## Probes

### Setting up correct probes

```yml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deploy
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
          livenessProbe:
            httpGet:
              path: /
              port: 80
            initialDelaySeconds: 5
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /
              port: 80
            initialDelaySeconds: 5
            periodSeconds: 5

```

```sh

kubectl describe pod nginx-deploy

```

### Breaking the probes

```sh

  livenessProbe:
	httpGet:
	  path: /wrong-path
	  port: 80
	initialDelaySeconds: 5
	periodSeconds: 10

```
=> keeps on restarting the pod

```sh
kubectl rollout undo deployment/nginx-deploy
```

```sh
  readinessProbe:
	httpGet:
	  path: /wrong-path
	  port: 80
	initialDelaySeconds: 5
	periodSeconds: 5
```
=> traffic will never be routed to this pod, pod is never ready, no restarts

```sh

kubectl run -it busybox --image=busybox --restart=Never -- sh
# Inside busybox
wget --timeout=1 nginx-service

```

## Loadbalancer service

```yml

apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  type: LoadBalancer
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```

```sh

kubectl apply -f .\loadbalancer-service.yml
kubectl get svc

```

### Edit HTML in pod

```sh

kubectl get pods

kubectl exec --stdin --tty <pod-name> -- /bin/sh

	cd /usr/share/nginx/html
	printf 'I was here' > index.html.html

```

### Deploy with ConfigMap

```yaml

apiVersion: v1
kind: ConfigMap
metadata:
  name: custom-html
data:
  index.html: |
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Welcome to Kubernetes</title>
      <style>
        body {
          background: #f9fafb;
          font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
          margin: 0;
          padding: 0;
          display: flex;
          align-items: center;
          justify-content: center;
          height: 100vh;
        }
        .card {
          background: white;
          padding: 2rem 3rem;
          box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
          border-radius: 12px;
          text-align: center;
          max-width: 500px;
        }
        h1 {
          color: #2563eb;
          font-size: 2rem;
          margin-bottom: 1rem;
        }
        p {
          color: #4b5563;
          font-size: 1.1rem;
        }
        .footer {
          margin-top: 2rem;
          font-size: 0.9rem;
          color: #9ca3af;
        }
      </style>
    </head>
    <body>
      <div class="card">
        <h1>👋 Hello from Kubernetes!</h1>
        <p>This web page is being served from a ConfigMap.</p>
        <div class="footer">
          Author: Baptiste
          Served by NGINX on AKS
        </div>
      </div>
    </body>
    </html>

```

```sh

kubectl apply -f .\configmap.yml

```

```yml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deploy
spec:
  replicas: 1
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
          volumeMounts:
            - name: html
              mountPath: /usr/share/nginx/html/index.html
              subPath: index.html
      volumes:
        - name: html
          configMap:
            name: custom-html

```


```sh

kubectl apply -f .\deployment-configmap.yml

```