#Cidr for VPC
variable "vpc_cidr" {
  type    = string
  default = "192.168.64.0/20"
}

#Availability Zones
variable "availability_zone" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

#Public Subnets for Web Tier
variable "web_pub_subnets" {
  default = ["192.168.64.0/24", "192.168.65.0/24", "192.168.66.0/24"]
}

#Private Subnets for App Tier
variable "app_pri_subnets" {
  default = ["192.168.67.0/24", "192.168.68.0/24", "192.168.69.0/24"]
}

#Public Subnets for DB Tier
variable "db_pri_subnets" {
  default = ["192.168.70.0/24", "192.168.71.0/24", "192.168.72.0/24"]
}

#Tags
variable "practice_tag" {
  type    = string
  default = "janvi-practice-labs"
}

variable "lab_tag" {
  type    = string
  default = "vishal-assign-labs"
}

variable "owner" {
  type    = string
  default = "janvi.thakkar@intuitive.cloud"
}

#EC2 Instance Type
variable "instance_type" {
  type    = string
  default = "t2.micro"
}

#EC2 AMI ID
variable "ami_id" {
  type    = string
  default = "ami-006dcf34c09e50022"
}