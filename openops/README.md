# Openops deployment using Terraform

Introduction: [OpenOps](https://www.openops.com) is a No-Code FinOps automation platform. It provides customizable workflows to automate various FinOps processes, such as cost optimization, budgeting, forecasting, allocation, and tagging. 
In this project we'll be using terraform to deploy OpenOps, check [official docs](https://docs.openops.com/introduction/overview) for other deployment options.

Objective: Create an EC2 instance on AWS and deploy OpenOps on it. Notify via email once the installation process is finished.

### Prerequisities
- Terraform installed (used Terraform v1.11.4 on linux_amd64)
- access_key and secret_key for aws provider authentication (or any other preferred credential source)

### Resources created
- An EC2 instance (default specs: t3.large, 50GB, ubuntu)
- IAM resources (to enable EC2 instance to publish to SNS topic and also create secret on AWS Secrets Manager)
- SNS topic and subscription
- Secret in AWS Secrets Manager
- SSH key-pair (which will be used to access EC2 instance on which openops will be deployed)

### Steps
- Ensure terraform is installed, create a separate directory and `cd` into it.
- Download the Terraform configuration files (make edits if required).
- Set environment variables to authenticate AWS with Terraform.
  ```sh
  export AWS_ACCESS_KEY_ID="my-access-key"
  export AWS_SECRET_ACCESS_KEY="my-secret-key"
  ```
- Run terraform init, plan and apply.
- By default you are expected to pass value`sns_sbuscrition_email` variable on `terraform apply`.
- You will receive a subscription confirmation email (check spam folder as well), which you'll have to confirm to receive notification after the deployment is finished.
- Deployment of OpenOps typically takes 5–10 minutes after running `terraform apply`.
- Upon successful installation, login credentials are securely stored in AWS Secrets Manager. You can retrieve them using the AWS CLI (e.g., `aws secretsmanager get-secret-value --region <region> --secret-id <secret-name>`), or by accessing the `.env` file directly on the OpenOps EC2 instance.. 
- That's it, login to your OpenOps application and explore.

*Note: This setup is intended for testing only and is not production-ready. Sharing credentials without encryption and proper access controls is unsafe and strongly discouraged.*