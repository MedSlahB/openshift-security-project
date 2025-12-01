#!/bin/bash
set -e

echo "Creating ClusterRole..."
cat <<YAML | oc apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: pipeline-deployer
rules:
- apiGroups: [""]
  resources: ["pods", "services", "configmaps", "secrets"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: ["route.openshift.io"]
  resources: ["routes"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: ["build.openshift.io"]
  resources: ["buildconfigs", "builds"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: ["image.openshift.io"]
  resources: ["imagestreams"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
YAML

echo "Creating ServiceAccount..."
oc create sa pipeline-sa -n cicd --dry-run=client -o yaml | oc apply -f -

echo "Creating ClusterRoleBinding..."
cat <<YAML | oc apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: pipeline-sa-deployer
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: pipeline-deployer
subjects:
- kind: ServiceAccount
  name: pipeline-sa
  namespace: cicd
YAML

echo "RBAC setup complete!"
