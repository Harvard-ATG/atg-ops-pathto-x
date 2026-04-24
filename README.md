# atg-ops-pathto-x

Infrastructure-as-code for the pathto-x website. Source code is at https://github.com/pathto-x/pathto-x.github.io.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.9 (see `.terraform-version` for the pinned version)
- AWS credentials configured with sufficient permissions to manage the resources in this repo

## Deploying infrastructure changes

Initialize the working directory (only needed on first use or after provider version changes):

```sh
terraform -chdir=terraform init
```

Preview changes before applying:

```sh
terraform -chdir=terraform plan -out tf.plan
```

Apply changes as planned:

```sh
terraform -chdir=terraform apply tf.plan
```

## First-time setup: authorizing the GitHub connection

After the first `terraform apply`, the AWS CodeConnections connection (`pathto-x-github`) will be in a `PENDING` state and the CodePipeline will not run until it is authorized. To complete the setup:

1. Go to the AWS Console → **CodePipeline** → **Settings** → **Connections**
2. Find `pathto-x-github` and click **Update pending connection**
3. Follow the prompts to authorize the GitHub App on the `pathto-x` organization

This step only needs to be done once.
