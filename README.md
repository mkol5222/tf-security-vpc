# Deploy GWLB load-balanced Check Point Security Gateways into centralized Security VPC

## Goals

## Steps

### 1. AWS Cloud Shell
Open [AWS CloudShell](https://eu-central-1.console.aws.amazon.com/cloudshell/home?region=eu-central-1#) in your region.

### 2. Make sure Terraform is available
```bash
git clone https://github.com/tfutils/tfenv.git ~/.tfenv
mkdir ~/bin
ln -s ~/.tfenv/bin/* ~/bin/
tfenv install
tfenv use
terraform -version
```

### 3. Clone repo
```bash
git clone https://mkol5222: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@github.com/mkol5222/tf-security-vpc.git ~/tf-security-vpc

cd ~/tf-security-vpc
```