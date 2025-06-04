Awesome! Your image `libertytestecr:latest` is successfully pushed to ECR ✅

Now let’s **run it inside your EKS cluster as a Pod**.

---

## 🚀 Kubernetes Manifest to Run ECR Image as a Pod

Create a file called:

```bash
libertytestecr-pod.yaml
```

With the following content:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: libertytester
spec:
  containers:
  - name: libertytester
    image: 333661424489.dkr.ecr.us-east-2.amazonaws.com/libertytestecr:latest
    imagePullPolicy: Always
    command: ["/bin/sh"]
    args: ["-c", "echo Hello from libertytester ECR image && sleep 3600"]
```

---

## 📌 How to Apply

```bash
kubectl apply -f libertytestecr-pod.yaml
```

Check status:

```bash
kubectl get pods
kubectl describe pod libertytester
kubectl logs libertytester
```

---

## 🔐 Ensure EKS Nodes Have Pull Access to ECR

Your EKS worker node IAM role must have this policy attached:

```json
{
  "Effect": "Allow",
  "Action": [
    "ecr:GetDownloadUrlForLayer",
    "ecr:BatchGetImage",
    "ecr:BatchCheckLayerAvailability"
  ],
  "Resource": "*"
}
```

✅ If you attached the `AmazonEC2ContainerRegistryReadOnly` policy, you’re already good.

---

## ✅ What You’ll See

After running the pod, `kubectl logs libertytester` should show:

```
Hello from libertytester ECR image
```

---

Let me know if you want to convert this into a **Helm chart**, **K8s deployment with LoadBalancer**, or expose it over **HTTPS with Ingress**.
