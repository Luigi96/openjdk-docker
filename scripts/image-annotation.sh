#!/bin/bash
echo "Fetching image digest"
digest=$(az acr repository show --name msopenjdk --image $IMAGE --query digest)
digest=${digest//\"/}
echo "Digest: $digest"
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