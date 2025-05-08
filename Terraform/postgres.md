


#  Infrastructure Architecture – EC2 + RDS PostgreSQL with Terraform

## Overview

This architecture securely provisions a PostgreSQL database using Amazon RDS and an EC2-based application environment. The setup is managed using Terraform and supports high availability and secure access through a bastion host and private networking.

---

## Network Architecture

- **VPC CIDR**: `10.0.0.0/16`
- **Subnets**:
  - **Public Subnet**: `10.0.1.0/24` (Availability Zone: `us-east-1a`)
  - **Private Subnets**:
    - `10.0.2.0/24` (`us-east-1a`)
    - `10.0.3.0/24` (`us-east-1b`)
    - `10.0.4.0/24` (`us-east-1c`)
- **Internet Gateway**: Provides internet access to the public subnet.
- **NAT Gateway**: Allows outbound internet access for private subnets.
![image](https://github.com/user-attachments/assets/b6d31232-9789-43a2-b3be-0a6c1ac1cc11)
---

## 🧩 Components

### 1. 🛡️ Bastion Host
- EC2 instance in the **public subnet** with SSH access from the internet.
- Used to securely jump into private instances (App EC2).
- Security Group allows SSH (`port 22`) from `0.0.0.0/0`.

![image](https://github.com/user-attachments/assets/02b52689-47d6-460c-9cfc-c07e2c8e60e5)

### 2. 💻 Application EC2
- EC2 instance in **private subnet** (`10.0.2.0/24`).
- PostgreSQL client installed.
- Connected to RDS via private IP.
- No public IP; accessible only via Bastion or AWS SSM.
- Attached to SSM IAM role for secure remote access.

### 3. 🐘 RDS PostgreSQL
- Multi-AZ deployment using 3 private subnets.
- Engine: `PostgreSQL 16.5`
- Not publicly accessible.
- Security Group allows traffic only from App EC2 security group on port `5432`.
- DB Subnet Group configured for high availability.

---

## Security Groups

| Component   | Allowed Ingress From | Ports       |
|-------------|----------------------|-------------|
| Bastion     | 0.0.0.0/0            | 22 (SSH)    |
| App EC2     | Bastion SG           | 22 (SSH)    |
| RDS         | App EC2 SG           | 5432 (Postgres) |

---

## Connectivity Flow

1. **SSH to Bastion**:
   ```bash
   ssh -i ak.pem ubuntu@<bastion-public-ip>
   ```

2. **SSH to App EC2 from Bastion**:

   ```bash
   ssh -i ak.pem ubuntu@<app-private-ip>
   ```

3. **Connect to RDS from App EC2**:

   ```bash
   psql -h <rds-endpoint> -U akadmin -d akdb
   # or with SSL:
   psql "host=<rds-endpoint> port=5432 user=akadmin dbname=akdb sslmode=require"
   ```

---

![image](https://github.com/user-attachments/assets/4728e9fc-9126-4ae2-995b-e8796650262d)

## Highlights

*  **Secure by design**: Private subnets, controlled SG rules, SSM access.
*  **HA-ready**: RDS deployed across 3 availability zones.
*  **IaC**: Entire infra defined and reproducible via Terraform.
* **Separation of concerns**: Bastion, App, and DB are isolated with clear access rules.

---

