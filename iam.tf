# # Rôle IAM pour les workers
# resource "aws_iam_role" "worker_role" {
#   name = "k8s-worker-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [{
#       Effect    = "Allow",
#       Principal = { Service = "ec2.amazonaws.com" },
#       Action    = "sts:AssumeRole"
#     }]
#   })
# }

# # Policy IAM pour les workers
# resource "aws_iam_role_policy" "worker_policy" {
#   name = "k8s-worker-policy"
#   role = aws_iam_role.worker_role.name
#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [{
#       Effect   = "Allow",
#       Action   = "ec2:DescribeInstances",
#       Resource = "*"
#     }]
#   })
# }

# resource "aws_iam_policy" "ssm_read_policy" {
#   name = "SSMReadK8sKeyPolicy"
#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Action = [
#           "ssm:GetParameter",
#           "ssm:GetParameters"
#         ],
#         Resource = "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/k8s/id_rsa_k8s"
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "attach_ssm_read_policy" {
#   role       = aws_iam_role.worker_role.name
#   policy_arn = aws_iam_policy.ssm_read_policy.arn
# }

# # Instance Profile IAM pour les workers
# resource "aws_iam_instance_profile" "worker_profile" {
#   name = "k8s-worker-profile"
#   role = aws_iam_role.worker_role.name
# }

