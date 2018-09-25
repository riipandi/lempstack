#!/usr/bin/env bash

# Import credentials form config file
. /etc/sshnotify.conf

URL="https://api.telegram.org/bot${BOTKEY}/sendMessage"
DATE="$(date "+%d %b %Y %H:%M")"

if [ -n "$SSH_CLIENT" ]; then
  CLIENT_IP=$(echo $SSH_CLIENT | awk '{print $1}')

  SRV_HOSTNAME=$(hostname -f)
  SRV_IP=$(hostname -I | awk '{print $1}')

  IPINFO="https://ipinfo.io/${CLIENT_IP}"

  TEXT="User ${USER} logged in to *${SRV_HOSTNAME}* (*${SRV_IP}*)
From: *${CLIENT_IP}*
Date: ${DATE}
User info: [${IPINFO}](${IPINFO})"

  curl -s -d "chat_id=${USERID}&text=${TEXT}&disable_web_page_preview=true&parse_mode=markdown" $URL > /dev/null
fi
