FROM jenkins/jenkins:lts

USER root

# Install basic tools (skip shadow)
RUN apt-get update && apt-get install -y \
    git curl gnupg lsb-release sudo

# Install Docker CLI
RUN mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian bookworm stable" \
       > /etc/apt/sources.list.d/docker.list \
    && apt-get update \
    && apt-get install -y docker-ce-cli docker-compose-plugin

# Create docker group and add Jenkins user
RUN groupadd docker || true && usermod -aG docker jenkins

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/

USER jenkins
ENV PATH=$PATH:/usr/local/bin

