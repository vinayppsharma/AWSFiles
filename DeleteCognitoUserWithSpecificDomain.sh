#!/bin/bash

# Set your AWS credentials
export AWS_ACCESS_KEY_ID=AccesKey

export AWS_SECRET_ACCESS_KEY=SecretKey

export AWS_DEFAULT_REGION=Regio

# Set your User Pool ID
USER_POOL_ID=userPoolId

# Set the domain to filter usernames
USERNAME_DOMAIN="mail domain"  # write the mail domain which you want to delete like @gmail.com, or any thing else

# List the users in the Cognito User Pool
EMAIL_DOMAIN="@getnada.com"

# List the users in the Cognito User Pool
USER_LIST_JSON=$(aws cognito-idp list-users --user-pool-id $USER_POOL_ID --query "Users[*].Attributes[?Name=='email'].Value" --output json)

# Extract and format email addresses from JSON
EMAIL_LIST=$(echo $USER_LIST_JSON | jq -r '.[][]')

echo "List of users with email addresses:"
echo "$EMAIL_LIST"

# Loop through the list of email addresses and delete users with the specified email domain
for EMAIL in $EMAIL_LIST
do
    if [[ "$EMAIL" == *"$EMAIL_DOMAIN" ]]; then

        # Get the username associated with the email address
        USERNAME=$(aws cognito-idp list-users --user-pool-id $USER_POOL_ID --filter "email=\"$EMAIL\"" --query "Users[0].Username" --output text)

        if [ -n "$USERNAME" ]; then
            # Delete the user by username
            echo $USERNAME
            aws cognito-idp admin-delete-user --user-pool-id $USER_POOL_ID --username $USERNAME

            echo "Deleted user with email address: $EMAIL"
        else
            echo "User not found for email address: $EMAIL"
        fi
    else
        echo "Skipped user with email address: $EMAIL"
    fi
done
