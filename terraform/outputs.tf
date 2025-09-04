output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
  sensitive   = true
}

output "database_subnet_ids" {
  description = "List of IDs of database subnets"
  value       = module.vpc.database_subnets
  sensitive   = true
}

output "alb_arn" {
  value       = aws_lb.jenkins_alb.arn
  description = "The ARN of the existing ALB"
  sensitive   = true
}

# output "https_listener_arn" {
#   description = "The ARN of the existing HTTPS listener"
#   value       = module.alb.https_listener_arns[0]
#   sensitive   = true
# }

output "http_listener_arn" {
  description = "The ARN of the existing HTTP listener"
  value       = aws_lb_listener.jenkins_listener
  sensitive   = true
}

output "acm_certificate_arn" {
  value       = aws_acm_certificate.jenkins.arn
  description = "The ARN of the ACM certificate used for HTTPS listeners"
  sensitive   = true
}

output "ecs_cluster_arn" {
  value       = aws_ecs_cluster.jenkins.arn
  description = "The ARN of the ECS cluster"
  sensitive   = true
}

output "ecs_jenkins" {
  value       = aws_ecs_cluster.jenkins
  description = "The name of the ECS cluster"
  sensitive   = true
}

output "public_network_acl_id" {
  description = "ID of the public network ACL"
  value       = module.vpc.public_network_acl_id
}

output "private_network_acl_id" {
  description = "ID of the private network ACL"
  value       = module.vpc.private_network_acl_id
}

output "public_route_table_ids" {
  description = "IDs of the public route tables"
  value       = module.vpc.public_route_table_ids
}

output "private_route_table_ids" {
  description = "IDs of the private route tables"
  value       = module.vpc.private_route_table_ids
}
