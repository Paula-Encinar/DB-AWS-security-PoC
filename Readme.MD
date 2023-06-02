# How to keep a database secure on AWS
## Encrypt databases
 AWS from January 2023 has decided that all databases created from that date onwards will be encrypted, but databases created prior to this date, if not encrypted, will be encrypted manually.

 Let's assume that our database is not encrypted and the customer asks us to encrypt all databases, how do we do it? 

 * Take a snapshot of the current database. 

 *  Access the snapshot when it has been created and take a new action "copy snapshot". In this action there is a very important option, you can encrypt the snapshot, as you can see below: 
 
    ![image](/docs/encryptsnapshot.png)


## Deploy database on the private subnet

Resources to have in count 
* Network ACLs 
* Roles and policies 
* private subnets 
* ssm manager and not ssh (blocked)
* vpc endpoints for system manager 

![image](/docs/securityRDS.png)
