# OpenShift DevSecOps Platform

A hands-on DevSecOps lab focused on securing, automating, and observing application deployments on OpenShift using Kubernetes-native tooling.

## Overview

This project brings together containerization, CI/CD, GitOps, platform security, identity management, monitoring, and centralized logging in a local OpenShift environment based on CodeReady Containers (CRC).

The objective was to build and validate an end-to-end application delivery workflow while applying security controls throughout the platform and deployment lifecycle.

## Architecture

```text
Developer
   |
   v
Git Repository
   |
   +----------------------+----------------+
   |                      |                |
   v                      v                v
Tekton CI/CD           ArgoCD          Keycloak
   |                      |                |
   +----------+-----------+                +--> SSO / Identity
              |
              v
          OpenShift / Kubernetes
              |
       Application Workloads
              |
     +--------+---------+---------+
     |                  |         |
 Prometheus           Loki    NetworkPolicy
     |                  |
  Grafana           Promtail
     |
 Alertmanager
```

## Technologies

- **Platform:** OpenShift, Kubernetes, CodeReady Containers (CRC)
- **Containers:** Docker
- **CI/CD:** Tekton
- **GitOps:** ArgoCD
- **Security:** RBAC, SCC, NetworkPolicy, secrets, Keycloak
- **Observability:** Prometheus, Grafana, Loki, Promtail, Alertmanager
- **Application delivery:** Kubernetes/OpenShift manifests and Helm

## What is demonstrated

### Platform and containerization

- Deployment and management of containerized workloads on OpenShift.
- Kubernetes/OpenShift manifests for application and platform components.
- Persistent storage using PVCs where required.

### CI/CD

- Tekton pipelines for automated application delivery.
- Pipeline triggers and reusable pipeline components.
- Integration of quality and security-oriented checks into the delivery workflow.

### GitOps

- ArgoCD-based application synchronization.
- Declarative deployment configuration stored in Git.
- Separation between application source and deployment configuration.

### Platform security

- RBAC roles, role bindings, and service accounts.
- OpenShift Security Context Constraints (SCC).
- Network policies to control workload communication.
- Secret management through Kubernetes/OpenShift resources.
- Keycloak integration for centralized identity, authentication, authorization, and SSO.

### Observability

- Prometheus metrics collection.
- Grafana dashboards.
- Loki-based log aggregation.
- Promtail log collection.
- Alertmanager for alert handling.

## Repository structure

The repository contains Kubernetes/OpenShift manifests, Tekton resources, GitOps configuration, security policies, monitoring/logging components, and supporting configuration used to build the lab environment.

## Environment

The platform was developed and tested locally using **CodeReady Containers (CRC)** rather than a production OpenShift cluster. Resource constraints of the local environment were considered during deployment and troubleshooting.

## Scope and limitations

This is a personal hands-on lab / portfolio project. It is intended to demonstrate practical understanding of OpenShift, Kubernetes, DevSecOps, CI/CD, GitOps, security, and observability concepts.

It should not be interpreted as a production reference architecture. Components were tested within the constraints of a local development environment.

## Key learning outcomes

- Securing containerized workloads with Kubernetes/OpenShift security controls.
- Building CI/CD workflows with Tekton.
- Applying GitOps principles with ArgoCD.
- Integrating centralized identity with Keycloak.
- Implementing monitoring, logging, and alerting for a container platform.
- Troubleshooting platform and resource constraints in a local OpenShift environment.
