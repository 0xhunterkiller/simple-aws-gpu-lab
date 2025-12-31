# simple-aws-gpu-lab

A simple AWS EC2 based GPU lab for self-hosting AI. This repository contains Terraform (HCL) to provision one or more GPU-enabled EC2 instances suitable for running model training/inference and self-hosted AI services (Jupyter, web UIs, model servers).

---

## Features
- Provision GPU-backed EC2 instance(s) with configurable instance type and storage.
- Create security group, key pair usage, and optional user-data to bootstrap the instance.
- Minimal, opinionated configuration so you can customize for your workflows.

## Requirements
- Terraform 1.0+ (install: https://learn.hashicorp.com/terraform)
- An AWS account and an IAM user with permissions to create EC2, VPC (or use existing), IAM (if required), EBS volumes, and Security Groups.
- AWS CLI configured with credentials (or export AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY and AWS_REGION).
- An existing AWS key pair (or create one in the AWS console) to SSH into the instance.

Optional: Familiarity with selecting GPU AMIs (AWS Deep Learning AMIs, Ubuntu images with NVIDIA drivers, or custom AMIs).

## Before you begin
1. Confirm AWS credentials are configured locally: `aws sts get-caller-identity` should return your account.
2. Choose an AWS region that has the GPU instance types you want (e.g., g4, g5, p3, p4 families).
3. Ensure your account has sufficient instance quota for the chosen instance type.
4. Decide which AMI you want to use. Recommended options:
   - AWS Deep Learning AMIs (preinstalled frameworks and drivers)
   - Ubuntu 22.04 / 20.04 + NVIDIA drivers installed via user-data
   - Marketplace GPU images specifically tailored for CUDA/CuDNN support

Tip: You can use SSM Parameter Store to find official deep learning AMIs, or pick a community/Marketplace AMI. Make sure the AMI supports the instance type (ENA, NVMe, and GPU drivers where necessary).

## Quick start
1. Clone the repo:

   ```bash
   git clone https://github.com/0xhunterkiller/simple-aws-gpu-lab.git
   cd simple-aws-gpu-lab
   ```

2. Inspect variables and example files (look for `variables.tf`, `main.tf`, `outputs.tf` in the repo) to see what options are exposed.

3. Create a `terraform.tfvars` file (or pass `-var` flags) to provide required values. Example `terraform.tfvars`:

   ```hcl
   aws_region = "us-west-2"
   key_name   = "my-aws-key"
   instance_type = "g4dn.xlarge"
   ami_id = "ami-0123456789abcdef0" # replace with a GPU-capable AMI for your region\   
   root_volume_size = 100
   
   # Optional
   vpc_id = ""      # if you want to use an existing VPC
   subnet_id = ""   # optional subnet id to place the instance in
   ```

4. Initialize Terraform and apply:

   ```bash
   terraform init
   terraform plan -var-file="terraform.tfvars"
   terraform apply -var-file="terraform.tfvars" -auto-approve
   ```

5. After apply completes, Terraform outputs will include the public IP / DNS of the instance and any other outputs configured. SSH into the instance:

   ```bash
   ssh -i ~/.ssh/my-aws-key.pem ubuntu@<instance-public-ip>
   ```

(Replace `ubuntu` with the appropriate default user for your AMI, e.g., `ec2-user`, `ubuntu`, `admin`, etc.)

## Ports and access
- The Terraform config creates a security group that may open SSH (22) and optional ports for web UIs (e.g., 8888 for Jupyter, 7860 for some web UIs).
- For security, restrict SSH to your IP or VPN and avoid opening management ports to the public. Use SSH tunnels or a reverse proxy if you must access services remotely.

Example SSH tunnel for Jupyter (remote port 8888):

```bash
ssh -i ~/.ssh/my-aws-key.pem -L 8888:localhost:8888 ubuntu@<instance-public-ip>
# then access http://localhost:8888 in your browser
```

## Customizing user-data / bootstrapping
If the config includes user-data, it can install drivers, CUDA, Docker, and common AI tooling (e.g., Anaconda, Miniconda, Docker + nvidia-container-toolkit). Check `user_data` in the Terraform files and adjust to your needs.

Notes:
- Installing NVIDIA drivers and CUDA during first boot may take a while. Consider creating a golden AMI with drivers preinstalled to speed provisioning.
- If using Docker, configure the NVIDIA Container Toolkit to expose GPUs to containers.

## Storage
- The instance uses an EBS root volume (size configurable). Increase `root_volume_size` if you plan to store large models or datasets.
- For persistent large data, consider attaching additional EBS volumes or using Amazon FSx/EFS (not covered by default).

## Cost and cleanup
GPU instances are expensive. To avoid unexpected charges:
- Stop or terminate instances when not in use.
- Use `terraform destroy -var-file="terraform.tfvars"` to tear down resources created by Terraform.
- Track attached EBS volumes and snapshots to avoid leftover storage costs.

Example cleanup:
```bash
terraform destroy -var-file="terraform.tfvars" -auto-approve
```

## Troubleshooting
- Instance does not show GPU devices
  - Ensure the chosen AMI includes NVIDIA drivers or install them via user-data/SSH.
  - Verify the instance type actually includes a GPU (e.g., g4, g5, p3).
  - Check `nvidia-smi` on the instance to confirm GPUs are available.

- SSH connection timed out
  - Confirm security group allows your IP on port 22.
  - Confirm the instance has a public IP or you’re on the same VPC/subnet or have a bastion host.

- Terraform apply fails due to quotas or limits
  - Check AWS service quotas for the chosen instance family/region and request limit increases if needed.

## Security considerations
- Do not hard-code AWS credentials in files committed to the repo. Use environment variables or a credentials file excluded by .gitignore.
- Restrict SSH and management ports to known, limited IP ranges.
- Consider enabling EBS volume encryption for sensitive data.

## Extending this project
- Add module support for multi-instance clusters or autoscaling groups.
- Integrate with AWS S3 for model and dataset storage.
- Add an AMI build pipeline (Packer) to bake GPU drivers and dependencies into a golden AMI.

## License
This repository does not include a license file by default. Add a LICENSE file if you want to specify terms.

## Contributing
Contributions are welcome. Please open issues or PRs with improvements, bug fixes, or documentation updates.
