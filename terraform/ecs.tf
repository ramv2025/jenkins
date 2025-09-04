resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "efs_access" {
  name = "efs-access"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:ClientRootAccess"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_ecs_task_definition" "jenkins" {
  family                   = "jenkins-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
  {
    name      = "jenkins"
    image     = "jenkins/jenkins:lts"
    essential = true
    portMappings = [
      {
        containerPort = 8080
      }
    ]
    mountPoints = [
      {
        sourceVolume  = "jenkins-data"
        containerPath = "/var/jenkins_home"
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/jenkins"
        awslogs-create-group  = "true",
        awslogs-region        = "us-east-1"
        awslogs-stream-prefix = "ecs"
      }
    }
    healthCheck = {
      command     = ["CMD-SHELL", "curl -f http://localhost:8080 || exit 1"]
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 60
    }
  }
])

  volume {
    name = "jenkins-data"
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.jenkins_efs.id
      root_directory     = "/"
      transit_encryption = "ENABLED"
      
      authorization_config {
      access_point_id = aws_efs_access_point.jenkins_ap.id
      iam             = "ENABLED"
    }

    }
  }
}


resource "aws_security_group" "ecs_sg" {
  name        = "jenkins-ecs-sg"
  description = "Security group for Jenkins ECS tasks"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id] # Allow traffic from ALB
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow outbound internet access
  }

  tags = {
    Name = "jenkins-ecs-sg"
  }
}


resource "aws_ecs_cluster" "jenkins" {
  name = "jenkins-cluster"
}

resource "aws_ecs_service" "jenkins" {
  name            = "jenkins-service"
  cluster         = aws_ecs_cluster.jenkins.id
  task_definition = aws_ecs_task_definition.jenkins.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets         = module.vpc.private_subnets
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.jenkins_tg.arn
    container_name   = "jenkins"
    container_port   = 8080
  }

  depends_on = [aws_lb_listener.jenkins_listener]
}

