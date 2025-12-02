#!/bin/bash

SCENARIO=$1

if [ -z "$SCENARIO" ]; then
    echo "Usage: ./scripts/scenario-test.sh <scenario-number>"
    echo "Example: ./scripts/scenario-test.sh 3"
    exit 1
fi

echo "=========================================="
echo "Testing Scenario $SCENARIO"
echo "=========================================="
echo ""

# Check memory before
echo "Memory BEFORE deployment:"
./scripts/memory-check.sh
echo ""

read -p "Press Enter to deploy scenario $SCENARIO..."

case $SCENARIO in
    3)
        echo "Deploying SonarQube (minimal)..."
        oc apply -f scenarios/scenario3-sonarqube/deployment-minimal.yaml
        echo "Waiting 3 minutes for SonarQube to start..."
        sleep 180
        oc wait --for=condition=available --timeout=300s deployment/sonarqube -n security-tools 2>/dev/null || echo "Still starting..."
        ;;
    4)
        echo "Deploying Nexus (minimal)..."
        oc apply -f scenarios/scenario4-nexus/deployment-minimal.yaml
        echo "Waiting 3 minutes for Nexus to start..."
        sleep 180
        oc wait --for=condition=available --timeout=300s deployment/nexus -n cicd 2>/dev/null || echo "Still starting..."
        ;;
    7)
        echo "Deploying Loki (minimal)..."
        oc apply -f scenarios/scenario7-logging/loki-minimal.yaml
        sleep 30
        ;;
    8)
        echo "Deploying Keycloak (minimal)..."
        oc apply -f scenarios/scenario8-keycloak/deployment-minimal.yaml
        echo "Waiting 3 minutes for Keycloak to start..."
        sleep 180
        oc wait --for=condition=available --timeout=300s deployment/keycloak -n security-tools 2>/dev/null || echo "Still starting..."
        ;;
    *)
        echo "Unknown scenario: $SCENARIO"
        exit 1
        ;;
esac

echo ""
echo "Memory AFTER deployment:"
./scripts/memory-check.sh
echo ""

echo "Scenario $SCENARIO deployed!"
echo ""
echo "When done testing, cleanup with:"
echo "  ./scripts/cleanup-scenario.sh $SCENARIO"
