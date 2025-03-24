# SalesApp Deployment with Terraform

## Overview
This project provisions a low-cost Azure VM, configures IIS, and deploys SalesApp (.NET 9 Web API) and ASPIRE.

## Prerequisites
- Terraform installed
- Azure CLI installed and logged in
- Service principal credentials

## Usage
1. Clone this repository.
2. Update `terraform.tfvars` with your Azure credentials.
3. Run the following commands:
   ```bash
   terraform init
   terraform plan
   terraform apply