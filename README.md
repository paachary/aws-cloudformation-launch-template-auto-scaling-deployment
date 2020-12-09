#       Example of automating deployment of AWS CloudFormation templates

         This repository has resources that automate creation of AWS Cloudformation Stacks for launch template and autoscaling group and deployment of those resources for running a Python based Flask web application.

          This example uses pynt, a lightweight python build tool, to execute tasks for creating and deleting AWS CloudFormation templates.
          
          The examples of AWS CloudFormation stacks include 
                    Individual Templates
                    Nested Stack

## Pre-requirements for using this repository

          1. Install python3 (latest version preferrable)

          2. Install and Configure AWS CLI on your local machine OR 
             Configure appropriate IAM role on the EC2 instance for executing the AWS CLI commands.

## Clone this repostory

git clone https://github.com/paachary/aws-cloudformation-launch-template-auto-scaling-deployment.git

## Execute the setup.sh script
          
          $ cd aws-cloudformation-launch-template-auto-scaling-deployment 
          $ sh setup.sh
          
    This script installs the python packages required for running the tasks successfully
       a. specifically the pynt package
       b. sets up the virtual environment for executing the tasks

## Tasks available

          Following tasks are available as a part of this repository:
          
          $ . myenv/bin/activate
          
          $ pynt -l
          <<output>>
                    create_nested_stack     [Default]  Creating cloudformation nested stack. The argument to this function is the parent stack name (s) 
                    create_stack                       Creating cloudformation stacks based on stack names 
                    delete_stack                       Delete stacks using CloudFormation.
          
## Description of this repository's CloudFormation Templates

### Nested Stack example

#### webapp-nested-resources
          $ pynt create_nested_stack["webapp-nested-resources"]
          
          This stack creates a fully functional web application running using python Flask with RDS using postgresdb as its datastore. 
          The webapplication can be accessed using the load-balancer DNS url.
          
          Creates network-resources, ssm-resources, rds-resources, aws-cloudformation-launch-template-webapp-resources, aws-cloudformation-elastic-load-balancer-resources and aws-cloudformation-autoscaling-group-webapp-resources stacks.

### Individual Stacks example

          The program has options to create the following stacks individually. Description of each of the stack is provided below:

#### network-resources
          $ pynt create_stack["network-resources"]
          
          Creates a custom VPC and its related resources [subnets, route tables, igw].
                
#### ssm-resources 
          $ pynt create_stack["ssm-resources"]
          
          Creates required ssm parameters for postgres-db-resources and webapp-resouces template to use.
          There is no dependency on any stack.
          
#### rds-resources
          $ pynt create_stack["rds-resources"]
          
          Creates a postgresSQL RDS instance.
          This stack is dependent on the network-resources stack and ssm-resources stack created above.
          
#### aws-cloudformation-launch-template-webapp-resources 
          $ pynt create_stack["aws-cloudformation-launch-template-webapp-resources"]
          
          Creates an EC2 Launch Template with the user-data to create and configure a python based Flask web application. This webapp uses the RDS postgresSQL db instance as its resources.
          This stack is dependent on the network-resources stack and ssm-resources stack created above.
          
#### aws-cloudformation-elastic-load-balancer-resources 
          $ pynt create_stack["aws-cloudformation-elastic-load-balancer-resources"]
          
          Creates an EC2 Application Elastic Load Balancer with a target group. This app elb will be used in the autoscaling group to launch the EC2 instancs hosting the python based Flask web application.
          This stack is dependent on the network-resources stack.
                    
#### aws-cloudformation-autoscaling-group-webapp-resources 
          $ pynt create_stack["aws-cloudformation-autoscaling-group-webapp-resources"]
          
          Creates an EC2 Autoscaling group with the desired number of EC2 instances as 2. The autoscaling group will launch the EC2 instancs hosting the python based Flask web application.
          This stack is dependent on the network-resources stack.
          The python Flask web application can be accessed using the load balancer's DNS URL.
                    
#### Note
          If you choose to create all the above individual stacks in the specified order, then you will have a fully functional web application running on python Flask with postgredb as its datastore.
          
          You can execute all the individual stacks using one command as shown below:
          
                    $ pynt create_stack["network-resources","ssm-resources","rds-resources", ...]

### Regarding the source code, "build.py"
          This is the python code which gets invoked when "pynt" is executed on the command line.
          
          A function with "task" decorator is executed when the specific function is invoked using the command listed above.
        
          You can include your own tasks with dependencies across tasks and create your own automation deployment pipeline.
