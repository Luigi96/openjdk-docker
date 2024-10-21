#!/bin/bash

annotate_image() {
    local $REGISTRY=$1
    local ARCHITECTURE=$2

    echo "Pulling $REGISTRY with architecture $ARCHITECTURE"

    docker pull --platform $ARCHITECTURE $REGISTRY
    if [[ $? -ne 0 ]]; then
        echo "Failed to pull image $REGISTRY"
        exit 1
    fi

    manifest=$(docker image inspect "$REGISTRY" | jq)
    digest=$(echo $manifest | jq '.[0].RepoDigests[0]')
    digest=${digest//\"/}
    endOfLifeDate=$(date "+%Y-%m-%d")

    echo "Annotating image $digest with end-of-life date $endOfLifeDate"
    oras attach \
    --artifact-type "application/vnd.microsoft.artifact.lifecycle" \
    --annotation "vnd.microsoft.artifact.lifecycle.end-of-life.date=${endOfLifeDate}T00:00:00Z" \
    $digest --verbose

    if [[ $? -ne 0 ]]; then
        echo "Failed to annotate image!"
        exit 1
    fi
    
}

az acr login -n msopenjdk

if [[ $? -ne 0 ]]; then
    echo "Failed to login to ACR"
    exit 1
fi

annotate_image "$REGISTRY" "amd64"
annotate_image "$REGISTRY" "arm64"