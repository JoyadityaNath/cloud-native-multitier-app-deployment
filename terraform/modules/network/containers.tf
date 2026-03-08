data "aws_iam_role" "exec_role" {
  name="ECS-policy-for-ECR-joynath"
}


resource "aws_ecs_cluster" "cluster" {
  name="cloud-multitier-application-cluster"
  region = "ap-south-1"
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name = "/ecs/my-application"
}

resource "aws_ecs_task_definition" "task_def" {
  family="cloud-multitier-application"
  requires_compatibilities = [ "EC2" ]
  network_mode = "bridge"
  cpu = 256
  memory = 512
  execution_role_arn = data.aws_iam_role.exec_role.arn
  container_definitions =file("${path.module}/taskdefinition.json")
}


resource "aws_ecs_service" "app_service" {

  name            = "cloud-multitier-application-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task_def.arn

  desired_count = 2
  launch_type   = "EC2"

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  ordered_placement_strategy {
    type  = "spread"
    field = "instanceId"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.instance_tg.arn
    container_name   = "cloud-multitier-application"
    container_port   = 80
  }

}