resource "aws_efs_file_system" "jenkins_efs" {
  creation_token = "jenkins-efs"
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  tags = {
    Name = "jenkins-efs"
  }
}

resource "aws_security_group" "jenkins_efs_sg" {
  name        = "efs-sg"
  description = "Allow NFS access"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["10.1.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_efs_mount_target" "efs_mount" {
  count           = length(module.vpc.private_subnets)
  file_system_id  = aws_efs_file_system.jenkins_efs.id
  subnet_id       = module.vpc.private_subnets[count.index]
  security_groups = [aws_security_group.jenkins_efs_sg.id]
}

resource "aws_efs_access_point" "jenkins_ap" {
  file_system_id = aws_efs_file_system.jenkins_efs.id

  posix_user {
    uid = 1000
    gid = 1000
  }

  root_directory {
    path = "/jenkins"
    creation_info {
      owner_uid   = 1000
      owner_gid   = 1000
      permissions = "755"
    }
  }
}