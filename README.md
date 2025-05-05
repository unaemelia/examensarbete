# Secuflow: Automation of security checks in CI/CD for Kubernetes

## About the Project
This project is part of the final examination (Examensarbete) for the *Systemutvecklare DevSecOps* education program. It explores how security policies and automated scanning tools can be integrated into Kubernetes-based CI/CD workflows. The goal is to demonstrate practical enforcement of container security best practices using:

- **OPA Gatekeeper** for Kubernetes policy control
- **Trivy** for vulnerability and misconfiguration scanning

The project simulates a real-world setup with AKS (Azure Kubernetes Service), enforcing policies and performing static and dynamic security testing before container deployment.

## Features and Technologies
- **AKS & ACR**: Azure Kubernetes Service and Azure Container Registry used for hosting and storing images
- **OPA Gatekeeper**: Enforces Kubernetes admission control via custom policies
- **Trivy**: Scans for vulnerabilities, misconfigurations, and insecure libraries
- **PowerShell Automation**: Script to run multiple policy test cases automatically

## Implemented Policies with Gatekeeper
| Policy                              | Description                                                    | Status  |
|-------------------------------------|----------------------------------------------------------------|---------|
| `Disallow Privileged Containers`    | Prevents containers from running with `privileged: true`       | ✅ Implemented |
| `Require Labels`                    | Requires `owner` and `team` labels on pods and deployments     | ✅ Implemented |
| `Disallow ImagePullPolicy Always`  | Blocks usage of `imagePullPolicy: Always`                      | ✅ Implemented |

## Test Execution via PowerShell Script
The `run-gatekeeper-tests.ps1` script applies all relevant constraints and manifests under `gatekeeper-tests/`, then prints whether each deployment or pod is `PASSED` or `BLOCKED` based on policy violations.

### To run:
```powershell
./run-gatekeeper-tests.ps1
```
This script:
- Applies ConstraintTemplates and Constraints
- Waits for Gatekeeper webhook to initialize
- Applies manifest test cases
- Cleans up after tests

## Trivy Security Scanning
Multiple container images were scanned using Trivy for:

| Test Case                 | Image Name           | Result Summary                                                       |
|---------------------------|----------------------|--------------------------------------------------------------------- |
| Secure base image         | `secuflow:v3`        | ✅ No critical vulnerabilities found                                 |
| Vulnerable base image     | `secuflow:vuln`      | ❌ Critical CVEs found in OS packages                                |
| Vulnerable OS image       | `vuln-debian-stretch`| ❌ Severe critical OS vulnerabilities detected (pure Debian Stretch) |
| Misconfigured Dockerfile  | `vuln-misconfig`     | ❌ Missing `USER` & `HEALTHCHECK` instructions                       |
| Vulnerable npm packages   | `vuln-npm-app`       | ❌ Found high & critical vulnerabilities in dependencies             |
| Insecure libraries        | `vuln-node-app`      | ❌ 1300+ high and 36 critical CVEs in libraries                      |

### Sample Trivy command:
```bash
trivy image --format json --output results.json secuflow:v3
```

## Project Structure
```
secuflow/
├── gatekeeper-tests/         # Rego policies, constraint templates, constraints, and Kubernetes test manifests for Gatekeeper
│   ├── constraints/          # YAML definitions for constraints linked to the Rego policies
│   ├── manifests/            # Test deployments and pods for validating policies
│   └── policies/             # Rego policy files for validation (e.g., disallow privileged, require labels)
├── src/                      # Node.js application source code (Express app)
├── trivy-results/            # JSON and TXT reports from Trivy scans (vulnerable images, package managers, libraries and misconfig)
├── trivy-tests/              # Vulnerable Dockerfiles and test images for Trivy scanning
├── deploy.ps1                # Main deployment script: builds, scans, and deploys the app to AKS
├── deployment.yaml           # Kubernetes deployment spec for the application (used in deploy.ps1)
├── Dockerfile                # Container build file for the Node.js application
└── run-gatekeeper-tests.ps1  # Script to automate Gatekeeper policy tests by applying manifests and cleaning up
```

## Setup Requirements
- Azure CLI + AKS cluster configured with ACR integration
- `kubectl` configured to access your AKS context
- Trivy installed (`https://aquasecurity.github.io/trivy/`)
- PowerShell (Windows or cross-platform Core)

## Summary
This project demonstrates hands-on DevSecOps by integrating policy-as-code and security scanning into the container pipeline. All components were tested in a production-like AKS environment, and the results validate the effectiveness of automated policy enforcement using Gatekeeper and Trivy.
