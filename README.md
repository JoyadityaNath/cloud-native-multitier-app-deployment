# ECS EC2 Deployment on AWS

### Terraform • Packer • GitHub Actions • Docker

## Project Overview

This project demonstrates a **production-style container deployment architecture** using **Amazon ECS with the EC2 launch type**. The goal is to run containerized applications on EC2 instances while maintaining full control over the underlying infrastructure.

Infrastructure is provisioned using **Infrastructure as Code**, container images are stored in a private registry, and deployments are automated through a CI/CD pipeline.

The system focuses on:

* Container orchestration using ECS
* Infrastructure provisioning with Terraform
* Immutable AMI creation using Packer
* Automated deployments using GitHub Actions
* Load-balanced container traffic using an Application Load Balancer
* Centralized logging with CloudWatch

---

# High-Level Architecture

```
Developer Push
      │
      ▼
GitHub Actions CI Pipeline
(Build & Push Docker Image)
      │
      ▼
Amazon ECR
(Container Image Repository)
      │
      ▼
Update ECS Task Definition
      │
      ▼
ECS Service Deployment
      │
      ▼
Application Load Balancer
      │
      ▼
ECS Tasks (Running Containers)
      │
      ▼
EC2 Instances (Auto Scaling Group)
```

The system runs inside a **VPC spanning two availability zones** for high availability.

---

# Infrastructure Overview

The base infrastructure is provisioned using Terraform.

The following components are already created:

### Networking

* VPC
* Public subnets
* Private subnets
* Internet Gateway
* Route tables

### Load Balancing

* Application Load Balancer deployed in public subnets
* Target group configured for ECS containers
* Listener rules routing traffic to the service

### Compute

* Auto Scaling Group
* Launch Template
* EC2 instances running inside private subnets

### Container Infrastructure

* Amazon ECR repository for storing container images
* GitHub Actions CI pipeline that builds Docker images and pushes them to ECR

---

# Custom ECS AMI

EC2 instances in this project run on a **custom AMI built using Packer**.

The AMI is preconfigured with:

* Docker
* ECS Agent
* AWS SSM Agent
* Systemd configuration for ECS agent startup

Using a prebuilt AMI provides several advantages:

* Faster instance startup
* Consistent configuration
* Reduced bootstrap complexity
* Improved reliability

The ECS cluster configuration is provided through **Launch Template user data** when instances start.

---

# ECS Architecture

Understanding ECS components is essential to understanding how the system works.

## ECS Cluster

An ECS cluster represents a **logical pool of compute capacity** where containers run.

In this architecture:

```
ECS Cluster
   │
   ├── EC2 Instance
   ├── EC2 Instance
   └── EC2 Instance
```

EC2 instances register themselves with the cluster through the ECS agent.

---

## Task Definition

A **task definition** acts as a blueprint describing how containers should run.

It defines:

* Container image
* CPU and memory requirements
* Port mappings
* Logging configuration

Each update creates a **new revision**, enabling controlled deployments and easy rollbacks.

---

## ECS Task

A **task** is a running instance of a task definition.

Example:

```
Task Definition: version 5

Running Tasks:
- Task A
- Task B
```

Tasks run on EC2 instances inside the cluster.

---

## ECS Service

The **ECS service** manages long-running tasks.

Responsibilities include:

* Maintaining the desired number of running tasks
* Restarting failed containers
* Integrating with the load balancer
* Performing rolling deployments

The service ensures the application remains available even if containers fail.

---

# Load Balancing

The system uses an **Application Load Balancer** to distribute traffic across containers.

Traffic flow:

```
Client Request
     │
     ▼
Application Load Balancer
     │
     ▼
Target Group
     │
     ▼
ECS Task (Container)
```

The load balancer provides:

* High availability
* Health checks
* Traffic distribution
* Zero-downtime deployments

---

# Dynamic Port Mapping

Containers run with **dynamic host ports**.

This allows multiple containers to run on a single EC2 instance without port conflicts.

Example runtime mapping:

```
EC2 Instance
   ├── Host Port 32768 → Container Port 5000
   ├── Host Port 32769 → Container Port 5000
   └── Host Port 32770 → Container Port 5000
```

The load balancer automatically registers the correct host ports when tasks start.

---

# Logging Architecture

Container logs are sent to **Amazon CloudWatch Logs**.

Log flow:

```
Application Logs
       │
       ▼
Container stdout/stderr
       │
       ▼
ECS Agent
       │
       ▼
CloudWatch Logs
```

This provides centralized log storage and monitoring.

---

# CI/CD Pipeline

Deployments are automated using **GitHub Actions**.

The pipeline performs the following steps:

```
1. Developer pushes code
2. GitHub Actions builds Docker image
3. Image tagged using commit SHA
4. Image pushed to Amazon ECR
5. Task definition updated with new image
6. ECS service deploys new containers
```

Each deployment creates a **new task definition revision**, enabling traceable deployments and easy rollback.

---

# Deployment Workflow

When a new image is deployed, ECS performs a rolling update.

Example:

```
Current Tasks
A
B

New Deployment Starts

Start Tasks
C
D

Health checks pass

Stop Tasks
A
B
```

This ensures **zero downtime deployments**.

---

# Health Checks

The Application Load Balancer performs health checks on the running containers.

Health checks determine whether a container should receive traffic.

If a container becomes unhealthy:

```
ALB stops routing traffic
ECS replaces the container
```

This maintains service availability.

---

# Repository Structure

```
terraform/
  Infrastructure provisioning

modules/
  Reusable Terraform modules

packer/
  AMI build configuration

app-code/
  Application source code

.github/workflows/
  CI/CD pipeline definitions
```

Each directory represents a different layer of the deployment system.

---

# End-to-End Deployment Flow

```
Developer pushes code
        │
        ▼
CI pipeline builds container image
        │
        ▼
Image pushed to ECR
        │
        ▼
Task definition updated
        │
        ▼
ECS service deploys new tasks
        │
        ▼
ALB routes traffic to containers
```

This pipeline provides automated, repeatable deployments.

---

# Design Principles

The architecture follows several best practices:

* Infrastructure as Code
* Immutable infrastructure
* Automated CI/CD deployments
* High availability across availability zones
* Container orchestration using ECS
* Centralized logging and monitoring

---

# Future Improvements

Potential enhancements include:

* ECS service auto scaling
* Capacity providers
* Blue/green deployments
* Observability improvements
* Advanced monitoring and alerting
* Infrastructure cost optimization

---

# Summary

This project demonstrates a complete container deployment platform built with modern DevOps practices.

Key features include:

* Container orchestration using Amazon ECS
* Infrastructure provisioning with Terraform
* Immutable AMI creation using Packer
* CI/CD deployments using GitHub Actions
* Load-balanced container traffic using an ALB
* Centralized logging through CloudWatch

The architecture provides a scalable and production-ready foundation for running containerized workloads on AWS.
