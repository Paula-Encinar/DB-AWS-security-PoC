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

It is recommended to have the databases deployed on a private subnet. Let's suppose that in AWS we create a VPC with two public subnets and two private subnets, then the deployment of the databases has to be deployed on the private subnets, for this there are several components involved.  

Resources to have in count 
* Private subnets
* BBDD subnets groups  
* Network ACLs 
* Roles and policies 
* ssm manager and not ssh (blocked)
* vpc endpoints for system manager 

![image](/docs/securityRDS.png)
