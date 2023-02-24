#!/bin/bash

#script that sets up latch for ssh access on a linux server 

# Configuration parameters
APP_NAME="Latch App Name"
APP_DESC="Latch for securing SSH with 2FA"
LATCH_API_TOKEN="your_latch_api_token"
LATCH_API_SECRET="your_latch_api_secret"
LATCH_API_URL="https://latch.elevenpaths.com/api/1.0"
LATCH_CONF_FILE="/etc/latch.conf"
PAM_CONF_FILE="/etc/pam.d/sshd"

if [ -f "$LATCH_CONF_FILE" ]; then
  read -p "Overwrite latch config? [y/n] " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Bye bye"
    exit 1
  fi
fi

# Install Latch client and daemon packages
echo "Installing latch & necessary packages..."
apt-get update >/dev/null 2>&1 || { echo "Update failed."; exit 1; }
apt-get install -y latch >/dev/null 2>&1 || { echo "Failed to install Latch packages."; exit 1; }

# Register the application with the Latch API and retrieve App ID and App Secret
echo "Registering the application..."
response=$(curl -s -X POST -H "Content-Type: application/json" -d "{\"name\": \"$APP_NAME\", \"description\": \"$APP_DESC\", \"url\": \"$APP_URL\", \"token\": \"$LATCH_API_TOKEN\", \"secret\": \"$LATCH_API_SECRET\"}" "$LATCH_API_URL/register")
if [ $? -ne 0 ]; then
  echo "Error: curl command failed."
  exit 1
fi

app_id=$(echo "$response" | jq -r '.id')
app_secret=$(echo "$response" | jq -r '.secret')

if [ "$app_id" = "null" ] || [ "$app_secret" = "null" ]; then
  echo "Failed to retrieve App ID and/or App Secret"
  exit 1
fi

#set up latch config file
cat << EOF > "$LATCH_CONF_FILE"
APP_ID=$app_id
APP_SECRET=$app_secret
EOF

# Configure PAM for Latch
cat << EOF >> "$PAM_CONF_FILE"

# Latch authentication
auth required pam_latch.so
EOF

echo "Restarting Latch and SSH"
systemctl restart latchd.service >/dev/null 2>&1 || { echo "Error: Failed to restart Latch service."; exit 1; }
systemctl restart sshd.service >/dev/null 2>&1 || { echo "Error: Failed to restart SSH service."; exit 1; }

# Show the QR code and wait for the user to enable Latch on the phone app
qrencode -t ANSI256 <(echo -n "otpauth://totp/latch:$(hostname)?secret=$app_secret&issuer=latch")
echo "Please scan the QR code above with your Latch mobile app and wait for approval. Press Enter to continue." && read

#Check if latch is enabled
echo "Checking whether Latch is enabled"
latch_status=$(latchcmd status)
if [ "$latch_status" != "on" ]; then
echo "Auth failed or Latch is not enabled"
exit 1
fi

echo "Latch configured for SSH logins on $hostname"