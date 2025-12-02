#!/bin/bash

echo "==================================="
echo "MASTER CLEANUP - ALL SCENARIOS"
echo "==================================="
echo ""

# Function to show memory
show_memory() {
    echo ""
    echo "=== Current Memory Usage ==="
    oc adm top nodes
    echo ""
}

# Initial memory check
echo "Memory usage BEFORE cleanup:"
show_memory

# Scenario 7 - Logging
echo "Cleaning up Scenario 7: Logging..."
oc delete deployment loki -n security-demo --ignore-not-found=true
oc delete daemonset promtail -n security-demo --ignore-not-found=true
oc delete service loki -n security-demo --ignore-not-found=true
oc delete configmap loki-config promtail-config -n security-demo --ignore-not-found=true
oc delete serviceaccount promtail -n security-demo --ignore-not-found=true
oc delete clusterrole promtail --ignore-not-found=true
oc delete clusterrolebinding promtail --ignore-not-found=true
echo "✓ Logging cleaned"
show_memory

# Scenario 8 - Keycloak
echo "Cleaning up Scenario 8: Keycloak..."
oc delete all -l app=keycloak -n security-tools --ignore-not-found=true
oc delete all -l app=keycloak-db -n security-tools --ignore-not-found=true
oc delete pvc keycloak-db -n security-tools --ignore-not-found=true
oc delete secret keycloak-db-secret -n security-tools --ignore-not-found=true
oc delete configmap keycloak-realm -n security-tools --ignore-not-found=true
echo "✓ Keycloak cleaned"
show_memory

# Scenario 9 - Linkerd
echo "Cleaning up Scenario 9: Linkerd..."
oc label namespace security-demo linkerd.io/inject- --ignore-not-found=true
oc rollout restart deployment vulnerable-app -n security-demo
oc delete configmap linkerd-config linkerd-instructions -n security-demo --ignore-not-found=true
echo "✓ Linkerd cleaned"
show_memory

# Scenario 10 - Full Pipeline
echo "Cleaning up Scenario 10: Pipeline..."
tkn pipelinerun delete --all -n cicd -f
oc delete pvc pipeline-workspace -n cicd --ignore-not-found=true
oc delete job --all -n security-demo --ignore-not-found=true
echo "✓ Pipeline cleaned"
show_memory

# Scenario 3 - SonarQube
echo "Cleaning up Scenario 3: SonarQube..."
oc delete all -l app=sonarqube -n security-tools --ignore-not-found=true
oc delete pvc sonarqube-data -n security-tools --ignore-not-found=true
echo "✓ SonarQube cleaned"
show_memory

# Scenario 4 - Nexus
echo "Cleaning up Scenario 4: Nexus..."
oc delete all -l app=nexus -n cicd --ignore-not-found=true
oc delete pvc nexus-data -n cicd --ignore-not-found=true
echo "✓ Nexus cleaned"
show_memory

# Clean up any remaining PVCs
echo "Cleaning up remaining PVCs..."
oc delete pvc --all -n security-tools --ignore-not-found=true
oc delete pvc --all -n cicd --ignore-not-found=true

# Clean up completed pods
echo "Cleaning up completed/failed pods..."
oc delete pod --field-selector=status.phase==Succeeded --all-namespaces
oc delete pod --field-selector=status.phase==Failed --all-namespaces

# Final memory check
echo ""
echo "==================================="
echo "Memory usage AFTER cleanup:"
show_memory

echo ""
echo "==================================="
echo "✓ ALL SCENARIOS CLEANED UP"
echo "==================================="
echo ""
echo "Remaining running:"
echo "- Base operators"
echo "- Vulnerable application"
echo "- Scenario 1 (RBAC - lightweight)"
echo "- Scenario 5 (GitOps - lightweight)"
echo "- Scenario 6 (Monitoring - lightweight)"
echo ""
echo "Total memory freed: ~6-8GB"
echo ""
