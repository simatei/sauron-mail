#!/bin/bash

# Variable
CONTAINER_NAME="webmail"

# Check if Docker is running
if ! command -v docker &> /dev/null
then
    echo "Docker is not installed. Please install Docker and try again."
    exit
fi

# Check if the specified Docker container is running
if ! docker ps --format '{{.Names}}' | grep -q "$CONTAINER_NAME"
then
    echo "Container '$CONTAINER_NAME' is not running. Please ensure it's running and try again."
    exit
fi

# Get a shell in the Docker container
echo "Accessing Docker container '$CONTAINER_NAME'..."
docker exec -it "$CONTAINER_NAME" bash -c "

# Check network connectivity
echo 'Testing network connectivity...'
if ! command -v nc &> /dev/null
then
    echo 'Installing netcat...'
    apk add --no-cache netcat-openbsd
fi
echo 'Connecting to mail service on port 587...'
nc -vz mail 587

# Check Roundcube error logs
echo 'Checking Roundcube error logs...'
if [ ! -d '/var/www/html/logs/' ]; then
    echo 'Error: Roundcube logs directory does not exist.'
else
    if [ -f '/var/www/html/logs/errors.log' ]; then
        echo 'Displaying last 10 lines of errors.log:'
        tail -n 10 /var/www/html/logs/errors.log
    else
        echo 'Error: errors.log does not exist.'
    fi
fi

# Exit Docker container shell
echo 'Exiting Docker container shell...'
exit
"
