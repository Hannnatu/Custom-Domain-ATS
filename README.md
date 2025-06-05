# Custom-Domain-ATS
This project is a complete serverless platform built using **AWS**, **Terraform**, **GitHub Actions (CI/CD)**, and a minimal **frontend** to support domain submissions and automatic secure (HTTPS) hosting via **CloudFront + ACM**.

---

## 🌐 Overview

* **Users** land on a static welcome page hosted via CloudFront (HTTPS).
* They can **submit a custom domain** through a form.
* The backend, powered by **Lambda + API Gateway**, writes the domain to **DynamoDB**.
* Infrastructure is fully deployed using **Terraform**, with **CI/CD** triggered on every push.
* All activity is **monitored** via CloudWatch Logs and Alarms.

---

## 🧠 Architecture Diagram

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

## 🛠 Developer Breakdown

### 📁 Project Structure

```
project-root/
├── terraform/              # All Terraform infra code
│   ├── main.tf
│   └── lambda.zip          # Built from `lambda/`
├── lambda/                 # Lambda function code
│   └── handler.py
├── frontend/               # Frontend HTML
│   └── index.html
└── .github/workflows/      # GitHub Actions CI/CD
    └── deploy.yml
```

---

## 🏗️ Step-by-Step: How It Works

### 👨‍💻 Developer Flow

1. **Write Code**: Modify frontend, lambda, or Terraform files.
2. **Push to GitHub**: Triggers GitHub Actions workflow.
3. **GitHub Actions Steps**:

   * Checkout repo
   * Setup Terraform
   * Zip Lambda
   * Run Terraform to deploy infrastructure
4. **AWS Infrastructure** is updated: Lambda, API Gateway, S3, CloudFront, etc.

### 🧑‍💻 User Flow

1. User visits `https://yourdomain.com`
2. Sees welcome page (index.html)
3. Submits a form with a domain (e.g. `hannatu.com`)
4. Lambda handles request, stores domain in DynamoDB
5. Response returned within \~5s with success message

---

## ⚙️ Technologies Used

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

## 📈 Monitoring & Observability

* **Lambda Logs**: CloudWatch log group `/aws/lambda/domain_api`
* **Error Alarms**: Triggered if Lambda throws any error in production
* **CloudFront Logs**: Delivered to a dedicated S3 logging bucket
* **SNS Integration**: Can be added for email/SMS alerts

---

## ✅ Setup Instructions

### 1. Clone Repo

```bash
git clone https://github.com/YOUR_USERNAME/ Custom-Domain-ATS.git .git
cd  Custom-Domain-ATS.git 
```

### 2. Set Variables in Terraform

Update `terraform/main.tf`:

```hcl
variable "domain_name" {
  default = "yourdomain.com"
}

variable "hosted_zone_id" {
  default = "ZXXXXXXXXXXXX"
}
```

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

## 💡 Notes

* `lambda/handler.py` contains the logic for handling domain submissions.
* `frontend/index.html` is the public welcome page where users interact.
* DNS propagation may take a few minutes after CloudFront setup.
* SSL certificates must be requested in **us-east-1** for CloudFront.

---

## 📜 License

MIT License. Feel free to use, extend, and improve!
