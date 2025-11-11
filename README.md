
# Everfit Assessment Application

This repository is a microservice example for the Everfit technical assessment, implemented with Next.js. It demonstrates modern CI/CD automation, containerization, and integration with a centralized deployment system.

## Overview

- **Purpose:** Example microservice for assessment, built with Next.js.
- **Scope:** Application code, Dockerfile, and CI pipeline. Deployment is managed externally.

## CI/CD Pipeline Flow

On every push to the `main` branch, the GitHub Actions pipeline is triggered. The pipeline automates the following stages:

---

## About `.github/workflows/dev.yml`

This workflow file implements the full CI/CD pipeline for the development environment:

- **Trigger:** Runs on every push to `main`.
- **Build:** Installs dependencies, builds the app, and creates a Docker image.
- **Test:** Runs unit tests (if defined in `package.json`).
- **Deploy:** Pushes the image to ECR, then updates the image tag in the infrastructure repository (`dev/demo-app.yaml`).
- **Automation:** Automatically creates and merges a PR in the infrastructure repo, ensuring the new image is deployed to the Kubernetes dev namespace.

### Key Secrets Required

| Name                    | Description                                 |
|-------------------------|---------------------------------------------|
| `AWS_ACCESS_KEY_ID`     | AWS credentials for ECR push                |
| `AWS_SECRET_ACCESS_KEY` | AWS credentials for ECR push                |
| `AWS_REGION`            | AWS region for ECR                          |
| `ECR_REGISTRY`          | ECR registry URL                            |
| `ECR_REPOSITORY`        | ECR repository name                         |
| `INFRA_REPO_TOKEN`      | GitHub token with write access to infra repo|

### Tools Used

- [`yq`](https://github.com/mikefarah/yq) for YAML editing
- [GitHub CLI (`gh`)](https://cli.github.com/) for PR creation and merging

---

### 1. Build

- Installs dependencies using Yarn.
- Builds the Next.js application.
- Packages the app into a Docker image.

### 2. Test

- Runs unit tests (ensure a `test` script exists in `package.json`).
- Fails the pipeline if tests do not pass.

### 3. Deploy

- Pushes the built Docker image to Amazon ECR.
- Automatically clones the [`everfit-assessment-infrastructure`](https://github.com/HauTruongIT/everfit-assessment-infrastructure) repository.
- Updates the image tag in the relevant Helm values file (e.g., `dev/demo-app.yaml`).
- Creates a Pull Request in the infrastructure repo with the new tag.
- Once the PR is merged, the infrastructure repo pipeline deploys the new image to Kubernetes.

#### Example Workflow Snippet

```yaml
on:
	push:
		branches: [ main ]

jobs:
	build:
		steps:
			- run: yarn install --frozen-lockfile --silent
			- run: yarn build
			- run: docker build -t $IMAGE_TAG .
	test:
		steps:
			- run: yarn test
	push-to-ecr:
		steps:
			- run: docker push $IMAGE_TAG
	update-infra:
		steps:
			- run: gh pr create --repo HauTruongIT/everfit-assessment-infrastructure ...
```

#### Required Environment Variables / Secrets

| Name                    | Description                                 |
|-------------------------|---------------------------------------------|
| `AWS_ACCESS_KEY_ID`     | AWS credentials for ECR push                |
| `AWS_SECRET_ACCESS_KEY` | AWS credentials for ECR push                |
| `AWS_REGION`            | AWS region for ECR                          |
| `ECR_REGISTRY`          | ECR registry URL                            |
| `ECR_REPOSITORY`        | ECR repository name                         |
| `INFRA_REPO_TOKEN`      | GitHub token with write access to infra repo|

## Separation of Concerns

- **Application repo:** Handles CI (build, test, image push, PR creation).
- **Infrastructure repo:** Handles CD (deployment to Kubernetes).

## Benefits

- **Developer velocity:** Developers only push code; deployment is automated.
- **Reduced manual steps:** No need to manually update deployment manifests or trigger deployments.
- **Auditability:** All changes are tracked via PRs and CI logs.

---
