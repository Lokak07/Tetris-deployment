resource "aws_ebs_volume" "jenkins-storage" {
  availability_zone = "us-east-1a"
  size              = 40

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}