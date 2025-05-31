# Create an IAM role with EC2 instance describe permissions
resource "aws_iam_role" "ec2_test_role" {
  name = "ec2_metadata_test_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Create a policy that allows describing EC2 instances
resource "aws_iam_policy" "ec2_describe_policy" {
  name        = "ec2_describe_policy"
  description = "Policy that allows describing EC2 instances"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "ec2:DescribeInstances",
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "ec2_describe_attachment" {
  role       = aws_iam_role.ec2_test_role.name
  policy_arn = aws_iam_policy.ec2_describe_policy.arn
}

# Create an IAM instance profile for the role
resource "aws_iam_instance_profile" "test_profile" {
  name = "metadata_test_profile"
  role = aws_iam_role.ec2_test_role.name
}