
# MongoDB on EKS (Modular IaC) — Minimal Runnable (AWS)

This is a **minimal, runnable, modular** IaC solution matching the provided diagram:

- EKS cluster across **3 Availability Zones**
- Dedicated MongoDB node group with **taint** `dedicated=mongodb:NoSchedule` and **label** `workload=mongodb`
- Encrypted gp3 storage (EBS CSI)
- Percona MongoDB Operator (Helm)
- MongoDB Replica Set (3 nodes) with AZ anti-affinity
- PBM backups to S3 using **IRSA** (no static AWS keys)
- Optional monitoring via kube-prometheus-stack

> **Costs:** EKS + EC2 nodes cost money. Run `terraform destroy` after validation.

## Prerequisites
- Terraform >= 1.5
- AWS CLI configured
- kubectl
- Helm

## Deploy Infrastructure (Terraform)
```bash
cd terraform
terraform init
terraform validate
terraform plan
terraform apply
```

## Configure kubectl
```bash
aws eks update-kubeconfig --region us-east-1 --name mongodb-iac-eks
kubectl get nodes
```

## Deploy MongoDB (Kubernetes)
1) Get the backup bucket created by Terraform:
```bash
terraform -chdir=terraform output -raw s3_backup_bucket
```

2) Edit `kubernetes/mongodb-psmdb.yaml` and replace `REPLACE_ME_BUCKET` with the output bucket name.

3) Apply manifests:
```bash
kubectl apply -f kubernetes/namespace.yaml
kubectl apply -f kubernetes/storageclass-gp3.yaml
kubectl apply -f kubernetes/mongodb-psmdb.yaml
```

4) Verify:
```bash
kubectl -n database get pods
kubectl -n database get psmdb
```

## Modules (3 points)
- `modules/eks`     → VPC (3 AZs) + EKS + dedicated MongoDB node group + EBS CSI add-on
- `modules/storage` → KMS key + S3 bucket for PBM backups
- `modules/platform`→ IRSA role + Kubernetes ServiceAccount + Helm installs (cert-manager, Percona Operator, optional monitoring)

## Destroy
```bash
cd terraform
terraform destroy
```
