# Anthos on AWS Installation
Anthos on AWS [install instructions](https://github.com/GoogleCloudPlatform/anthos-samples/tree/main/anthos-multi-cloud/AWS) and source repository

## Steps
1. Create a new argolis project
1. Run my 4 scripts in the [gcp-scripts](https://github.com/gfilicetti/gcp-scripts) repository
1. Start Cloud Shell
1. Install AWS CLI from these instructions, which runs these commands:
    ```bash 
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update
    ```
1. Create the Access Key and/or Session Token for AWS CLI use
    1. Access Key for CLI
        1. In AWS console, go to **IAM / Users** and click on your user
        1. Click on **Security Credentials** tab, then scroll and click the **Create Access Key** button
        1. Click on first radio button for CLI and then click **Create**
        1. On the next screen copy the **Access Key Id** and **Secret** and paste onto a temporary text file
        1. At the Cloud Shell run: `aws configure`
        1. Fill in the key id and key secret (and add in other defaults if you want)
    1. Session Token if MFA is enabled.
        1. Use your MFA device to get the code and use it in the command below
        1. Run this command to create a session token:
            ```bash
            aws sts get-session-token --serial-number arn:aws:iam::713113969541:mfa/AWSArgolis --duration-seconds 129600 --token-code <mfa token here>
            ```
        1. You’ll get a JSON document back, copy these values to a temporary text file:
            1. `AccessKeyId`
            1. `SecretAccessKey`
            1. `SessionToken`
        1. You’ll want to create a new profile in the `~/.aws/credentials` file with these values. The new section in the file will look something like this. 
            > **NOTE:** After this, you’ll need to issue aws cli commands with `--profile mfa`
            ```bash
            [mfa]
            aws_access_key_id = XXXXXXXXXXXXXXXXXXXX
            aws_secret_access_key = XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
            aws_session_token = YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY
            ```

1. Enable the APIs needed for Anthos
    ```bash
    gcloud --project="${PROJECT_ID}" services enable \
    gkemulticloud.googleapis.com \
    gkeconnect.googleapis.com \
    connectgateway.googleapis.com \
    cloudresourcemanager.googleapis.com \
    anthos.googleapis.com \
    logging.googleapis.com \
    monitoring.googleapis.com
    ```

1. Create the role needed if your AWS environment is brand new
    ```bash
    aws iam create-service-linked-role --aws-service-name autoscaling.amazonaws.com
    ```
    > **NOTE:** It is ok if this fails saying the name is already taken.

1. Clone the Anthos samples repo into the Cloud Shell
    ```bash
    git clone https://github.com/GoogleCloudPlatform/anthos-samples.git
    cd anthos-samples/anthos-multi-cloud/AWS
    ```

1. Edit `terraform.tfvars` and change the `gcp_project_id` and `admin_user` fields to match yours.
1. Run:
    ```bash
    terraform init
    terraform apply
    ```

    > *Install takes about 15 minutes*

1. Log into the cluster and set your kubectl context and get nodes to make sure it works
    ```bash
    gcloud container aws clusters get-credentials <cluster name here>
    kubectl get nodes
    ```

1. To delete run:
    ```bash
    terraform destroy
    ```

## Links
- [Install instructions and repo](https://github.com/GoogleCloudPlatform/anthos-samples/tree/main/anthos-multi-cloud/AWS)
- [“Powered By Anthos”](https://sites.google.com/corp/google.com/poweredbyanthos/home)  pre-canned demo environment
- [Bug re: KMS errors](https://b.corp.google.com/issues/275707975) encountered on fresh AWS environments.
- [Brian’s Multi-cloud customer deck](go/anthos-multicloud-customer-deck)
- [My fork](https://github.com/gfilicetti/csp-config-management) of the Anthos Config Management example repository
    - This is where you make changes for the demo
    - They will be propagated to the clusters you enable
- Crossplane: [Brian’s demo repo](https://github.com/bkauf/anthos-crossplane-demo)


## Author
Gino Filicetti <ginof@>

