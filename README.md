# Tekinsible
*TE*RRAFORM 
JEN*KIN*S 
*S*ONARQUBE 
ANS*IBLE* 
DOCKER 
AWS
------------------------------------------------------------------------------------------

Following is the Workflow Documentation for the Project

---------------------------------------------------------------------

## Introduction

This documentation provides a detailed explanation of the CI/CD pipeline implemented in this project. The pipeline includes the following components:

1. GitHub Actions: The CI/CD workflow is triggered on every push or pull request made to the main branch.

2. Terraform: The Terraform script is executed as part of the pipeline to provision AWS resources, such as VPC, subnets, internet gateway and Security Group Rules. Triggerred through ci-cd pipeline

3. Ansible: The Ansible script is triggered after the Terraform script completes, through terraform. It copies the docker-compose.yml file to the remote system and runs it.

4. Docker Compose: The docker-compose.yml file is responsible for creating and running containers for Jenkins and SonarQube on the remote system.

Ideally, the code to be worked on should be fetched from another repo, evauluated on SonarQube and then deploy through Jenkins Pipeline.
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

---------------------------------------------------------------------

## IMPORTANT:

1. If S3 bucket is not initialized correctly, each pipeline trigger will create NEW RESOURCES instead of modifying previous ones.
2. The S3 Bucket used in the code is DOES NOT ENABLES ENCRYPTION OF THE STATE.
2. Ansible's Config file must be init through CLI.
3. Ansible's 'inventory.ini' can only be seen when run locally. In ci-cd pipeline, it is created in environment file of github workflows and removed once pipeline is completed, providing better secrecy to keypairname.
4. 'docker-compose.yml' is stored 'locally' and then copied to remote system through ansible.
5. 'docker-compose.yml' allows Jenkins to host on the remote system in this project. Beware! it is a bad practice and is depriciated.

---------------------------------------------------------------------

## Prerequisites

Before setting up this CI/CD pipeline, ensure you have the following prerequisites:

1. **AWS Account:** Access to an AWS account with the necessary permissions to create and manage resources.
2. **GitHub Repository:** A GitHub repository to host the project and CI/CD configuration files.
3. **GitHub Secrets:** Set up the following secrets in your GitHub repository:
   - `AWS_KEY_ID`
   - `AWS_KEY_PASS`
   - `KEYPAIRNAME`
   - `KEYVALUE`

---------------------------------------------------------------------

## Getting Started

To get started with this project, follow these steps:

1. **Clone the Repository:**
   ```sh
   git clone https://github.com/Ahmad-Waseem/tekinsible.git
   cd tekinsible
   ```

2. **Configure Terraform Backend:**
   Update the `s3_bucket.tf` file with your S3 bucket name and region.

3. **Update Terraform Variables:**
   Modify the `network.tfvars` and `ec2.tfvars` files with your specific configurations.

4. **Commit and Push Changes:**
   ```sh
   git add .
   git commit -m "Initial setup"
   git push origin dev
   ```

5. **Trigger CI/CD Pipeline:**
   The pipeline will automatically run on every push or pull request to the main branch.

---------------------------------------------------------------------

## Troubleshooting

Here are some common issues and their solutions:

1. **Workflow Pipeline Errors**
   - Make sure the sanity ssh-agent of the environment being able to access secret key as '.pem' file.
   - Make sure that the agent accesses the key with lower restrictions on reading access.
   - Use conditions in Stages observing the completion of previous stage, so that no job runs before completion of prerequisite one.
   - Use root user where neccessary. Make sure to mention the directory we want workflow to fetch/execute/modify scripts.

2. **Terraform Errors:**
   - Ensure your AWS credentials are correctly set up in GitHub Secrets.
   - Check the Terraform state file configuration in the `s3_bucket.tf` file.
   - Put /.terraform, terraform.state, .terraform, .terraform/ files in git ignore to solve large file errors.
   - The network is needed to be attached to the subnets if Route Table is not being made.
   - Private Networks will not run until NAT Table is made, which is out of AWS FREE TIER.

3. **Ansible Playbook Fails:**
   - Verify that the public IP of the EC2 instance is correctly added to the `inventory.ini` file.
   - Ensure there is no extra/less space between each letter/symbol of inventory.ini template.
   - Ensure the ansible playbook is running AFTER assignment of public ip to EC2.
   - Ensure the SSH key provided in GitHub Secrets matches the key pair used for the EC2 instance.

4. **Docker Compose Issues:**
   - Ensure Docker and Docker Compose are correctly installed on the remote system.
   - Verify that the `docker-compose.yml` file has the correct configurations for ports of Jenkins and SonarQube.
   - Minimum requirement of both SonarQube and Jenkins to Run simulataneously is to use 'T2.medium' on AWS. Anything less will pop bottleneck, overload or throw service crashing errors. 
   - Open the jenkins using 'docker-compose logs --follow' to get password for jenkins. Configure it through default settings. If it skips plugins like 'pipeline' or shows only one plugin, Jenkins is not configured correctly.
---------------------------------------------------------------------

## Future Enhancements

Consider implementing the following enhancements to improve the pipeline:

1. **Automated Testing:**
   - Add unit and integration tests to the CI/CD pipeline to ensure code quality and reliability.

2. **Security Enhancements:**
   - Implement additional security measures such as IAM roles and policies to restrict access to AWS resources.

3. **Scalability:**
   - Enhance the infrastructure to support auto-scaling and load balancing for better performance and availability.

---------------------------------------------------------------------

## References

Here are some useful references for further reading:

1. [Terraform Documentation](https://www.terraform.io/docs/index.html)
2. [Ansible Documentation](https://docs.ansible.com/)
3. [Docker Compose Documentation](https://docs.docker.com/compose/)
4. [GitHub Actions Documentation](https://docs.github.com/en/actions)

---------------------------------------------------------------------

## Contact

For any questions or issues, please contact:

- **Project Maintainer:** Muhammad Ahmed Waseem
- **Email:** [ahmedwaseem7686@gmail.com](mailto:ahmedwaseem7686@gmail.com)
- **GitHub:** [Ahmad-Waseem](https://github.com/Ahmad-Waseem)

---------------------------------------------------------------------

