#!/bin/bash
set -e

NAMESPACE="security-demo"

echo "Deploying application to $NAMESPACE..."

oc apply -f application/vulnerable-app/deployment.yaml -n $NAMESPACE

sleep 5

echo "Starting build..."
cd application/vulnerable-app
oc start-build vulnerable-app --from-dir=. --follow -n $NAMESPACE
cd ../..

echo "Waiting for deployment..."
oc rollout status deployment/vulnerable-app -n $NAMESPACE --timeout=300s

echo "Application deployed!"
ROUTE=$(oc get route vulnerable-app -n $NAMESPACE -o jsonpath='{.spec.host}')
echo "Application URL: https://$ROUTE"
