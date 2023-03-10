variable "vpc_cidr" {
  type    = string
  default = "192.168.64.0/20"
}

variable "availability_zone" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "web_pub_subnets" {
  default = ["192.168.64.0/24", "192.168.65.0/24", "192.168.66.0/24"]
}

variable "app_pri_subnets" {
  default = ["192.168.67.0/24", "192.168.68.0/24", "192.168.69.0/24"]
}

variable "db_pri_subnets" {
  default = ["192.168.70.0/24", "192.168.71.0/24", "192.168.72.0/24"]
}

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

variable "aws_key_pair_pub" {
  type    = string
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC2ltX6YYo0xwhAfb+mc/KezcvIzFnrr2vnu878ixcSUeLTg8QoImVR8uu9G9GyScnfojumNWbQ7zqKO1O8IJM2YtQ9fyc4qwDaxIggzCWLtuSlazBgUWEpUFvB/1WEiFuzKvAx3aQ2f7xPufSDIqAhDaAFP7tstVzWOPddK/5GT1nXgM4NG8J4w2dpSMwhHde8Acv/jSWyENjVxVoiyRMHqG5FZq7G8vwVBd1JrTFL9IFWDuOy7LW/YHmqcpe/oKQS2Kjf50oosVWD8W1Kruk5TknTjB7fib5QpYjXeo9OciMTqVUy2a0K56Azc1a+oM0WDzpczhYA0J9pr+Qmf65r rsa-key-20230309"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ami_id" {
  type    = string
  default = "ami-006dcf34c09e50022"
}

# variable "db_endpoint"{
#   type=string

# }

variable "app_user_data" {
  default = <<EOT
      #!/bin/bash

# Update the package manager and install the LAMP stack
sudo yum update -y
sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2

# Install Apache and start the service
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd

# Add the current user to the Apache group and update the ownership of the /var/www directory
sudo usermod -a -G apache $USER
sudo chown -R $USER:apache /var/www
sudo chmod 2775 /var/www
sudo find /var/www -type d -exec chmod 2775 {} \;
sudo find /var/www -type f -exec chmod 0664 {} \;

# Install required PHP modules and restart Apache and PHP-FPM
sudo yum install -y php-mbstring php-xml
sudo systemctl restart httpd
sudo systemctl restart php-fpm

# Download and configure phpMyAdmin
cd /var/www/html
sudo wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz
sudo mkdir phpMyAdmin && sudo tar -xvzf phpMyAdmin-latest-all-languages.tar.gz -C phpMyAdmin --strip-components 1
sudo rm phpMyAdmin-latest-all-languages.tar.gz
sudo cp phpMyAdmin/config.sample.inc.php phpMyAdmin/config.inc.php
# Create a test PHP file to verify the installation
echo '<?php phpinfo(); ?>' > /var/www/html/phpinfo.php

 > index.html
    EOT
}