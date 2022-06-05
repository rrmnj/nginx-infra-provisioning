# Dependencies / Assumptions
1) Terraform 
2) AWS CLI configured with profile containing secret/access keys 
3) AWS Account atleast in Free Tier to host the nginx server.
4) Assumes you have a valid SSL certificate uploaded into ACM (this is a mandatory paramater for the nginx server - for the purposes of this POC, I uploaded a self-signed cert)
5) Assumes you have a keypair to ssh into the EC2 nodes (though ssh/22 is not open by default)
6) Assumes minimum 2 subnets (to load balance across to azs for HA)

# Architectural Considerations 
1) Under normal circumstances, of course, this application would be deployed via ECS which handles the load balancing, autoscaling, and provisioning of the Docker image out of the box. However this would have taken me out of Free Tier - for the purposes of this POC, this entire environment fits under the free tier constraints. 

*Why ECS and not EKS? For this brief specifically, the application is is a standalone, stateless, front end application only. EKS would be an overengineereed solution for something that doesn't communicate with other microservices that would utilise sidecars, service mesh, replicas etc.*

# Module Information 
This repo contains 2 separate modules that can be run indepentenly, 'infrastructure' & 'nginx-server'. This means if you already have your own VPC setup in AWS, you can run the nginx-server in there - you just need to pass in the VPC and Subnet IDs.

That being said, If you have an empty AWS account - you can use the 'infrastructure' module to build all the necessary, minimum components for the nginx-server to work. The outputs of the infrastructure module can be passed through directly to the mandatory parameters in the nginx-server module which will create the resources chronologically. 

###### The Infrastructure module creates the following components in AWS:
 1) VPC
 2) Subnets in separate AZs
 3) NACL (with rules only allowing outbound 80/443)
 4) Route Tables associated to the subnets to enable traffic flow
 5) Internet access via an IGW.

###### The Nginx-server module creates the following components: 
1) A Launch template for the EC2 which defines the instance type, image and contains a userdata script which automatically installs the nginx-hello image upon creation (bootstrap.sh).
2) Autoscaling Group for the launch template where you can define scaling parameters (min/max/desired) nodes through parameters passed into the module.
3) ALB & Target Group to load balance between the difference nodes in the ASG.
4) 2 Security Groups:
    - The ALB security group allows 80/443 from your IP address only (locked down for security purposes on this POC - in prod, you would open this up further to the internet)
    - The EC2 security group which only allows 80 ingress traffic from the ALB. You cannot hit the EC2 Public IP address directly, must be proxied through the ALB. 
5) ALB Listeners: 
    - HTTPS/443 Listener - primary listener which will then proxy the traffic to the nodes under the target group which will display the nginx page. Because this traffic is encrypted under HTTPS, a valid SSL certificate must be uploaded into ACM and passed through as a parameter to the module.
    - HTTP/80 Listener - This listener simply redirects the user to 443 to ensure all traffic is encrypted when communicating to the nodes.

# Instructions 
###### To run the nginx-server module indepenently:
1) in the main.tf file, ensure only the following module is present: 
```
module "nginx-microservice" {
  source = "./modules/nginx-server"
  /* -- Mandatory Parameters -- */
  vpc            = "vpc-xxxxxx"
  subnet1        = "subnet-xxxxxx"
  subnet2        = "subnet-xxxxxx"
  keypair        = var.keypair
  certificateARN = var.certificateARN

  /* -- Optional Parameters -- */
  maxSize         = "2"
  minSize         = "1"
  desiredCapacity = "2"
  ami             = var.ami          # default Amazon Linux 2
  instanceType    = var.instanceType # default t2.micro to stay in free tier
```

2) cd into root directory (nginx-terraform/)
3) run `terraform init` to pull packages
4) run `terraform apply` to build the server (after supplying all the mandatory paramaters either directly through the module or in the terraform.tfvars file) 
5) Once all the components are up, retrieve the DNS address of the ALB that was built and put it in your browser:  (looks something like: https://nginx-alb-xxxxxx.xxxxxx.elb.amazonaws.com/)

###### To run the nginx-server module WITH the infrastructure module: 
1) in the main.tf file, ensure the following modules are present: 
```
module "infrastructure" {
  source = "./modules/infrastructure"
  /* -- Mandatory Parameters -- */
  vpcCIDR = var.vpcCIDR # define a CIDR range for the VPC 
  subnet1 = var.subnet1 # define a cidr / az for subnet 1
  subnet2 = var.subnet2 # define a cidr / az for subnet 2

  /* -- Optional Parameters -- */
  # allocatePublicIP = #  bool - allocate a public IP to each EC2 created? Default is true. 
}

module "nginx-microservice" {
  source = "./modules/nginx-server"
  /* -- Mandatory Parameters -- */
  vpc            = module.infrastructure.vpc-id
  subnet1        = module.infrastructure.subnet1-id
  subnet2        = module.infrastructure.subnet2-id
  keypair        = var.keypair
  certificateARN = var.certificateARN

  /* -- Optional Parameters -- */
  maxSize         = "2"
  minSize         = "1"
  desiredCapacity = "2"
  ami             = var.ami          # default Amazon Linux 2
  instanceType    = var.instanceType # default t2.micro to stay in free tier
}
```
2) Define CIDR block variables for the infrastructure modules, e.g. vpc range 10.0.0.0/16, subnets being divided within that.
3) *Note that the vpc and subnet variables are passed through via the outputs of the infrastructure module.*
4) run `terraform init` to pull packages
5) run `terraform apply` to build the infrastructure and server (after supplying all the mandatory paramaters either directly through the module or in the terraform.tfvars file) - terraform will automatically build the pieces in order.
6) Once all the components are up, retrieve the DNS address of the ALB that was built and put it in your browser:  (looks something like: https://nginx-alb-xxxxxx.xxxxxx.elb.amazonaws.com/)


# PARAMETERS used to test with -- 
*Note, most of these parameteters I defined the terraform.tfvars file*
```
var.keypair
  Value: my-keypair

var.profile
  Value: default

var.region
  Value: eu-west-1

var.vpcCIDR
  Value: 10.0.0.0/16

var.subnet1
    Value: subnet1 = {
    cidr = "10.0.1.0/24"
    az   = "eu-west-1a"}
var.subnet2
    Value: subnet2 = {
    cidr = "10.0.2.0/24"
    az   = "eu-west-1b"}
}
certificateARN: arn:aws:acm:eu-west-1:**REDACTED***
```