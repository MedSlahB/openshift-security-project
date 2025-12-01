#!/bin/bash
set -e

echo "Cleaning up..."

oc delete all -l app=vulnerable-app -n security-demo --ignore-not-found=true
oc delete pipelinerun --all -n cicd --ignore-not-found=true
oc delete application --all -n openshift-gitops --ignore-not-found=true
oc delete pvc --all -n security-demo --ignore-not-found=true
oc delete pvc --all -n cicd --ignore-not-found=true
oc delete pvc --all -n security-tools --ignore-not-found=true
oc delete clusterrolebinding pipeline-sa-deployer --ignore-not-found=true

oc delete namespace security-demo --ignore-not-found=true &
oc delete namespace cicd --ignore-not-found=true &
oc delete namespace security-tools --ignore-not-found=true &

wait

echo "Cleanup complete!"
