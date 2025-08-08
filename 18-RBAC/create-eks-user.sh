#!/bin/bash

# Prompt for username
echo -n "Enter IAM username: "
read USER_NAME

# Prompt for group name
echo -n "Enter IAM group name: "
read GROUP_NAME

# Check if the group exists, create it if not
aws iam get-group --group-name $GROUP_NAME >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Creating IAM group: $GROUP_NAME"
    aws iam create-group --group-name $GROUP_NAME
fi

# Create IAM user
echo "Creating IAM user: $USER_NAME"
aws iam create-user --user-name $USER_NAME

# Attach user to the group
echo "Adding user to group: $GROUP_NAME"
aws iam add-user-to-group --user-name $USER_NAME --group-name $GROUP_NAME

# Create an IAM policy for EKS authentication
POLICY_NAME="EKS-ACCESS-POLICY"
POLICY_DOCUMENT='{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "eks:DescribeCluster"
            ],
            "Resource": "*"
        }
    ]
}'

POLICY_ARN=$(aws iam create-policy --policy-name $POLICY_NAME --policy-document "$POLICY_DOCUMENT" --query 'Policy.Arn' --output text)

echo "Attaching EKS policy to user: $USER_NAME"
aws iam attach-user-policy --user-name $USER_NAME --policy-arn $POLICY_ARN

# Generate access keys for user
ACCESS_KEYS=$(aws iam create-access-key --user-name $USER_NAME)
ACCESS_KEY_ID=$(echo $ACCESS_KEYS | jq -r '.AccessKey.AccessKeyId')
SECRET_ACCESS_KEY=$(echo $ACCESS_KEYS | jq -r '.AccessKey.SecretAccessKey')

# Get user ARN
USER_ARN=$(aws iam get-user --user-name $USER_NAME --query 'User.Arn' --output text)

# Save details to a file
echo "Saving user credentials to ${USER_NAME}_credentials.txt"
echo -e "Username: $USER_NAME\nGroupname: $GROUP_NAME\nUser ARN: $USER_ARN\nAccess Key: $ACCESS_KEY_ID\nSecret Key: $SECRET_ACCESS_KEY" > ${USER_NAME}_credentials.txt

# Display success message
echo "IAM user setup completed. Credentials saved in ${USER_NAME}_credentials.txt"
