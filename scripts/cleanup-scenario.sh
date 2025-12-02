#!/bin/bash

SCENARIO=$1

if [ -z "$SCENARIO" ]; then
    echo "Usage: ./scripts/cleanup-scenario.sh <scenario-number>"
    exit 1
fi

echo "=========================================="
echo "Cleaning up Scenario $SCENARIO"
echo "=========================================="
echo ""

case $SCENARIO in
    3)
        echo "Cleaning SonarQube..."
        oc delete all -l app=sonarqube -n security-tools --ignore-not-found=true
        oc delete pvc sonarqube-data -n security-tools --ignore-not-found=true
        echo "Freed ~1GB RAM"
        ;;
    4)
        echo "Cleaning Nexus..."
        oc delete all -l app=nexus -n cicd --ignore-not-found=true
        oc delete pvc nexus-data -n cicd --ignore-not-found=true
        echo "Freed ~1GB RAM"
        ;;
    7)
        echo "Cleaning Loki..."
        oc delete all -l app=loki -n security-demo --ignore-not-found=true
        oc delete configmap loki-config -n security-demo --ignore-not-found=true
        echo "Freed ~256MB RAM"
        ;;
    8)
        echo "Cleaning Keycloak..."
        oc delete all -l app=keycloak -n security-tools --ignore-not-found=true
        oc delete all -l app=keycloak-db -n security-tools --ignore-not-found=true
        oc delete pvc keycloak-db -n security-tools --ignore-not-found=true
        echo "Freed ~1.5GB RAM"
        ;;
    *)
        echo "Unknown scenario: $SCENARIO"
        exit 1
        ;;
esac

echo ""
echo "Waiting for pods to terminate..."
sleep 10

echo ""
echo "Current memory status:"
./scripts/memory-check.sh
