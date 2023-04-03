#!/bin/bash

# download zip and install it to /usr/local/bin
CLI_BIN_DIR=/usr/local/bin 
CLI_INSTALL_DIR=/usr/local/aws-cli 
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install --bin-dir $CLI_BIN_DIR --install-dir $CLI_INSTALL_DIR --update

# getting an MFA session token (max duration 3 days)
# change to token given on your device.
MFA_TOKEN=999999
aws sts get-session-token --serial-number arn:aws:iam::713113969541:mfa/AWSArgolis \
    --duration-seconds 129600 --token-code $MFA_TOKEN

# example MFA profile in .aws/credentials:
# [mfa]
# aws_access_key_id = ASIA2MCHHUOCRTETLET3
# aws_secret_access_key = arIjWWQwBQD7oIOIb8QwSGHGf9g5N6qs8ft+dlKJ
# aws_session_token = FwoGZXIvYXdzELL//////////wEaDHXb8tDaUvE9W0J+ISKGAXaMkZNZSZqqugn8LDG/cdDKck0p2wRz5KPjkfBlXNT020M+fl9oz+v9Atb64TLBhmXFpgJtWxfiBfvR117SpIVYygxBUgEElsm84RlI17Lp3mCd3TF7jJaTOlYCxb9V5sd5TK3hvRsUImB4Edl1oDGVpR6V88QAO3zmqASDAhD5TKfh7aU7KOD1lqEGMijj+solxN8bQS5kpTtuqtDJnUfFGVMnIXkr14MLxTeSrXLBs03zg3se

# Enable APIs in GCP needed by Anthos
gcloud --project="${PROJECT_ID}" services enable \
gkemulticloud.googleapis.com \
gkeconnect.googleapis.com \
connectgateway.googleapis.com \
cloudresourcemanager.googleapis.com \
anthos.googleapis.com \
logging.googleapis.com \
monitoring.googleapis.com

# If your AWS environment is brand new, you'll need this Role created (if you aren't sure, run this command anyway)
aws iam create-service-linked-role --aws-service-name autoscaling.amazonaws.com

# Clone the Anthos Samples repo and change to the AWS install directory
git clone https://github.com/GoogleCloudPlatform/anthos-samples.git
cd anthos-samples/anthos-multi-cloud/AWS

# run Terraform
terraform init
terraform apply

# NOTE: Install takes 15 minutes

# set your kube context to the new cluster (get its name from the console), and get nodes to see if its working
CLUSTER_NAME=myanthoscluser
gcloud container aws clusters get-credentials $CLUSTER_NAME
kubectl get nodes

# Use this command to delete your cluster, don't try to do it by hand
#terraform destroy



