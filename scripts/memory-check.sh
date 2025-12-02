#!/bin/bash

echo "=========================================="
echo "MEMORY STATUS CHECK"
echo "=========================================="
echo ""

# Node memory
echo "Node Memory Usage:"
oc adm top nodes 2>/dev/null || echo "Metrics not available yet"
echo ""

# Pod memory by namespace
echo "Memory by Namespace:"
for ns in security-demo cicd security-tools openshift-gitops openshift-operators; do
    total=$(oc adm top pods -n $ns 2>/dev/null | awk 'NR>1 {sum+=$3} END {print sum}')
    if [ -n "$total" ] && [ "$total" != "0" ]; then
        echo "  $ns: ${total}Mi"
    fi
done
echo ""

# Top memory consumers
echo "Top 10 Memory Consuming Pods:"
oc adm top pods -A 2>/dev/null | sort -k4 -h -r | head -11
echo ""

# Cleanup suggestions
echo "Cleanup Suggestions:"
completed=$(oc get pods -A --field-selector=status.phase==Succeeded --no-headers 2>/dev/null | wc -l)
failed=$(oc get pods -A --field-selector=status.phase==Failed --no-headers 2>/dev/null | wc -l)
echo "  Completed pods to delete: $completed"
echo "  Failed pods to delete: $failed"

if [ "$completed" -gt 0 ] || [ "$failed" -gt 0 ]; then
    echo ""
    echo "Run this to free memory:"
    echo "  oc delete pod --field-selector=status.phase==Succeeded -A"
    echo "  oc delete pod --field-selector=status.phase==Failed -A"
fi
