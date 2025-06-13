# Custom-Domain-Ats

This project is a complete serverless platform built using **AWS**, **Terraform**, **GitHub Actions (CI/CD)**, and a minimal **frontend** to support domain submissions and automatic secure (HTTPS) hosting via **CloudFront + ACM**.

---

## Overview

* **Users** land on a static welcome page hosted via CloudFront (HTTPS).
* They can **submit a custom domain** through a form.
* The backend, powered by **Lambda + API Gateway**, writes the domain to **DynamoDB**.
* Infrastructure is fully deployed using **Terraform**, with **CI/CD** triggered on every push.
* All activity is **monitored** via CloudWatch Logs and Alarms.

---

## Architecture Diagram

```
+---------+     +-------------+     +------------------+
|         |     |  API GW +   |     |  CloudWatch Logs |
|  User   +---> |  Lambda     +---> |  & Alarms         |
|         |     +-------------+     +------------------+
     |               |
     v               v
+----------+     +----------+
|  S3      |<----+  Terraform|
|  Static  |     +----------+
|  Hosting |
+----+-----+
     |
     v
+------------+
| CloudFront |
| + ACM Cert |
+------------+
     |
     v
+------------+
| Custom DNS |
| (Route53)  |
+------------+
```

---

### 📁 Project Structure

```
custom-domain-ats/
├── terraform/              # All Terraform infra code
│   ├── main.tf
│   ├── variables.tf        # Terraform variables
│   └── lambda.zip          # Built from `lambda/`
├── lambda/                 # Lambda function code
│   └── handler.py
├── frontend/               # Frontend HTML
│   └── index.html
└── .github/workflows/      # GitHub Actions CI/CD
    └── deploy.yml
```

---

##Step-by-Step: How It Works

### Developer Flow

1. **Write Code**: Modify frontend, lambda, or Terraform files.
2. **Push to GitHub**: Triggers GitHub Actions workflow.
3. **GitHub Actions Steps**:

   * Checkout repo
   * Setup Terraform
   * Zip Lambda
   * Run Terraform to deploy infrastructure
4. **AWS Infrastructure** is updated: Lambda, API Gateway, S3, CloudFront, etc.

### User Flow

1. User visits `https://yourdomain.com`
2. Sees welcome page (index.html)
3. Submits a form with a domain (e.g. `homerunner.com`)
4. Lambda handles request, stores domain in DynamoDB
5. Response returned within \~5m with success message

---

## ⚙Technologies Used

* **Terraform**: Infrastructure as Code
* **AWS Services**:

  * Lambda (Python)
  * API Gateway (REST)
  * S3 (Static Hosting)
  * CloudFront (CDN + HTTPS)
  * ACM (Certificates)
  * DynamoDB (Data Storage)
  * CloudWatch (Logs + Monitoring)
  * Route53 (DNS)
* **GitHub Actions**: CI/CD Pipeline

---

## Monitoring & Observability

* **Lambda Logs**: CloudWatch log group `/aws/lambda/domain_api`
* **Error Alarms**: Triggered if Lambda throws any error in production
* **CloudFront Logs**: Delivered to a dedicated S3 logging bucket
* **SNS Integration**: Can be added for email/SMS alerts

---

## ✅ Setup Instructions

### 1. Clone Repo

```bash
git clone https://github.com/Hannnatu/custom-domain-ats.git
cd custom-domain-ats
```

### 2. Set Variables in `variables.tf`

Create or edit the file at `terraform/variables.tf`:

```hcl
variable "domain_name" {
  description = "Your main domain name"
  type        = string
  default     = "yourdomain.com"
}

variable "hosted_zone_id" {
  description = "Route53 hosted zone ID for domain"
  type        = string
  default     = "ZXXXXXXXXXXXX"
}
```

> 📝 Replace `yourdomain.com` and `ZXXXXXXXXXXXX` with your actual domain and hosted zone ID.

### 3. Deploy Infrastructure

```bash
cd terraform
terraform init
zip lambda.zip ../lambda/handler.py
terraform apply -auto-approve
```

### 4. Push to GitHub

```bash
git add .
git commit -m "Initial deployment"
git push -u origin main
```

This will trigger the CI/CD pipeline and deploy everything.

---

## 🚧 Constraints & Errors Faced

* **IAM Role Permissions**: Required detailed IAM policies for Lambda, API Gateway, Route53, ACM, CloudWatch.
* **ACM Certificates**: Must be in `us-east-1` for CloudFront compatibility.
* **DNS Propagation Delay**: Custom domains can take 2–10 minutes to reflect.
* **Lambda Build & Zip**: Ensure the Lambda file is zipped and updated before `terraform apply`.
* **S3 + CloudFront TTL**: Static files are cached, so updates may be delayed.

---

## 💸 AWS Costs Incurred

These are the AWS services that may incur cost:

| Service     | Monthly Est. (USD) | Notes                          |
| ----------- | ------------------ | ------------------------------ |
| Lambda      | \~\$0.20           | Per 1M requests & compute time |
| API Gateway | \~\$3.50           | For REST APIs                  |
| S3 Hosting  | \~\$0.10           | Based on storage/requests      |
| CloudFront  | \~\$1–5            | Based on data transfer         |
| ACM         | Free               | Public certificates            |
| DynamoDB    | \~\$1–2            | On-demand write/read units     |
| Route53     | \$0.50/domain      | For hosted zone + DNS queries  |

---

## ✏️ Where to Edit with Your Info

* `variables.tf`: Update domain name and hosted zone ID.
* `frontend/index.html`: Customize your welcome page + input form.
* `lambda/handler.py`: Adjust domain validation or logic.
* `.github/workflows/deploy.yml`: Add your AWS credentials/secrets securely.
* `main.tf`: Link your ACM cert ARN and Route53 records if customizing.
* IMPORTANT: Configure the CNAME record in Route53
Terraform automatically creates a CNAME (or Alias A) record that maps your custom domain (e.g., jobs.yourdomain.com) to the CloudFront distribution domain.
Ensure your hosted zone is correct and that this DNS entry exists for your domain to route traffic properly to CloudFront over HTTPS.
---


## 📜 License

MIT License. Feel free to use, extend, and improve!

