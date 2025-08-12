``` shell
aws sso login --profile butterthon-dev
export AWS_PROFILE=butterthon-dev
terraform plan -var-file="secret.tfvars"
terraform apply -var-file="secret.tfvars"
```
