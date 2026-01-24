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

Each service is containerized using Docker and run locally using Docker Compose. Follow these steps to build and run the services:

i. Build Docker Images

Navigate to each service’s directory and build its Docker image:
     
     docker build -f $IMAGE_NAME:$IMAGE_TAG

ii. Verify images

      docker images

iii. Update docker-compose.yml

Specify the built images for each service in the docker-compose.yml file.

iv. Run Services
    Start all services in detached mode
    
      docker compose up -d
      

What this step achieves:

- Isolates each service in its own container
- Enables local development with a production-like setup
- Demonstrates a classic 3-tier architecture
- Uses persistent storage for the database
- Allows developers to run the entire system with a single command



Step 2: K3s Deployment
Once the services are validated locally, they can be deployed on a Kubernetes cluster (using K3s in this project) for orchestration, scalability, and high availability. The k8s/ folder contains all the manifest files required for deploying microservices to a Kubernetes cluster.

i.  Apply Kubernetes Manifests

Deploy all services to your cluster:

       kubectl apply -f k8s/

 This will create all deployments, services, and any necessary configuration objects defined in the k8s/ folder.

 ii. Verify Deployments

Check the status of your pods, deployments, and services

          kubectl get deployments -n
          kubectl get pods
          kubectl get svc

  This ensures that all microservices are running and accessible within the cluster.


What this step achieves:

- Lightweight Kubernetes (K3s) suitable for learning and edge environments
- Docker images are pushed to a container registry
- Each service runs as an independent Kubernetes workload
- Services communicate using internal Kubernetes networking
- Frontend is exposed externally using a NodePort service
- This step focuses on container orchestration, scalability, and service isolation.



Step 3: Jenkins CI/CD Pipeline
This section explains how to install Jenkins, create a pipeline job, and use the existing Jenkinsfile to automate builds and deployment.

i. Install jenkins

           docker pull jenkins/jenkins:lts
           docker run -d \  -p 8080:8080 \  -p 50000:50000 \  --name jenkins \  -v jenkins_home:/var/jenkins_home \  jenkins/jenkins:lts

-p 8080:8080: Access Jenkins web interface
-p 50000:50000: Jenkins agent port
-v jenkins_home:/var/jenkins_home: Persist Jenkins data


ii. Access Jenkins Web UI

- Open a browser and go to:

                http://localhost:8080

- Unlock Jenkins using the initial password:
  
                 docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
  
  - Install suggested plugins and create your admin user.
 
iii. Create a Pipeline Job
-Go to Jenkins Dashboard → New Item
-Enter a name (e.g., Microservices-CI-CD)
- Select Pipeline → Click OK
  
iv.Configure Pipeline to Use Repo Jenkinsfile
- In Pipeline configuration:
- Definition → Select Pipeline script from SCM
- SCM → Git
- Repository URL → https://github.com/dhakallokesh/Micro-Services.git
- Branch → main
- Script Path → Jenkinsfile
- Save the job.


v. Run the Pipeline
- Click Build Now to execute the pipeline.
- Jenkins will automatically:
- Checkout your repository
- Build Docker images for all services
- Run tests (if defined in Jenkinsfile)
- Push images to Docker registry
- Deploy services to Kubernetes using the k8s/ manifests



