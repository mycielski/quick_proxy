# Squid proxy on AWS

This repository contains Terraform code for creating a Squid proxy on AWS.

## Usage

1. Create a `terraform.tfvars` file with the following content:

    ```terraform
    profile = # your profile from ~/.aws/credentials
    region = # aws region to deploy into
    instance_type = # instance type to use, fyi works on t4g.nano
    proxy_username = # username used to connect to proxy
    proxy_password = # password used to connect to proxy
    ```
2. Adjust `squid.conf` file to match your needs.
3. `terraform init` and `terraform apply`.
4. Enjoy your new proxy!

