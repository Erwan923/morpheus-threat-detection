# Morpheus Threat Detection - Terraform Deployment

## Prerequisites

1. AWS CLI configured with credentials
2. Terraform installed (v1.0+)
3. SSH key pair created in AWS

## Quick Start
```bash
# Initialize Terraform
terraform init

# Create SSH key if needed
aws ec2 create-key-pair --key-name morpheus-key --query 'KeyMaterial' --output text > ~/.ssh/morpheus-key.pem
chmod 400 ~/.ssh/morpheus-key.pem

# Plan deployment
terraform plan -var="key_name=morpheus-key"

# Deploy
terraform apply -var="key_name=morpheus-key" -auto-approve
```

## Configuration

Edit `terraform.tfvars`:
```hcl
instance_type     = "g4dn.xlarge"
spot_instance     = true
spot_max_price    = "0.50"
allowed_ssh_cidr  = "YOUR_IP/32"
```

## Outputs

After deployment, get instance details:
```bash
terraform output
```

## Connect to Instance
```bash
ssh -i ~/.ssh/morpheus-key.pem ubuntu@$(terraform output -raw instance_public_ip)
```

## Cost Optimization

- **Spot instance**: ~70% cheaper than on-demand
- **g4dn.xlarge**: ~$0.30/hour (spot) vs ~$0.526/hour (on-demand)
- Don't forget to destroy when not in use!

## Destroy Infrastructure
```bash
terraform destroy -auto-approve
```
