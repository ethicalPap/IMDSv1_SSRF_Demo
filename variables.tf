variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance (Amazon Linux 2 Free tier eligible)"
  type        = string
  default     = "ami-084568db4383264d4"  # Amazon Linux 2 AMI in us-east-1 (update as needed)
}
