module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "jenkins"

  instance_type               = "t2.large"
  ami                         = data.aws_ami.ubuntu.image_id
  key_name                    = "my-keypair"
  monitoring                  = true
  vpc_security_group_ids      = [module.web_server_sg.security_group_id]
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update
              sudo apt install -y fontconfig openjdk-17-jre
              if ! java -version; then
                  echo "Java not installed properly"
                  exit 1
              fi
              sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
              echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
              sudo apt-get update
              sudo apt-get install -y jenkins
              EOF

}


resource "aws_volume_attachment" "micro-attachment" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.jenkins-storage.id
  instance_id = module.ec2_instance.id
}

