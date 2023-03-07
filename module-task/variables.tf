variable "vpc_cidr" {
  type    = string
  default = "192.168.64.0/20"
}

variable availability_zone{
  type=list(string)
  default= ["us-east-1a","us-east-1b","us-east-1c"]
}

variable pub_subnets{
    default=["192.168.64.0/24", "192.168.65.0/24", "192.168.66.0/24"]
} 

variable app_subnets{
    default=["192.168.67.0/24", "192.168.68.0/24", "192.168.69.0/24"]
} 

variable db_subnets{
    default=["192.168.70.0/24", "192.168.71.0/24", "192.168.72.0/24"]
} 

variable "practice_tag" {
  type    = string
  default = "janvi-practice-labs"
}

variable "lab_tag" {
  type    = string
  default = "vishal-assign-labs"
}

variable "aws_key_pair_pub"{
  type = string
}