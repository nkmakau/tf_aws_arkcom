## Terraform IaC to deploy CI Pipeline to AWS Cloud

This is a four part Series that the final platform will consist of:
 a Jenkins cluster with a dedicated Master and multiple slaves configured in an autoscaling group, 
 a GitLab code repository deployed in a HA configuration with external Elastic File System (EFS) volumes, 
 a hosted Redis cluster, a multi-AZ Postgresql database, 
 and an Elastic Container Registry to store Docker images.

 ### Prerequiste:
 1. AWS CLI
    Check below link on how to install AWS CLI:
    https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html

    verify AWS CLI Installation  by running the below on terminal:
    ```
    $ aws --version
    ```
 2. Terraform
    Check below link on how to install Terraform:
    https://learn.hashicorp.com/tutorials/terraform/install-cli

    Verify Terraform is installed by running the below on terminal:
    
    ```
    $ terraform version
    ```

 3. GIT
    Check below link on how to install Terraform:
    https://git-scm.com/book/en/v2/Getting-Started-Installing-Git

    Verify Git is installed by running the below on terminal:

    ```
    $ git version
    ```

 4. Configure AWS CLI Profile:
    ```
    $ aws Configure --profile [name]
    AWS Access Key ID [None]: <Access Key>
    AWS Secret Access Key [None]: <Secret Key>
    Default region name [None]: <region>
    Default output format [None]: text
    ```

## PART 1: Landing Zone:
This is the foundation of the project and consists of:

#### One Virtual Private Cloud (VPC)
A VPC is required. It enables you to launch AWS resources into a virtual network that you’ve defined. This virtual network closely resembles a traditional network that you’d operate in your own data center.

#### Two public subnets 
These subnets will be used to deploy any resource which will be accessed from the internet, such as our bastion host and Application Load Balancers. These subnets will also provide external internet access for our private resources via the NAT Gateway, which we will deploy here. The two subnets will be assigned to two separate availability zones, so we can deploy resources across each, providing for high availability. Note that Availability Zones (AZs) are physically isolated from one another. 

#### Two private application subnets 
These two subnets, each assigned to unique AZs, will house our application servers. Servers in a private subnet (not attached to an Internet Gateway) will not be directly accessible from the internet and therefore are safe from external attacks. Access to these servers will only be available through a load balancer virtual IP address. 

#### Two private database subnets 
These two subnets, each assigned to unique AZs, will house our database instances. Databases in a private subnet (not attached to an Internet Gateway) will not be directly accessible from the internet and therefore are safe from external attacks. Database access will be very secure, restricted via AWS Security Groups to only allow the GitLab server to access them.  

#### Internet Gateway (IG)
The internet gateway allows our bi-directional internet access to and from services within our VPC.  Note that only resources in our “public” subnets will have access to an internet gateway. 

#### NAT Gateway (NAT)
Network Address Translation (NAT) gateway enable services in our private subnets to connect to the internet or other AWS services, but prevent the internet from initiating a connection with those instances. This is needed for package and patch installs on our private EC2 instances. 

#### Route Tables 
These tables are a set of rules or routes that govern where traffic is routed. We attach a routing table to each subnet. Our public subnets will have a route to the Internet Gateway and our private subnets will have a route to the NAT Gateway. 

## Deploy Landing Zone:
Run a “terraform plan”. Terraform plan will validate the syntax prior to applying the configuration to your AWS account.

Note that it reads all .tf files and is set to create 17 new AWS resources based on the scripts in your working directory. 

Run "terraform apply" to create the resources. Login to AWS console to confirm creation.

## Part 2: Add CI Tools:
We build on the existing infrastructure, adding open source continuous integration tools and the supporting infrastructure to provide a highly available deployment.
We ontinue to use Terraform as the tool of choice to script the deployment of a Jenkins master server, Jenkins slaves within an autoscaling group and a highly available GitLab repository behind a load balancer.

To build out the application servers and associated infrastructure we continue to build out additional Terraform scripts which will provision the EC2 instances, application load balancers, RDS instances, Redis clusters, EFS (NAT) volumes, SSH key pairs, security groups and KMS Encryption keys.


This Part Consists of:
#### Main.tf
To build out the application servers and associated infrastructure we continue to build out additional Terraform scripts which will provision the EC2 instances, application load balancers, RDS instances, Redis clusters, EFS (NAT) volumes, SSH key pairs, security groups and KMS Encryption keys.

#### git.sh
The git.sh script, referenced in the main.tf script above, provides a simple bash script to perform the initial configuration of the GitLab EC2 instance.

The function of this script is to:

   - Install common software and tools needed for server administration
   - Install the AWS CLI
   - Download the GitLab software
   - Configure the fstab to mount the EFS volumes at boot time and mount the EFS volumes
   - Run a AWS CLI command to fetch the public DNS name of the load balancer that will service GitLab and set an environment variable for use during installation of Gitlab
   - Install GitLab and set it to start automatically at boot .

#### gitlab_application_user_data.tpl
Create this file in your “templates” sub-folder so it to be found by the reference to it in the main.tf script.

This template file is a cloud-init script, which is how you initialize your EC2 instances upon first boot. 

