#!/bin/bash
# For use this script you need to install jq "sudo apt install jq -y"
# get user data
read -p "Enter your profile " aws_profile
read -p "Enter your mfa name " mfa_name
# get account_id
account_id=$(aws --profile $aws_profile sts get-caller-identity | jq --raw-output '.Account')
read -p "Enter your mfa token-code " mfa_token_code
# get aws credentials
credentials=$(aws sts assume-role --role-arn arn:aws:iam::$account_id:role/Admins --role-session-name tf --serial-number arn:aws:iam::$account_id:mfa/$mfa_name --token-code $mfa_token_code --profile $aws_profile)
export AWS_ACCESS_KEY_ID=$(echo $credentials | jq --raw-output '.Credentials.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo $credentials | jq --raw-output '.Credentials.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo $credentials | jq '.Credentials.SessionToken')
#use test command
#terraform -chdir="./terraform/environments/prd/aws/" plan
#terraform -chdir="./terraform/environments/prd/aws/" console
