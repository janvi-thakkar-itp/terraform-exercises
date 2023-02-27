resource "aws_key_pair" "lab" {
  key_name   = "janvi-keypair"
  public_key = var.aws_key_pair_pub
}