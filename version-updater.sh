#!/bin/bash

# Set repository URL
url="https://github.com/Ivannosal/BH-HW-4"
repo_dir="temp_repo"

# Function to increment version
increment_version() {
    local current_tag=$1
    echo "Current tag: $current_tag" >&2

    # Remove 'v' prefix if present (v1.0.0 -> 1.0.0)
    current_tag="${current_tag#v}"

    # Split version into parts
    IFS='.' read -ra version_parts <<< "$current_tag"

    if [ ${#version_parts[@]} -ne 3 ]; then
        echo "Error: Invalid version format: $current_tag" >&2
        return 1
    fi

    major="${version_parts[0]}"
    minor="${version_parts[1]}"
    patch="${version_parts[2]}"

    # Increment patch version
    patch=$((patch + 1))

    # Return new version
    echo "$major.$minor.$patch"
}

echo "=== Version-updater Script ==="

# Clone repository
echo "Cloning repository from $url..."
if ! git clone "$url" "$repo_dir" 2>/dev/null; then
    echo "Error: Failed to clone repository" >&2
    exit 1
fi

# Change to repository directory
cd "$repo_dir" || {
    echo "Error: Failed to enter repository directory" >&2
    exit 1
}

# Get current tag description
echo "Checking current tags..."
desc=$(git describe --tags 2>/dev/null)

# Check if tags exist in repository
if [ $? -ne 0 ] || [ -z "$desc" ]; then
    echo "No tags found in repository"
    echo "No changes"
else
    echo "Current tag description: $desc"

    # Check if there are commits after the last tag (if description contains hyphen)
    if [[ "$desc" == *"-"* ]]; then
        echo "New commits found after the last tag!"

        # Extract clean tag name (remove commit info)
        current_tag=$(echo "$desc" | cut -d'-' -f1)
        echo "Last tag: $current_tag"

        # Increment version
        new_tag=$(increment_version "$current_tag")

        if [ $? -eq 0 ] && [ -n "$new_tag" ]; then
            echo "New tag: $new_tag"

            # Create annotated tag
            git tag -a "$new_tag" -m "Auto-incremented version: $new_tag"

            # Push tag to remote repository
            git push --tags

            echo "Tag $new_tag successfully created and pushed!"
        else
            echo "Error: Failed to increment version" >&2
        fi
    else
        echo "No changes - last tag points to the latest commit"
    fi
fi

# Return to original directory and cleanup
cd .. || exit 1

# Remove local repository copy
echo "Cleaning up..."
rm -rf "$repo_dir"

echo "=== Script finished ==="