# Security and configuration notes

This repository is a local educational lab. Do not copy its manifests into a shared or production cluster without reviewing and adapting them.

## Credentials

Do not commit passwords, tokens, private keys, kubeconfigs, or production connection strings.

The Keycloak/PostgreSQL manifest references a Secret named `keycloak-db-secret`. Create it in your local cluster before deploying Keycloak:

```bash
oc create secret generic keycloak-db-secret \
  --namespace security-tools \
  --from-literal=username='REPLACE_WITH_LOCAL_DB_USER' \
  --from-literal=password='REPLACE_WITH_A_UNIQUE_LOCAL_PASSWORD' \
  --from-literal=database='keycloak'
```

Use a separate local admin password for Keycloak:

```bash
oc create secret generic keycloak-admin-secret \
  --namespace security-tools \
  --from-literal=username='admin' \
  --from-literal=password='REPLACE_WITH_A_UNIQUE_LOCAL_PASSWORD'
```

These commands create cluster Secrets from values you provide locally. They do not encrypt secrets at rest by themselves; configure cluster encryption and access controls where appropriate.

The realm import file contains demo users for identity-flow testing. Set their passwords through the Keycloak administration interface after importing the realm, rather than committing passwords in the repository.

## Vulnerable application

The Flask workload is deliberately vulnerable for controlled security exercises. It includes insecure patterns by design, such as SQL injection, XSS, command injection and environment disclosure.

- Run only in an isolated disposable lab.
- Do not expose the Route to public networks.
- Do not use real accounts, secrets, personal information or production data.
- Rebuild from a clean environment after experiments.
- Do not reuse this application or its container image in production.

## RBAC and network policies

Review every Role, ClusterRole, RoleBinding, ClusterRoleBinding and NetworkPolicy before applying it. Confirm that permissions are limited to the intended service accounts and namespaces. Test effective permissions with `oc auth can-i` and validate both allowed and denied network paths.

NetworkPolicy enforcement depends on the cluster network plugin. A manifest being accepted by the API server does not prove that traffic is being filtered.

## Image and pipeline security

The Tekton examples reference external images and cluster-provided tasks. Pin image versions/digests, review task sources, configure least-privilege service accounts, and verify registry TLS behavior for your cluster.

A scanner task only acts as a pipeline gate if its exit status is propagated and the pipeline fails on the configured severity threshold. Review the actual TaskRun and PipelineRun results rather than assuming that a scan was enforced.

## Before publishing changes

Search for accidentally committed credentials and rotate any real credential that may have been exposed. Removing a secret from the latest file does not erase it from Git history. If a real credential was committed, revoke/rotate it immediately and consider history cleanup separately.
