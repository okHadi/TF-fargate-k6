provider "aws" {
  region = "ap-northeast-1"
}

data "aws_iam_policy" "ecs_task_execution_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy" "cloudwatch_logs_full_access_policy" {
  arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_policy_attachment" "ecs_task_execution_policy_attachment" {
  name       = "ecs_task_execution_policy_attachment"
  policy_arn = data.aws_iam_policy.ecs_task_execution_policy.arn
  roles      = ["ecsTaskExecutionRole"]
}

resource "aws_iam_policy_attachment" "cloudwatch_logs_full_access_policy_attachment" {
  name       = "cloudwatch_logs_full_access_policy_attachment"
  policy_arn = data.aws_iam_policy.cloudwatch_logs_full_access_policy.arn
  roles      = ["ecsTaskExecutionRole"]
}

resource "aws_ecs_task_definition" "k6TF" {
  family                   = "k6TF"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = "arn:aws:iam::049964873288:role/ecsTaskExecutionRole"
  container_definitions = jsonencode([
    {
      name  = "k6TFContainer"
      image = "049964873288.dkr.ecr.ap-northeast-1.amazonaws.com/k6:latest"
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-create-group  = "true",
          awslogs-group         = "/ecs/k6TF",
          awslogs-region        = "ap-northeast-1",
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

resource "aws_ecs_cluster" "k6TFCluster" {
  name = "k6TFCluster"

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
  }
}
