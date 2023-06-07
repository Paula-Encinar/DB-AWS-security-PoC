# How to keep a database secure on AWS
This README provides instructions on how to keep a database secure on AWS. It covers topics such as encrypting databases and deploying them on private subnets using AWS services like Session Manager and VPC endpoints. The document also includes steps for accessing the database using AWS CLI and SSM, as well as accessing the database through a SQL client.

## Table of Contents
1. Encrypt Databases
2. Deploy Database on Private Subnet
3. Session Manager Plugin (AWS CLI)
4. Access EC2 Instances with AWS CLI and SSM
5. SSM Port Forwarding Session to Remote Host
6. Access the Database Through a SQL Client

### Encrypt databases
AWS requires all databases created after January 2023 to be encrypted. However, databases created prior to this date need to be manually encrypted. Follow these steps to encrypt an existing database:

1. Take a snapshot of the current database.
2. Access the created snapshot and choose the "Copy snapshot" action.
3. In the copy snapshot action, select the option to encrypt the snapshot.

     ![image](/docs/encryptsnapshot.png)
4. Once the snapshot is encrypted, restore it to create an encrypted database.
5. Verify the new database configuration to confirm encryption.

    ![image](/docs/databaseencrypted.png) 

### Deploy database on the private subnet

To ensure better security, it is recommended to deploy databases on private subnets. Follow these steps to deploy a database on a private subnet:

1. Set up private subnets within your AWS Virtual Private Cloud (VPC).
2. Configure a subnet group for the database resource and add the private subnets.
3. Associate a security group with the database and configure the necessary port access.
4. Configure Network ACLs to block incoming ports for SSH (so you avoid also managing ssh keys) and RDP.  
5. Create an EC2 instance as a bastion server and host it on the private subnet.
6. Use AWS Session Manager, VPC endpoints, IAM roles, and policies to enable access to the EC2 instance and establish secure connections to the database.

How can the database be accessed locally?

The scenario is as follows:

![image](/docs/securityRDS.png)

As you can see the other resources mentioned above come into the picture, AWS Session Manager, VPC endpoints to enable this port forwarding and IAM roles and policies to make the jump across the EC2 instance possible as well as access to the EC2 instance itself which is also accessed through the Session Manager.

**What is AWS Session Manager?** 

Session Manager is a fully managed AWS Systems Manager capability. Session Manager provides secure, auditable node management without the need to open ingress ports, maintain bastion hosts or manage SSH keys.

**VPC Endpoints** 

It’s recommended to use VPC Endpoints for session manager so that the network traffic between your managed instances, Systems Manager, and Amazon EC2 is restricted to the Amazon network.

The following VPC endpoints have been configured:

1. com.amazonaws.eu-west-2.ssm: The endpoint for the Systems Manager service.
2. com.amazonaws.eu-west-2.ssmmessages: This endpoint is required only if you’re connecting to your instances through a secure data channel using Session Manager.
3. com.amazonaws.eu-west-2.ec2: The endpoint for the EC2 service
4. com.amazonaws.eu-west-2.ec2messages: Systems Manager uses this endpoint to make calls from SSM Agent to the Systems Manager service.

With these endpoints it is possible to access any EC2 instance through Session Manager without using SSH as well as a secure connection to a database through a bastion server.


**IAM Roles and Policies**
For the EC2 instance to have permissions to use Systems Manager it is necessary to attach a role with a policy called *AmazonSSMManagedInstanceCore* to enable this use. 


### Session Manager Plugin (AWS CLI)

To access the database deployed on the private subnet from your local computer, you need to have AWS CLI installed and the Session Manager plugin. Follow these steps to install AWS CLI and the Session Manager plugin:

1. Install AWS CLI: depending on your OS follow this [guide](https://docs.aws.amazon.com/es_es/cli/latest/userguide/getting-started-install.html#getting-started-install-instructions)

2. Install Session Manager Pluging: depending on your OS follow this [guide](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html#install-plugin-macos)


### Access EC2 instances with AWS CLI and SSM

As SSH and RDP ports are blocked for security reasons, you can access the EC2 instances through AWS Session Manager. To start a session on an EC2 instance, use the following command:

```
aws ssm start-session --target <EC2 instance ID> --region <region name>
```

Make sure to replace <EC2 instance ID> with the actual ID of the EC2 instance you want to access and <region name> with the name of the region where the instance is located. You also need to have the required IAM roles and policies attached to the EC2 instance for using Session Manager.

### SSM Port Forwarding Session To Remote Host

To create a tunnel and access the databases, you need to run a command through AWS Systems Manager that provides port forwarding. Use the following command:  

```
aws ssm start-session --target <EC2 instance ID> --region <region name> --document-name AWS-StartPortForwardingSessionToRemoteHost --parameters '{"host":["<database endpoint >"],"portNumber":["<database port>"], "localPortNumber":["<local port>"]}'
```

Replace the placeholders with the appropriate values:

* **EC2 instance ID**: ID of the EC2 instance serving as the bastion server.
* **region name**: Name of the region where the databases and EC2 instance are deployed.
* **database endpoint**: Endpoint of the database you want to access.
* **database port**: Port number of the database (e.g., 5432 for PostgreSQL).
* **local port**: Port number on your local computer for accessing the database.

This command establishes a port forwarding session using AWS Session Manager.

![image](/docs/SSMPortForwarding.png)

### Access the DDBB through a SQL client

After setting up the port forwarding session, you can use a SQL client on your local computer to access the database. Configure the SQL client with the following details:

* Host: localhost
* Port: The local port number you specified during the port forwarding session setup.
* Username: Database username
* Password: Database password

![image](/docs/SQLClient.png)

If you access the terminal where you have this session open you will see a message like this: 

```
Connection accepted for session [paula-encinar-X].
```

And if you look at your SQL client you will see that it has accessed your database without any problem. 

![image](/docs/DatabaseSQLClient.png)

It's worth noting that all access to EC2 instances and databases through Session Manager is logged and can be monitored via AWS Systems Manager's Session Manager section.

![image](/docs/SessionManager.png)

By following these instructions, you can ensure secure access to your databases on AWS while maintaining the necessary security measures and compliance requirements.