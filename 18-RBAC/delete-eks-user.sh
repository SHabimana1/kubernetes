#!/bin/bash

# Prompt for username
echo -n "Enter IAM username to delete: "
read USER_NAME

# Prompt for group name
echo -n "Enter IAM group name to delete: "
read GROUP_NAME

# Define policy name
POLICY_NAME="EKS-ACCESS-POLICY"

# Get policy ARN
POLICY_ARN=$(aws iam list-policies --query "Policies[?PolicyName=='$POLICY_NAME'].Arn" --output text)

# Detach policy from user if it exists
if [ -n "$POLICY_ARN" ]; then
    echo "Detaching policy $POLICY_NAME from user: $USER_NAME"
    aws iam detach-user-policy --user-name $USER_NAME --policy-arn $POLICY_ARN

    echo "Deleting policy: $POLICY_NAME"
    aws iam delete-policy --policy-arn $POLICY_ARN
else
    echo "Policy $POLICY_NAME not found. Skipping policy deletion."
fi

# Remove user from group
echo "Removing user $USER_NAME from group $GROUP_NAME"
aws iam remove-user-from-group --user-name $USER_NAME --group-name $GROUP_NAME

# Delete user access keys
ACCESS_KEYS=$(aws iam list-access-keys --user-name $USER_NAME --query 'AccessKeyMetadata[].AccessKeyId' --output text)
for KEY in $ACCESS_KEYS; do
    echo "Deleting access key $KEY for user $USER_NAME"
    aws iam delete-access-key --user-name $USER_NAME --access-key-id $KEY
done

# Delete IAM user
echo "Deleting IAM user: $USER_NAME"
aws iam delete-user --user-name $USER_NAME

# Check if the group is empty and has no policies attached before deletion
group_users=$(aws iam get-group --group-name $GROUP_NAME --query 'Users' --output text)
attached_policies=$(aws iam list-attached-group-policies --group-name $GROUP_NAME --query 'AttachedPolicies' --output text)

if [ -z "$group_users" ] && [ "$attached_policies" == "None" ]; then
    echo "Deleting IAM group: $GROUP_NAME"
    aws iam delete-group --group-name $GROUP_NAME
else
    if [ -n "$group_users" ]; then
        echo "Group $GROUP_NAME is not empty. Skipping deletion."
    fi
    if [ -n "$attached_policies" ] && [ "$attached_policies" != "None" ]; then
        echo "Group $GROUP_NAME has policies attached. Skipping deletion."
    fi
fi

# Display success message
echo "IAM user, group, and policy deletion process completed."
