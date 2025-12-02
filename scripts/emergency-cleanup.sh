#!/bin/bash

echo "=========================================="
echo "EMERGENCY MEMORY CLEANUP"
echo "=========================================="
echo ""

# Delete completed pods
echo "Deleting completed pods..."
oc delete pod --field-selector=status.phase==Succeeded -A --ignore-not-found=true

# Delete failed pods
echo "Deleting failed pods..."
oc delete pod --field-selector=status.phase==Failed -A --ignore-not-found=true

# Delete old pipeline runs
echo "Deleting old pipeline runs..."
oc delete pipelinerun --all -n cicd --ignore-not-found=true

# Delete build pods
echo "Deleting old build pods..."
oc delete pod -n security-demo -l openshift.io/build.name --ignore-not-found=true

# Show current status
echo ""
echo "Current memory after cleanup:"
oc adm top nodes 2>/dev/null || echo "Metrics not available"
