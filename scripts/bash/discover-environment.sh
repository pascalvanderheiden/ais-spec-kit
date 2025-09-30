#!/usr/bin/env bash

set -e

JSON_MODE=false
ARGS=()
for arg in "$@"; do
    case "$arg" in
        --json) JSON_MODE=true ;;
        --help|-h) 
            echo "Usage: $0 [--json] [tag_filter]"
            echo ""
            echo "Examples:"
            echo "  $0                                    # Discover all resources"
            echo "  $0 azd-env-name:azd-ais-lza-prd      # Filter by tag"
            echo "  $0 env:prod,team:platform            # Multiple tags"
            exit 0 
            ;;
        *) ARGS+=("$arg") ;;
    esac
done

TAG_FILTER="${ARGS[*]}"

# Function to find the repository root by searching for existing project markers
find_repo_root() {
    local dir="$1"
    while [ "$dir" != "/" ]; do
        if [ -d "$dir/.git" ] || [ -d "$dir/.specify" ]; then
            echo "$dir"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    return 1
}

# Resolve repository root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if git rev-parse --show-toplevel >/dev/null 2>&1; then
    REPO_ROOT=$(git rev-parse --show-toplevel)
    HAS_GIT=true
else
    REPO_ROOT="$(find_repo_root "$SCRIPT_DIR")"
    if [ -z "$REPO_ROOT" ]; then
        echo "Error: Could not determine repository root. Please run this script from within the repository." >&2
        exit 1
    fi
    HAS_GIT=false
fi

cd "$REPO_ROOT"

# Check for cloud provider configuration
CLOUD_PROVIDER="${SPECIFY_CLOUD_PROVIDER:-}"
if [ -z "$CLOUD_PROVIDER" ]; then
    # Try to read from .specify/config if exists
    CONFIG_FILE="$REPO_ROOT/.specify/config"
    if [ -f "$CONFIG_FILE" ]; then
        CLOUD_PROVIDER=$(grep "^CLOUD_PROVIDER=" "$CONFIG_FILE" | cut -d= -f2)
    fi
fi

if [ -z "$CLOUD_PROVIDER" ]; then
    echo "Error: Cloud provider not configured." >&2
    echo "Set SPECIFY_CLOUD_PROVIDER environment variable or run 'specify init' to configure." >&2
    exit 1
fi

# Validate cloud provider
case "$CLOUD_PROVIDER" in
    azure|Azure|AZURE) CLOUD_PROVIDER="Azure" ;;
    aws|AWS) 
        echo "Error: AWS support coming soon." >&2
        exit 1
        ;;
    gcp|GCP|google|Google) 
        echo "Error: Google Cloud support coming soon." >&2
        exit 1
        ;;
    *)
        echo "Error: Unknown cloud provider '$CLOUD_PROVIDER'. Supported: azure (aws and gcp coming soon)" >&2
        exit 1
        ;;
esac

# Create specs directory if it doesn't exist
SPECS_DIR="$REPO_ROOT/specs"
mkdir -p "$SPECS_DIR"

# Find highest numbered spec directory
HIGHEST=0
if [ -d "$SPECS_DIR" ]; then
    for dir in "$SPECS_DIR"/*; do
        [ -d "$dir" ] || continue
        dirname=$(basename "$dir")
        number=$(echo "$dirname" | grep -o '^[0-9]\+' || echo "0")
        number=$((10#$number))
        if [ "$number" -gt "$HIGHEST" ]; then HIGHEST=$number; fi
    done
fi

NEXT=$((HIGHEST + 1))
DISCOVERY_NUM=$(printf "%03d" "$NEXT")

# Create discovery session name
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
SESSION_NAME="discovery-${CLOUD_PROVIDER,,}-${TIMESTAMP}"
BRANCH_NAME="${DISCOVERY_NUM}-${SESSION_NAME}"

# Create new branch if using git
if [ "$HAS_GIT" = true ]; then
    git checkout -b "$BRANCH_NAME"
else
    >&2 echo "[specify] Warning: Git repository not detected; skipped branch creation for $BRANCH_NAME"
fi

# Create discovery directory
DISCOVERY_DIR="$SPECS_DIR/$BRANCH_NAME"
mkdir -p "$DISCOVERY_DIR"

# Copy discovery template
TEMPLATE="$REPO_ROOT/.specify/templates/discovery-template.md"
DISCOVERY_FILE="$DISCOVERY_DIR/discovery.md"
if [ -f "$TEMPLATE" ]; then 
    cp "$TEMPLATE" "$DISCOVERY_FILE"
else 
    touch "$DISCOVERY_FILE"
    echo "Warning: Discovery template not found at $TEMPLATE" >&2
fi

# Set environment variable for current session
export SPECIFY_DISCOVERY="$BRANCH_NAME"
export SPECIFY_CLOUD_PROVIDER="$CLOUD_PROVIDER"

# Output results
if $JSON_MODE; then
    printf '{"BRANCH_NAME":"%s","DISCOVERY_FILE":"%s","DISCOVERY_DIR":"%s","CLOUD_PROVIDER":"%s","TAG_FILTER":"%s","DISCOVERY_NUM":"%s","SESSION_NAME":"%s"}\n' \
        "$BRANCH_NAME" "$DISCOVERY_FILE" "$DISCOVERY_DIR" "$CLOUD_PROVIDER" "$TAG_FILTER" "$DISCOVERY_NUM" "$SESSION_NAME"
else
    echo "BRANCH_NAME: $BRANCH_NAME"
    echo "DISCOVERY_FILE: $DISCOVERY_FILE"
    echo "DISCOVERY_DIR: $DISCOVERY_DIR"
    echo "CLOUD_PROVIDER: $CLOUD_PROVIDER"
    echo "TAG_FILTER: ${TAG_FILTER:-<none - discover all>}"
    echo "DISCOVERY_NUM: $DISCOVERY_NUM"
    echo "SESSION_NAME: $SESSION_NAME"
    echo "SPECIFY_DISCOVERY environment variable set to: $BRANCH_NAME"
fi
