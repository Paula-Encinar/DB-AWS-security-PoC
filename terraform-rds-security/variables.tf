variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "rds_instance_type" {
  default = "db.t3.micro"
  
}

 variable "rds_snapshop_id" {
    default = ""
 }

variable "environment" {
  default = "KS"
}