#!/bin/bash
# GitHub API URL
API_URL="https://api.github.com"

# Check if environment variables are set
if [ -z "$username" ] || [ -z "$token" ]; then
    echo "Error: GitHub username and token must be set as environment variables."
    echo "Use: export username=your_github_username"
    echo "Use: export token=your_github_token"
    exit 1
fi

# GitHub username and personal access token
USERNAME=$username
TOKEN=$token

# Check if repo info is provided
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 REPO_OWNER REPO_NAME"
    exit 1
fi

# User and Repository information
REPO_OWNER=$1
REPO_NAME=$2

# Function to make a GET request to the GitHub API
function github_api_get {
    local endpoint="$1"
    local url="${API_URL}/${endpoint}"
    
    # Send a GET request to the GitHub API with authentication
    curl -s -u "${USERNAME}:${TOKEN}" "$url"
}

# Function to list users with read access to the repository
function list_users_with_read_access {
    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/collaborators"
    
    # Fetch the list of collaborators on the repository
    response=$(github_api_get "$endpoint")
    
    # Check if the response is an error
    if echo "$response" | jq -e 'has("message")' > /dev/null; then
        error_message=$(echo "$response" | jq -r '.message')
        echo "Error: $error_message"
        return 1
    fi
    
    # Check if the response is an array
    if ! echo "$response" | jq -e 'if type == "array" then true else false end' > /dev/null; then
        echo "Error: Unexpected response format from GitHub API."
        echo "Response: $response"
        return 1
    fi
    
    # Fetch collaborators with read access
    collaborators=$(echo "$response" | jq -r '.[] | select(.permissions.pull == true) | .login')
    
    # Display the list of collaborators with read access
    if [[ -z "$collaborators" ]]; then
        echo "No users with read access found for ${REPO_OWNER}/${REPO_NAME}."
    else
        echo "Users with read access to ${REPO_OWNER}/${REPO_NAME}:"
        echo "$collaborators"
    fi
}

# Main script
echo "Listing users with read access to ${REPO_OWNER}/${REPO_NAME}..."
list_users_with_read_access
