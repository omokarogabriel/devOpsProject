## This project deploys an application and expose with a service and ingress

### Manifests in this folder

- `deployment.yaml`: Deployment for the nginx application.
	- Creates `nginx-deployment` with 3 replicas using image `nginx:1.14.2`.
	- Pod template label: `app: nginx` (selected by the Service).
	- Defines container `nginx` listening on `containerPort: 80`.
	- Resource `requests`/`limits` are set for CPU and memory.
	- Environment variables: `ENVIRONMENT=development`, `LOG_LEVEL=info`.
	- Probes:
		- `livenessProbe`: HTTP GET `/` on port 80 with `initialDelaySeconds: 30`, `timeoutSeconds: 5`, `periodSeconds: 10`, `failureThreshold: 3`.
		- `readinessProbe`: HTTP GET `/` on port 80 with `initialDelaySeconds: 5`, `timeoutSeconds: 2`, `periodSeconds: 5`, `failureThreshold: 3`.

- `service.yaml`: Service exposing the nginx pods.
	- Service name: `nginx-service`.
	- Type: `NodePort` (exposes pods externally on node ports).
	- Selector: `app: nginx` matches the Deployment pods.
	- Port mapping: service `port: 80` -> `targetPort: 80` on the pod.

- `ingress.yaml`: Ingress to route external traffic to the Service.
	- apiVersion: `networking.k8s.io/v1` and kind `Ingress`.
	- Host: `nginx.example.com` with a rule for path `/`.
	- Path uses `pathType: Prefix` and routes to backend service `nginx-service` port `80`.
	- Annotation `nginx.ingress.kubernetes.io/rewrite-target: /` is present to rewrite paths.

### Notes

- To validate locally without applying to a cluster:

```bash
kubectl apply --dry-run=client -f project_1/deployment.yaml -f project_1/service.yaml -f project_1/ingress.yaml
```

To apply to a connected cluster:

```bash
kubectl apply -f project_1/deployment.yaml -f project_1/service.yaml -f project_1/ingress.yaml
```

## Viewing the app in a browser - complete steps taken after all manifests have been created

1. Create the namespace used by the manifests:

```bash
## Project 1 — nginx Ingress demo

A small demo that deploys an `nginx` application behind a Kubernetes `Service` and an `Ingress`.

## Prerequisites

- A Kubernetes cluster and `kubectl` configured to talk to it.
- (Optional) An Ingress controller (nginx-ingress) installed to test real hostname routing. You can use `kubectl port-forward` to test without an ingress controller.

## Manifests

- `namespace.yaml` — Namespace `project-1` for isolation.
- `deployment.yaml` — `nginx-deployment` (3 replicas) using `nginx:1.14.2`. Pods labeled `app: nginx` and exposing `containerPort: 80`. Includes resource requests/limits, env vars, liveness and readiness probes.
- `service.yaml` — `nginx-service` of type `NodePort` exposing port `80` (nodePort `30080` configured).
- `ingress.yaml` — Ingress rule for host `nginx.example.com` routing `/` (pathType: `Prefix`) to `nginx-service:80`. Includes rewrite annotation for the nginx ingress controller.

## Apply

Create namespace and apply manifests:

```bash
kubectl apply -f project_1/namespace.yaml
kubectl apply -f project_1/deployment.yaml -n project-1
kubectl apply -f project_1/service.yaml -n project-1
kubectl apply -f project_1/ingress.yaml -n project-1
```

Validate without applying:

```bash
kubectl apply --dry-run=client -f project_1/deployment.yaml -f project_1/service.yaml -f project_1/ingress.yaml
```

## Viewing the app in a browser

Option A — Using an Ingress controller with an external IP (recommended):

1. Install or confirm an Ingress controller (example):

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml
```

2. Get the controller external IP and map it to the host used by the Ingress (`nginx.example.com`):

```bash
# find IP (example service name may vary)
kubectl get svc -n ingress-nginx -o wide
# then add to /etc/hosts (requires sudo)
sudo -- sh -c 'echo "X.X.X.X nginx.example.com" >> /etc/hosts'
```

3. Open `http://nginx.example.com` in your browser.

Option B — Quick local test (bypass Ingress) using port-forward:

```bash
kubectl port-forward svc/nginx-service -n project-1 8080:80 &
# open in browser:
http://localhost:8080
```

To stop the port-forward:

```bash
pkill -f "kubectl port-forward .*8080:80"
```

Quick curl checks:

```bash
# Against ingress IP (if present):
curl -H "Host: nginx.example.com" http://<INGRESS-IP>/

# Against local port-forward:
curl -H "Host: nginx.example.com" http://localhost:8080/
```

## Cleanup

Remove all resources created by this demo:

```bash
kubectl delete namespace project-1
```

## Troubleshooting / Notes

- If the Ingress does not route, ensure an Ingress controller is installed and the Ingress resource is in the correct namespace.
- If you used a `NodePort`, you can also reach the Service via any node IP on the configured nodePort (example: `http://<NODE-IP>:30080`).
- Editing `/etc/hosts` requires `sudo`.
- Adjust probe timings to suit your environment.

## Author

Created for demonstration and portfolio use.
