# Fastcampus - System Designs with Anti-Patterns

## Instruction

### Preliminary

1. Create your AWS credentials and store them safely.
2. Create a file named `secrets.tfvars` inside the directory `infrastructure`.
3. Fill the file as below:
    ```
    aws_access_key = "YOURAWSACCESSKEY"
    aws_secret_key = "YOURAWSSECRETACCESSKEY"
    ```
4. Move inside the `infrastructure` directory and enter `terraform init` in your terminal.

### Terraform plan and apply

- To plan the infrastructure definitions, enter `terraform plan -var-file=secrets.tfvars` inside the terraform root.
- To apply the plan results, issue the command `terraform apply -var-file=secrets.tfvars`.

### Access the EKS cluster

1. Install AWS CLI and kubectl.
2. Register your AWS credentials as a profile in your AWS CLI configuration file.
3. Enter `aws eks --region ap-northeast-2 update-kubeconfig --name fc-sre-cluster` to register your cluster to the `kubectl` configuration.
    - If you're using a profile other than the default profile, you should append `--profile your-profile` on the command above.
4. Enter `kubectl config use-context arn:aws:eks:ap-northeast-2:1234567890:cluster/fc-sre-cluster` (change `1234567890` to your account ID).
5. Check `kubectl get nodes`

### Destroying resources

To destory all the resources that have been provisioned, make sure issuing `terraform destroy -var-file=secrets.tfvars`.