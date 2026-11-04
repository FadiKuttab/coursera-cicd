#!/usr/bin/env bash
set -euo pipefail

for cicd_command in oc tkn git curl; do
  if ! command -v "$cicd_command" >/dev/null 2>&1; then
    echo "Missing required lab command: $cicd_command" >&2
    exit 1
  fi
done

oc whoami >/dev/null

CICD_REPO_URL="${CICD_REPO_URL:-$(git config --get remote.origin.url || true)}"
if [[ -z "$CICD_REPO_URL" ]]; then
  echo "Set CICD_REPO_URL to the GitHub repository URL." >&2
  exit 1
fi

CICD_NAMESPACE="$(oc project -q)"
CICD_IMAGE_URL="${CICD_IMAGE_URL:-image-registry.openshift-image-registry.svc:5000/${CICD_NAMESPACE}/counter-service:latest}"

echo "Project: $CICD_NAMESPACE"
echo "Repository: $CICD_REPO_URL"
echo "Image: $CICD_IMAGE_URL"

oc apply -f .tekton/tasks.yml
oc apply -f .tekton/pvc.yml
oc apply -f .tekton/pipeline.yml
oc get pvc counter-service-workspace

tkn pipeline start counter-service-pipeline \
  --param "repo-url=$CICD_REPO_URL" \
  --param "image=$CICD_IMAGE_URL" \
  --workspace name=shared-workspace,claimName=counter-service-workspace \
  --use-param-defaults \
  --showlog \
  --exit-with-pipelinerun-error

oc get deployment counter-service
oc get route counter-service
CICD_ROUTE_HOST="$(oc get route counter-service -o jsonpath='{.spec.host}')"
curl --fail --silent --show-error "http://${CICD_ROUTE_HOST}/health"
echo
oc logs deployment/counter-service --tail=80
