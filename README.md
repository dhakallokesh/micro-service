Microservices Project Deployment Guide

This repository demonstrates a complete end-to-end microservices deployment workflow, starting from local development to Kubernetes deployment and automated CI/CD.


Architecture Components

- Frontend: React application served via Nginx
- API Service: Node.js backend handling client requests
- Worker Service: Python service for background processing
- Database: MySQL for persistent data storage
- Cache / Messaging: Redis for fast access and task coordination
- Orchestration: Kubernetes (K3s)
- CI/CD: Jenkins pipeline


Step 1: Docker & Docker Compose

In the first step, each service is containerized using Docker and run locally using Docker Compose.

What this step achieves:

- Isolates each service in its own container
- Enables local development with a production-like setup
- Demonstrates a classic 3-tier architecture
- Uses persistent storage for the database
- Allows developers to run the entire system with a single command



Step 2: K3s Deployment
In the second step, the application is deployed to a K3s Kubernetes cluster.
Key highlights:

- Lightweight Kubernetes (K3s) suitable for learning and edge environments
- Docker images are pushed to a container registry
- Each service runs as an independent Kubernetes workload
- Services communicate using internal Kubernetes networking
- Frontend is exposed externally using a NodePort service
- This step focuses on container orchestration, scalability, and service isolation.

Step 3: Jenkins CI/CD Pipeline

The final step introduces automation using Jenkins.
- CI/CD Pipeline Capabilities:
- Pulls code from GitHub
- Builds Docker images for all services
- Pushes versioned images to Docker Hub
- Updates Kubernetes deployment manifests dynamically
- Deploys new versions to the K3s cluster
- Verifies rollout status
- Automatically rolls back services if deployment fails

