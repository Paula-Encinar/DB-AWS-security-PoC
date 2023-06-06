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

We will gradually describe each of these resources as we go along. As mentioned above, in this example we will have two private subnets. For the database to be deployed on the private subnet the first thing to do is in the resource *subnet group* which belongs to the database resource to add the two private subnets that will be assigned to the database. It is also important to link to the database a security group with its default port.

Once the database is on the private subnet, how do you access it now from local? This is the typical question that any developer would ask since they work with the database on a daily basis. 

The next resource to create in order to access the database is an EC2 instance that will work as a bastion server and will also be hosted on the private subnet for security reasons.

In this case the EC2 instance will work as a jump machine, but this will not be through SSH as is common. Why? Because the SSH and RDP ports have been blocked through the Network ACLs configured because these accesses cannot be controlled by AWS as such and also because it prevents the private keys from being on the developers' computers.

How can the database be accessed locally?

The scenario is as follows:

![image](/docs/securityRDS.png)

As you can see the other resources mentioned above come into the picture, AWS Session Manager, VPC endpoints to enable this port forwarding and IAM roles and policies to make the jump across the EC2 instance possible as well as access to the EC2 instance itself which is also accessed through the Session Manager.

What is AWS Session Manager? 

Session Manager is a fully managed AWS Systems Manager capability. Session Manager provides secure, auditable node management without the need to open ingress ports, maintain bastion hosts or manage SSH keys.

VPC Endpoints 

It’s recommended to use VPC Endpoints for session manager so that the network traffic between your managed instances, Systems Manager, and Amazon EC2 is restricted to the Amazon network.


![image](/docs/SessionManager.png)



