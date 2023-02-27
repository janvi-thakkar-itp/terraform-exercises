variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/24"
}

variable "practice_tag" {
  type    = string
  default = "janvi-practice-labs"
}

variable "web_user_data" {
  default = <<EOT
        #!/bin/bash
        yum update -y
        yum install httpd -y
        service httpd start
        chkconfig httpd on
        cd /var/www/html
        echo "<html><h1>This is WebServer" `curl http://169.254.169.254/latest/meta-data/local-ipv4` "</h1></html>" > index.html
    EOT
}

variable "instance_ami" {
  type    = string
  default = "ami-0dfcb1ef8550277af"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "aws_key_pair_pub" { type = string }


