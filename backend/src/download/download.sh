#!/bin/bash

# url, username, password, playlist_name, directory, playlist_link

echo "Connecting to ssh server $1 as user $2"

sshpass -p $3 ssh -o StrictHostKeyChecking=no $2@$1 << EOF
    echo "Connected to $1"
    echo "Downloading playlist $4 to directory $5"
    cd $5
	
    # spotdl --m3u $6
EOF

if [ $? -eq 0 ]; then
    exit 0
else
    echo "Could not connect to $1"
    exit 1
fi
