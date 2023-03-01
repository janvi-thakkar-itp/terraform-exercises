resource "aws_launch_configuration" "as_conf" {
    name_prefix = "WebServers-"
    image_id = var.instance_ami
    instance_type = var.instance_type
    key_name = aws_key_pair.lab.id
    user_data = var.web_user_data
    security_groups = [ aws_security_group.web_server.id ]
    depends_on = [
      aws_key_pair.lab
    ]
    root_block_device {
        volume_size = 8
        delete_on_termination = true
    }
     
    lifecycle {
        create_before_destroy = true
    }
}