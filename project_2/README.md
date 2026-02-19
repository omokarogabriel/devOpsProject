# Project 2 — 3‑Tier Application with Ingress, TLS, Rolling Updates, Resource Management

## Task
• Deploy a full 3-tier app on k8s
• Add Ingress + SSL
• Perform rolling updates & rollbacks

This repository folder describes how to deploy a three‑tier application (Frontend, Backend/API, Database) within Kubernetes, secure the frontend with TLS via cert‑manager, perform safe rolling updates and rollbacks, and manage resources with ResourceQuotas and LimitRanges.

Sections
- Architecture
- Manifests & Networking
- Resource Management (ResourceQuota & LimitRange)
- Ingress + TLS (cert‑manager + Let's Encrypt)
- Rolling updates & Rollbacks
- Quick commands (apply / test / cleanup)
- Recommendations

## Architecture

- Frontend (Tier 1): static UI served by Nginx or a Node-based server. Exposed only via Ingress.
- Backend/API (Tier 2): application logic (Node, Python, Java). Talked-to by frontend internally.
- Database (Tier 3): Postgres/Mongo/Redis. Not exposed externally; use StatefulSet if persistence and stable network identity are required.

## Manifests & Networking

- Use `Deployment` for frontend and backend. Use `StatefulSet` for the database when needed.
- Use `ClusterIP` Services to keep tiers internal:
  - `frontend-svc`: ClusterIP → port 80
  - `backend-svc`: ClusterIP → port 8080
  - `db-svc`: ClusterIP → postgres 5432

Example Service (ClusterIP):

```yaml
apiVersion: v1
kind: Service
metadata:
  name: backend-svc
spec:
  type: ClusterIP
  selector:
    app: backend
  ports:
  - port: 8080
    targetPort: 8080
```

Include readiness and liveness probes on frontend and backend pods to ensure healthy traffic shifting during rollouts.

## Resource Management (ResourceQuota & LimitRange)

### LimitRange
Automatically applies default resource limits to containers in the namespace:

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: project2-limitrange
  namespace: project-2
spec:
  limits:
  - default:
      cpu: 500m
      memory: 512Mi
    defaultRequest:
      cpu: 200m
      memory: 256Mi
    max:
      cpu: "2"
      memory: 2Gi
    type: Container
```

### ResourceQuota
Sets namespace-level resource limits:

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: project2-quota
  namespace: project-2
spec:
  hard:
    requests.cpu: "4"
    requests.memory: 8Gi
    limits.cpu: "8"
    limits.memory: 16Gi
    pods: "10"
```

All deployments use LimitRange defaults by omitting explicit resource specifications.

## Ingress + TLS (cert‑manager)

1. Install an Ingress controller (nginx‑ingress) if not present. Example (cloud):

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml
```

2. Install cert‑manager (for automated TLS certs):

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
```

3. Create a ClusterIssuer for Let’s Encrypt (example using staging for testing):

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    email: your-email@example.com
    privateKeySecretRef:
      name: letsencrypt-staging
    solvers:
    - http01:
        ingress:
          class: nginx
```

4. Create an Ingress that references TLS and the issuer (example):

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: frontend-ingress
  annotations:
    kubernetes.io/ingress.class: "nginx"
    cert-manager.io/cluster-issuer: "letsencrypt-staging"
spec:
  tls:
  - hosts:
    - myapp.example.com
    secretName: myapp-tls
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-svc
            port:
              number: 80
```

Notes:
- For production use `letsencrypt-production` and update the ClusterIssuer `server` to the production ACME endpoint.
- DNS must point `myapp.example.com` to your Ingress controller (LB) IP for validation to succeed.

## Rolling Updates

All deployments and StatefulSets are configured with rolling update strategies:

**Deployments (frontend & backend):**
```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1
    maxUnavailable: 0
revisionHistoryLimit: 10
```

**StatefulSet (postgres):**
```yaml
updateStrategy:
  type: RollingUpdate
  rollingUpdate:
    partition: 0
revisionHistoryLimit: 10
```

To update an image and watch rollout:

```bash
kubectl set image deployment/backend-deployment backend=my-backend:2.0 -n my-namespace
kubectl rollout status deployment/backend-deployment -n my-namespace
```

## Rollbacks

All resources keep 10 revisions for rollback capability:

```bash
# Rollback deployments
kubectl rollout undo deployment/frontend-deployment -n project-2
kubectl rollout undo deployment/backend-deployment -n project-2

# Rollback StatefulSet
kubectl rollout undo statefulset/postgres -n project-2

# View rollout history
kubectl rollout history deployment/backend-deployment -n project-2
```

## Quick commands (apply / test / cleanup)

```bash
# apply all manifests in k8s/ directory
kubectl apply -f k8s/

# test frontend locally (bypass Ingress)
kubectl port-forward svc/frontend-service -n project-2 8080:80

# cleanup
kubectl delete namespace project-2
```

## Recommendations (portfolio / production)

- ✅ Readiness/liveness probes configured for reliable rollouts
- ✅ ResourceQuota and LimitRange for resource management
- ✅ Rolling update strategies with zero downtime (maxUnavailable: 0)
- ✅ Rollback capability with 10 revision history
- Add CI/CD to build images and perform automated rollouts
- Add monitoring (Prometheus) and centralized logging (ELK/Grafana)
- Use PodDisruptionBudgets for high availability

---
