# set -uo pipefail
# shopt -s globstar

# echo -e ".gitignore validation..."

# # Get a list of files that exist in the repo but are ignored.

# # The --verbose flag also includes files un-ignored via ! prefixes.
# # We filter those out with a somewhat awkward `awk` directive.
# 	# (Explanation: Split each line by : delimiters,
# 	# see if the actual gitignore line shown in the third field starts with !,
# 	# if it doesn't, print it.)

# # ignorecase for the sake of Windows users.

# output=$(git -c core.ignorecase=true check-ignore --verbose --no-index **/* | \
#     awk -F ':' '{ if ($3 !~ /^!/) print $0 }')

# # Then we take this result and return success if it's empty.
# if [ -z "$output" ]; then
#     exit 0
# else
# 	# And print the result if it isn't.
#     echo "$output"
#     exit 1
# fi
#!/bin/bash

# Exit on any error, undefined variables, and pipe failures
set -euo pipefail

# Enable globstar for ** patterns (bash 4.0+)
shopt -s globstar

echo ".gitignore validation..."

# Function to check if we're in a git repository
check_git_repo() {
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "Error: Not inside a git repository"
        exit 1
    fi
}

# Function to validate .gitignore
validate_gitignore() {
    echo "Checking for files that should be ignored but are tracked..."

    # Get all tracked files that should be ignored
    # Using git ls-files to get tracked files, then check each against .gitignore
    local ignored_but_tracked=""

    while IFS= read -r file; do
        # Check if this tracked file would be ignored by .gitignore
        if git check-ignore "$file" >/dev/null 2>&1; then
            ignored_but_tracked="$ignored_but_tracked$file"$'\n'
        fi
    done < <(git ls-files)

    # Also check for files that exist but are improperly ignored
    echo "Checking for files that exist in repo but are ignored..."

    # Get a list of files that exist in the repo but are ignored
    # The --verbose flag shows which .gitignore rule matched
    # Filter out un-ignored files (those with ! prefix)
    local improperly_ignored
    improperly_ignored=$(git -c core.ignorecase=true check-ignore --verbose --no-index ./**/* 2>/dev/null | \
        awk -F ':' '{
            # Skip files that are un-ignored (start with !)
            if ($3 !~ /^[[:space:]]*!/) {
                # Only show files that actually exist
                if (system("test -e \"" $4 "\"") == 0) {
                    print $4 " (ignored by: " $3 ")"
                }
            }
        }' || true)

    # Report results
    local has_errors=false

    if [ -n "$ignored_but_tracked" ]; then
        echo "ERROR: The following tracked files should be ignored:"
        echo "$ignored_but_tracked"
        has_errors=true
    fi

    if [ -n "$improperly_ignored" ]; then
        echo "WARNING: The following files exist but are ignored:"
        echo "$improperly_ignored"
        # Uncomment the next line if you want warnings to be treated as errors
        # has_errors=true
    fi

    if [ "$has_errors" = true ]; then
        echo "❌ .gitignore validation failed"
        exit 1
    else
        echo "✅ .gitignore validation passed"
        exit 0
    fi
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [--help] [--fix]"
    echo ""
    echo "Options:"
    echo "  --help    Show this help message"
    echo "  --fix     Attempt to fix issues by untracking ignored files"
    echo ""
    echo "This script validates that:"
    echo "  1. No tracked files should be ignored"
    echo "  2. No important files are accidentally ignored"
}

# Function to fix issues
fix_issues() {
    echo "Attempting to fix .gitignore issues..."

    # Untrack files that should be ignored
    while IFS= read -r file; do
        if git check-ignore "$file" >/dev/null 2>&1; then
            echo "Untracking ignored file: $file"
            git rm --cached "$file" 2>/dev/null || true
        fi
    done < <(git ls-files)

    echo "Fixed! Please review changes and commit if appropriate."
}

# Main execution
main() {
    case "${1:-}" in
        --help|-h)
            show_usage
            exit 0
            ;;
        --fix)
            check_git_repo
            fix_issues
            ;;
        "")
            check_git_repo
            validate_gitignore
            ;;
        *)
            echo "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
