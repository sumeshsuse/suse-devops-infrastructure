# AWS Two-Tier Infrastructure — Terraform

---

## Why I Built This

I got tired of seeing cloud setups that lived entirely inside someone's head — or worse, inside the AWS console with no record of what was clicked, when, or why.

This project is my answer to that. Every resource is code. Every change is tracked. Every environment is reproducible. If something breaks, I can tear it down and bring it back in minutes — not hours of clicking through menus trying to remember what the setup looked like.

It is also how I think infrastructure should be done: modular, version-controlled, and separated by environment so a mistake in dev never touches prod.

---

## What It Builds

A two-tier AWS setup — a web server that faces the internet, and a backend server that does not. They live in the same VPC but in different subnets, and the security groups are wired so the backend only accepts traffic from the web server. Nothing from the internet can reach the backend directly.

```
                        Internet
                            │
                    ┌───────▼────────┐
                    │ Internet Gateway│
                    └───────┬────────┘
                            │
              ┌─────────────▼──────────────┐
              │         VPC 10.0.0.0/16    │
              │                            │
              │  ┌─────────────────────┐   │
              │  │   Public Subnet      │   │
              │  │   10.0.1.0/24       │   │
              │  │   us-east-1a        │   │
              │  │                     │   │
              │  │   [ Web Server ]    │   │
              │  │   Port 80 / 443     │   │
              │  └──────────┬──────────┘   │
              │             │              │
              │       SSH + Port 8080      │
              │       (Web SG only)        │
              │             │              │
              │  ┌──────────▼──────────┐   │
              │  │   Private Subnet    │   │
              │  │   10.0.2.0/24      │   │
              │  │   us-east-1b       │   │
              │  │                    │   │
              │  │  [ Backend Server ]│   │
              │  │   Port 8080        │   │
              │  └────────────────────┘   │
              └────────────────────────────┘
```

The web server is publicly reachable. The backend is not. That separation is enforced at the security group level — the backend's inbound rules reference the web security group ID, not a CIDR block. So even if you know the backend's IP address, you cannot get to it unless you are coming through the web server.

---

## How It Is Organised

I split everything into reusable modules. The first time I wrote this as one big file and it became unmanageable fast — changing the VPC CIDR meant hunting through fifty lines of code. Modules fixed that.

```
.
├── dev/                     # Everything for the dev environment
│   ├── main.tf              # Calls the modules, sets up the backend
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars     # Dev values — smaller instances, dev CIDRs
│
├── prod/                    # Same structure, different values
│   ├── main.tf
│   ├── variables.tf
│   └── terraform.tfvars     # Prod values — larger instances, prod CIDRs
│
└── modules/
    ├── vpc/                 # VPC, subnets, internet gateway, route tables
    ├── ec2/                 # Web server and backend server instances
    └── security/            # Security groups and their rules
```

Dev and prod call the exact same modules. The only difference is what goes into `terraform.tfvars`. That is the point — the infrastructure logic lives once, and the environment-specific values live separately.

---

## Security Groups — The Important Bit

This is where most people cut corners. I did not.

**Web server** — publicly accessible:
| Port | From | Why |
|------|------|-----|
| 80 | Internet | HTTP |
| 443 | Internet | HTTPS |
| 22 | Internet | SSH management |

**Backend server** — locked down:
| Port | From | Why |
|------|------|-----|
| 8080 | Web SG only | Application traffic |
| 22 | Web SG only | SSH only via web server |

The backend has no direct internet exposure at all. Its security group references the web security group as the source — not `0.0.0.0/0`. That is an important distinction.

---

## State Management

Running Terraform locally with a local state file works until it does not — the moment a second person runs `terraform apply`, you have a conflict and potentially a corrupted state.

Remote state in S3 with DynamoDB locking solves this properly:

```hcl
backend "s3" {
  bucket         = "suse-terraform-state-2026"
  key            = "dev/terraform.tfstate"
  region         = "us-east-1"
  dynamodb_table = "suse-terraform-lock"
  encrypt        = true
}
```

The DynamoDB table holds a lock while any apply is running. A second apply cannot start until the first one finishes and releases the lock. Dev and prod have separate state keys so they never interfere with each other.

---

## Running It

You need Terraform 1.0+, the AWS CLI configured, and an S3 bucket and DynamoDB table already created for the backend.

```bash
# Dev
cd dev
terraform init
terraform plan
terraform apply

# Prod
cd prod
terraform init
terraform plan
terraform apply

# Tear down
terraform destroy
```

---

## Environments

| | Dev | Prod |
|--|-----|------|
| VPC | 10.0.0.0/16 | 10.1.0.0/16 |
| Public subnet | 10.0.1.0/24 | 10.1.1.0/24 |
| Private subnet | 10.0.2.0/24 | 10.1.2.0/24 |
| Instance size | t2.micro | t2.medium |
| State file | dev/terraform.tfstate | prod/terraform.tfstate |

---

## About Me

I am Sumesh — a Cloud DevOps Engineer with a background in software delivery, currently focused on AWS, Kubernetes and infrastructure automation. I hold the CKAD, AWS Solutions Architect Associate and Terraform Associate certifications.

This repo is part of a broader portfolio of hands-on cloud and DevOps projects I have been building while transitioning fully into cloud engineering.

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Sumesh_Suseelan-0077B5?logo=linkedin)](https://linkedin.com/in/sumeshsuseelan)
[![GitHub](https://img.shields.io/badge/GitHub-sumeshsuse-181717?logo=github)](https://github.com/sumeshsuse)
