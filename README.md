# Tekinsible
*TE*RRAFORM
JEN*KIN*S
AN*SIBLE*
DOCKER
------------------------------------------------------------------------------------------

GitHub Documentation for the Project

---------------------------------------------------------------------

## Introduction

This documentation provides a detailed explanation of the CI/CD pipeline implemented in this project. The pipeline includes the following components:

1. GitHub Actions: The CI/CD workflow is triggered on every push or pull request made to the main branch.

2. Terraform: The Terraform script is executed as part of the pipeline to provision AWS resources, such as VPC, subnets, internet gateway and Security Group Rules. Triggerred through ci-cd pipeline

3. Ansible: The Ansible script is triggered after the Terraform script completes, through terraform. It copies the docker-compose.yml file to the remote system and runs it.

4. Docker Compose: The docker-compose.yml file is responsible for creating and running containers for Jenkins and SonarQube on the remote system.

In the following sections, we will provide a step-by-step explanation of each component and its configuration.

---------------------------------------------------------------------

## CI/CD Workflow

Directory: '.github/workflows'
The CI/CD workflow is defined in the ci-cd.yml file. It is executed on every push or pull request made to the main branch. The workflow includes the following jobs:

1. Terraform: This job is responsible for provisioning AWS resources using Terraform. It sets up the required providers, initializes the VPC, creates subnets, attaches an internet gateway and configures route tables.

2. Ansible: This job is triggered after the Terraform job completes. It uses Ansible to copy the docker-compose.yml file to the remote system and runs it.

Each job is executed on an Ubuntu virtual machine, and the necessary configurations and dependencies are set up through the running the scripts.

---------------------------------------------------------------------

## Terraform Scripts

Directory: 'terraform/'
The Terraform script is divided into multiple files: main.tf, s3_bucket.tf, instance.tf and variables.tf. These files define the AWS resources and configurations required for the VPC setup.

1. main.tf: This file contains the configuration for the VPC, subnets, internet gateway, route tables and their associations. It uses variables defined in the variables.tf; initialized through network.tfvars file to customize the configuration.

2. s3_bucket.tf: This file specifies the backend configuration for storing the Terraform state. In this case, it is configured to use an S3 bucket named "terra-byte-storage" in the "us-east-2" region.

3. variables.tf: This file defines the variables used in the Terraform script. It includes variables for the region, CIDR block, subnet configurations, engine AMI, and key pair information. It also includes default values for neccessary resources.

4. instance.tf: This file completely controls the provisioning of AWS Elastic Cloud Compute (EC2) and customized resources for it. It includes SSH protocols, Network Security Group and information about Ingress and Egress ports defining the limits of the access. It attaches the EC2 instance through AMI, Security Group and Public Subnet of VPC. After EC2 provisioning is complete, it initializes ansible's inventory.ini dynamically using the public ip assigned to EC2 instance, where the instance's keypairname is keypair is already generated manually and provided to the workflow using Github Secrets for enhanced security. Gets variables through variables.tf; init through ec2.tfvars!

The Terraform script is executed during the CI/CD pipeline to provision the required AWS resources for the application.

---------------------------------------------------------------------

## Ansible Script

Directory: '/terraform'
The Ansible script is defined in the ansible_ec2_config.yml file. It is triggered after the Terraform script completes and is responsible for configuring the remote system to run the application.

The script performs the following tasks:

1. Updates the apt cache on the remote system.

2. Adds the Docker repository and installs Docker and Docker Compose.

3. Adds the "ubuntu" user to the Docker group.

4. Copies the docker-compose.yml file to the remote system.

5. Runs the docker-compose.yml file using the "sudo docker-compose up -d" command.

These tasks ensure that the necessary dependencies are installed and the application containers are up and running on the remote system.

---------------------------------------------------------------------

## Docker Compose Configuration

Directory: 'terraform/'
The docker-compose.yml file defines the services and configurations required for running the Jenkins and SonarQube containers.

1. Jenkins: This service is based on the "jenkins/jenkins:lts" image. It runs on port 8080 and 50000 and mounts the Jenkins configuration and Docker socket volumes for persistence and access to the host's Docker daemon.

2. SonarQube: This service is based on the "sonarqube:latest" image. It runs on port 9000 and depends on the "db" service. It sets environment variables for the SonarQube database connection.

3. DB: This service is based on the "postgres:latest" image. It runs a PostgreSQL database for SonarQube and sets the necessary environment variables.

The docker-compose.yml file ensures that the Jenkins and SonarQube containers are properly configured and running on the remote system. Make sure that EC2 instance has opened the ingress ports mentioned above.

---------------------------------------------------------------------

## Conclusion

In this documentation, we have provided a detailed explanation of the CI/CD pipeline implemented in this project. The pipeline includes GitHub Actions for triggering the workflow, which runs Terraform for provisioning AWS resources, at last triggers Ansible for configuring the remote system and pinging Docker Compose for running the application containers.

By following this pipeline, you can automate the deployment and configuration of your application. Add 'nginx' and complete SonarQube and Jenkins Pipeline to Deploy your app. Super time saving and ensuring consistency in your DevOps processes!
