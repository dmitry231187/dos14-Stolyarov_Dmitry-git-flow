#!/bin/bash
# "for use this script you need to install jq 'sudo apt install jq -y'"
# get user data
echo ""
read -p "Enter your profile " aws_profile 
read -p "Enter your mfa name " mfa_name
# get account id
account_id=$(aws --profile $aws_profile sts get-caller-identity | jq --raw-output '.Account')
# get mfa token
read -p "Enter your mfa token-code " mfa_token_code

#get credentials and write them to variables
credentials=$(aws sts assume-role --role-arn arn:aws:iam::$account_id:role/Admins --role-session-name tf --serial-number arn:aws:iam::$account_id:mfa/$mfa_name --token-code $mfa_token_code --profile $aws_profile)
ACCESS_KEY_ID=$(echo $credentials | jq --raw-output '.Credentials.AccessKeyId')
SECRET_ACCESS_KEY=$(echo $credentials | jq --raw-output '.Credentials.SecretAccessKey')
SESSION_TOKEN=$(echo $credentials | jq '.Credentials.SessionToken')
# print this text only if the user bpzb not set
if [[ -v AWS_PROFILE ]]; then
	if [[ $AWS_PROFILE != "bpzb" ]]; then
		echo ""
		echo "We create new aws profile 'bpzb' and write it to ~/.aws/credentials"
		echo ""
		echo "To use new profile you need use aws with '--profile bpzb'"
		echo "For example: aws --profile bpzb sts get-caller-identity"
		echo ""
	fi
else
	echo ""
	echo "We create new aws profile 'bpzb' and write it to ~/.aws/credentials"
	echo ""
	echo "To use new profile you need use aws with '--profile bpzb'"
	echo "For example: aws --profile bpzb sts get-caller-identity"
	echo ""
fi

# check exist name
if grep -Fxq "[bpzb]" ~/.aws/credentials
then
#if exist, delete it
	start_line=$(awk '/\[bpzb\]/{print NR}' ~/.aws/credentials)
	end_line=$(($start_line+3))
	sed -i "$start_line,$end_line"'d' ~/.aws/credentials
fi
# creating template for writing to ~/.aws/credentials
aws_credentials=("[bpzb]")
aws_credentials+=("aws_access_key_id = $ACCESS_KEY_ID")
aws_credentials+=("aws_secret_access_key = $SECRET_ACCESS_KEY")
aws_credentials+=("aws_session_token = $SESSION_TOKEN")
# write template to  ~/.aws/credentials
for i in "${aws_credentials[@]}"; do echo "$i" >> ~/.aws/credentials; done
# print this text only if the user bpzb not set
if [[ -v AWS_PROFILE ]]; then
	if [[ $AWS_PROFILE != "bpzb" ]]; then
		echo ""
		echo ""
		echo "Please, execute this command: export AWS_PROFILE=bpzb"
		echo ""
		echo ""
	fi
else
	echo ""
	echo ""
	echo "Please, execute this command: export AWS_PROFILE=bpzb"
	echo ""
	echo ""
fi

