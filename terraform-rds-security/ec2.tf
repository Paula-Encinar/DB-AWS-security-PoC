resource "aws_iam_instance_profile" "dev-resources-iam-profile" {
  name = "ec2_profile_${var.environment}"
  role = aws_iam_role.dev-resources-iam-role.name
}

resource "aws_iam_role" "dev-resources-iam-role" {
  name        = "dev-ssm-role_${var.environment}"
  description = "The role for the developer resources EC2"
  assume_role_policy = <<EOF
  {
  "Version": "2012-10-17",
  "Statement": {
  "Effect": "Allow",
  "Principal": {"Service": "ec2.amazonaws.com"},
  "Action": "sts:AssumeRole"
  }
  }
  EOF
  tags = {
    Environment = var.environment
  }
}


data "aws_iam_policy" "ec2_ssm_policy"{
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_iam_role_policy_attachment" "dev-resources-ssm-policy" {
  role       = aws_iam_role.dev-resources-iam-role.name
  policy_arn = data.aws_iam_policy.ec2_ssm_policy.arn

}


data "aws_ami" "amazon-linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]  # Update with the desired Linux AMI name pattern
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "app_server" {
  ami           = data.aws_ami.amazon-linux.id
  instance_type = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.dev-resources-iam-profile.name

  vpc_security_group_ids = [
    aws_security_group.sg.id
  ]
  subnet_id = aws_subnet.private_subnet_1.id

  tags = {
    Environment = var.environment
    Name = "bastion_${var.environment}"
    
  }

  depends_on = [ aws_security_group.sg ]
  
}
