# How to keep a database secure on AWS
## Encrypt databases
 AWS from January 2023 has decided that all databases created from that date onwards will be encrypted, but databases created prior to this date, if not encrypted, will be encrypted manually.

 Let's assume that our database is not encrypted and the customer asks us to encrypt all databases, how do we do it? 

 * Take a snapshot of the current database. 

 *  Access the snapshot when it has been created and take a new action "copy snapshot". In this action there is a very important option, you can encrypt the snapshot, as you can see below: 
 
    ![image](/docs/encryptsnapshot.png)

* Once this snapshot has been encrypted, the next action is to restore the snapshot, which allows you to create an encrypted database from the snapshot of your current database. You will now be able to see in the new database configuration that it is encrypted.

    ![image](/docs/databaseencrypted.png) 

## Deploy database on the private subnet

It is recommended to have the databases deployed on a private subnet. Let's suppose that in AWS we create a VPC with two public subnets and two private subnets, then the deployment of the databases has to be deployed on the private subnets, for this there are several resources involved.  

Resources to have in count 
* Private subnets
* BBDD subnets groups
* EC2 instance   
* Network ACLs 
* Roles and policies 
* ssm manager and not ssh (blocked)
* vpc endpoints for system manager 

We will gradually describe each of these resources as we go along. As mentioned above, in this example we will have two private subnets. For the database to be deployed on the private subnet the first thing to do is in the resource **subnet group** which belongs to the database resource to add the two private subnets that will be assigned to the database. It is also important to link to the database a security group with its default port.

Once the database is on the private subnet, how do you access it now from local? This is the typical question that any developer would ask since they work with the database on a daily basis. 

The next resource to create in order to access the database is an EC2 instance that will work as a bastion server and will also be hosted on the private subnet for security reasons.

In this case the EC2 instance will work as a jump machine, but this will not be through SSH as is common. Why? Because the SSH and RDP ports have been blocked through the Network ACLs configured because these accesses cannot be controlled by AWS as such and also because it prevents the private keys from being on the developers' computers.

How can the database be accessed locally?

The scenario is as follows:

![image](/docs/securityRDS.png)

As you can see the other resources mentioned above come into the picture, AWS Session Manager, VPC endpoints to enable this port forwarding and IAM roles and policies to make the jump across the EC2 instance possible as well as access to the EC2 instance itself which is also accessed through the Session Manager.

**What is AWS Session Manager?** 

Session Manager is a fully managed AWS Systems Manager capability. Session Manager provides secure, auditable node management without the need to open ingress ports, maintain bastion hosts or manage SSH keys.

**VPC Endpoints** 

It’s recommended to use VPC Endpoints for session manager so that the network traffic between your managed instances, Systems Manager, and Amazon EC2 is restricted to the Amazon network.

The following VPC endpoints have been configured:

* com.amazonaws.eu-west-2.ssm: The endpoint for the Systems Manager service.
* com.amazonaws.eu-west-2.ssmmessages: This endpoint is required only if you’re connecting to your instances through a secure data channel using Session Manager.
* com.amazonaws.eu-west-2.ec2: The endpoint for the EC2 service
* com.amazonaws.eu-west-2.ec2messages: Systems Manager uses this endpoint to make calls from SSM Agent to the Systems Manager service.

With these endpoints it is possible to access any EC2 instance through Session Manager without using SSH as well as a secure connection to a database through a bastion server.


**IAM Roles and Policies**
For the EC2 instance to have permissions to use Systems Manager it is necessary to attach a role with a policy called *AmazonSSMManagedInstanceCore* to enable this use. 


## Session Manager Plugin (AWS CLI)

In order to access the database once it is deployed on the private subnet from our local computer, we need to have AWS CLI installed and then install the Session Manager plugin. The steps are as follows:

1. Install AWS CLI: depending on your OS follow this [guide](https://docs.aws.amazon.com/es_es/cli/latest/userguide/getting-started-install.html#getting-started-install-instructions)

2. Install Session Manager Pluging: depending on your OS follow this [guide](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html#install-plugin-macos)


## Access EC2 instances with AWS CLI and SSM

As the SSH port is blocked the way to access the EC2 working as Bastion Server is through Session Manager by starting a session as follows: 

```
aws ssm start-session --target <EC2 instance ID> --region <region name>
```

As you can see there are two fields to complete:

* **EC2 instance ID**: ID of the EC2 instance you want to access

* **Region name**: name of the region where the instance you want to access is located

Finally, to access through SSM not just any configuration in the EC2, you must have an associated role which gives permissions to make use of this service.

## SSM Port Forwarding Session To Remote Host

To create a tunnel to access the DDBBs you have to know the iD of the EC2 instance that will be in charge of working as a bastion to give access to the DDBB, each environment has an instance. 

To access from your PC you have to open your terminal and run a command that provides a Port Forwarding through the AWS System Manager, the command is as follows:  

```
aws ssm start-session --target <EC2 instance ID> --region <region name> --document-name AWS-StartPortForwardingSessionToRemoteHost --parameters '{"host":["<database endpoint >"],"portNumber":["<database port>"], "localPortNumber":["<local port>"]}'
```

As you can see there are several values to complete: 

* **EC2 instance ID**: EC2 instance ID (bastion server)

* **Region name**: name of the region where the DDBBs and EC2 instance are deployed

* **Document-name**: this value in this case is fixed which is a system manager document which allows to perform this Port Forwarding

* **parameters**: here you can see that there are several values between {} which we discuss below: 

    * **host**: database endpoint 

    * **portNumber**: port of your database, in case of postgres the port is 5432

    * **localPortNumber**:  the port on your computer through which you will access the database

When you run this command you should see that a session has been started on the port you have chosen and is waiting for connections, as in the following image:  

![image](/docs/SSMPortForwarding.png)

## Access the DDBB through a SQL client

Now open your SQL client on your computer and you can access your DDBB in this case postgres type using as host "localhost" and as port the port you have set as "localPortNumber", enter the database username and password and you will be inside, here you can see an example: 

![image](/docs/SQLClient.png)




![image](/docs/SessionManager.png)