The function of this script is to:

   - Customize the Gitlab configuration to:
      - Prevent Gitlab from starting if the shared NFS volumes are not mounted
      - Disable internal Postgresql database and enable the use of an External Postgresql database
      - Set the Gilab URL to the load balancer public DNS name
      - Disable internal Redids and enable the use of an External Redis cache cluster
      - Setup common Operating System user IDs (UID) and Group IDs (GID) to file permission issues are not created between Gitlab servers
   - Reconfigure Gitlab with the above customizations.

#### sg.tf
This script is responsible for build out all of the security groups that control inbound and outbound network access to our services.

A brief description of the six security groups (SGs):

   1. efs-general 
      – Applied to EFS volumes to allow port 2049 from the private subnet
   2. sgbastion 
      – Applied to the bastion EC2 instance to allow incoming SSH connections from your list of remote IP addresses.
   3. sg_jenkins 
      – Applied to the Jenkins EC2 instances to allow administrative SSH access from the bastion and HTTP access from the load balancer servicing Jenkins requests
   4. sg_db 
      – Applied to the GitLab Postgresql database to allow the Gitlab hosts to access the database
   5. sg_redis 
      – Applied to the Redis cluster to allow Gitlab access to Redis
   6. sg_git 
      – Applied to the Gitlab EC2 instances to allow administrative SSH access from the bastion and HTTP access from the load balancer servicing Gitlab requests.

#### rds.tf
In this script we are creating our postgreSQL database. To configure our GitLab instance to connect to this external database, earlier, we reference output variables from this resource.

#### redis.tf
GitLab requires a Redis cache. We can either use the built-in Redis cache or an external cache. In order to meet our objective of building a highly-available infrastructure, we will need at least 2 GitLab servers and therefore will need an external, shared Redis cluster.

#### iam.tf
When we launch an EC2 instance in this environment, we want the ability to run AWS CLI commands (from an instance) when running our cloud_init scripts. This will allow us to pull information about other AWS resources and use them to customize our configuration. One example where this comes in handy is when we install GitLab.

#### kms.tf
This script will generate 2 KMS keys used to secure data in the Elastic File System (EFS) for the Jenkins and GitLab data.

#### efs.tf
As part of building a highly available architecture, we need to build a series of EFS filesystems, which are basically equivalent to CIFS or NFS filesystems. All of our filesystem data for both the GitLab servers and Jenkins Master servers will mount and utilize these EFS filesystems, making our EC2 instances immutable.

#### keypair.tf
This script will take a pre-built key from your workstation and install it on every EC2 instance deployed during this exercise.
Ensure you update your variables.tf file to point to a valid ssh public key that you have access to from your workstation. 

#### elb.tf
The elb.tf script is responsible for setting up our Application Load Balancers (ALB), the Target Groups and the Launch Configurations for our Jenkins Master and GitLab instances.  
The ALBs provide the front-end access point to our application, by providing a public IP address and DNS name.

#### jenkins-master.sh
The function of this script is to:

   1. Install common software and tools needed for server administration
   2. Install the AWS CLI
   3. Configure the fstab to mount an EFS volume at boot time and mount the EFS volume
   4. Install Java RTE and the Jenkins software
   5. Run some sed scripts to modify the home directory for the Jenkins user and Jenkins software to point at the external EFS mount point
   6. Move the Jenkins software to the EFS mount point
   7. Add the Jenkins user to the root OS group to allow future docker builds to succeed
   8. Configure Jenkins to start on boot and start Jenkins
   9. Install a JSON parser utility and Golang
   10. Install a credential helper script to simplify Jenkins script interaction with AWS ECR service
   11. Install Groovy for any Jenkins scripting needs (not used)
   12. Install Docker and Git for building docker containers from within Jenkins
   13. Setup an SSH key for integration with Gitlab
   14. Patch the Operating System
   15. Install Postfix to allow Jenkins to send emails

#### jenkins-slave.sh
Jenkins slaves are used to offload the Jenkins Master server to run Jenkins jobs. 
The installation an configuration of the slaves is very similar to the master with one exception: The slaves will not have an EFS volume attached as they do not need to save any configuration. 
A failed slave will simply be replaced by a new slave.

The function of this script is to:
   1. Install common software and tools needed for server administration
   2. Install the AWS CLI
   3. Install Java RTE and the Jenkins software
   4. Run some sed scripts to modify the home directory for the Jenkins user and Jenkins software to point at the external EFS mount point
   5. Move the Jenkins software to the EFS mount point
   6. Add the Jenkins user to the root OS group to allow future docker builds to succeed
   7. Configure Jenkins to start on boot and start Jenkins
   8. Install a JSON parser utility and Golang
   9. Install a credential helper script to simplify Jenkins script interaction with AWS ECR service
   10. Install Groovy for any Jenkins scripting needs (not used)
   11. Install Docker and Git for building docker containers from within Jenkins
   12. Setup an SSH key for integration with Gitlab
   13. Patch the Operating System
   14. Install Postfix to allow Jenkins to send emails

When complete you should have one Bastion host, one GitLab server, one Jenkins Master server, one or more Jenkins Slave servers (depending on your variables.tf settings), a PostgreSQL RDS instance, a Redis Cluster, multiple EFS filesystems, an Application Load Balancer with a public DNS Name, an EC2 launch configuration, two target groups, a KMS key, an EC2 Key Pair, Security Groups for EC2 and RDS, and all of the networking, subnets, and routing from Part 1.
