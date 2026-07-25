# Script to switch cloud profiles using fzf
function profile-env() {
    local profiles=()
    local gcp_base="$HOME/.config/gcloud/legacy_credentials"

    # Gather AWS profiles
    if [[ -f "$HOME/.aws/credentials" ]]; then
        local aws_profs=$(grep '^\[' "$HOME/.aws/credentials" | tr -d '[]' | sed 's/^/AWS: /')
        while IFS= read -r line; do
            if [[ -n "$line" ]]; then
                profiles+=("$line")
            fi
        done <<< "$aws_profs"
    fi

    # Gather GCP profiles
    if [[ -d "$gcp_base" ]]; then
        for dir in "$gcp_base"/*; do
            if [[ -d "$dir" && -f "$dir/adc.json" ]]; then
                local gcp_prof=$(basename "$dir")
                profiles+=("GCP: $gcp_prof")
            fi
        done
    fi

    if [[ ${#profiles[@]} -eq 0 ]]; then
        echo "No cloud profiles found."
        return 1
    fi

    # Use fzf to select a profile
    local selected=$(printf "%s\n" "''${profiles[@]}" | fzf --prompt="Select Cloud Profile > ")

    if [[ -z "$selected" ]]; then
        echo "Selection cancelled."
        return 1
    fi

    local provider=$(echo "$selected" | awk '{print $1}')
    local profile_name=$(echo "$selected" | awk '{print $2}')

    if [[ "$provider" == "AWS:" ]]; then
        export AWS_PROFILE="$profile_name"
        echo "AWS_PROFILE set to: $AWS_PROFILE"
    elif [[ "$provider" == "GCP:" ]]; then
        export GOOGLE_APPLICATION_CREDENTIALS="$gcp_base/$profile_name/adc.json"
        export CLOUDSDK_ACTIVE_CONFIG_NAME="$profile_name"
        # Optionally activate gcloud config if exists, otherwise just env var is fine
        echo "GCP Profile set to: $profile_name"
        echo "GOOGLE_APPLICATION_CREDENTIALS=$GOOGLE_APPLICATION_CREDENTIALS"
    else
        echo "Unknown provider selected."
    fi
}
