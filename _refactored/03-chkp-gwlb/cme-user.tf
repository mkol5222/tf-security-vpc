module "cme_iam_role" {
  source = "../../modules/cme-iam-role"
/*   providers = {
    aws = aws
  } */
  
  sts_roles = [] //var.sts_roles
  permissions = "Create with read permissions" // var.iam_permissions
}

output "cme_role_name" {
  value = module.cme_iam_role.cme_iam_role_name
}

resource "random_id" "unique_user_id" {
  keepers = {
    prefix = "cme-user-"
  }
  byte_length = 8
}

resource "aws_iam_user" "cme-user" {
  name = "cme-user-${random_id.unique_user_id.hex}"
}

resource "aws_iam_access_key" "cme-user-key" {
  user = aws_iam_user.cme-user.name
}

resource "aws_iam_policy_attachment" "cme-policy-attach" {
  name       = "cme-policy-attach"
  users      = [aws_iam_user.cme-user.name]
  policy_arn = module.cme_iam_role.cme_read_policy_arn
} 

output "cme-user-key-secret" {
  value = aws_iam_access_key.cme-user-key.secret
  sensitive = true
}

output "cme-user-key-id" {
  value = aws_iam_access_key.cme-user-key.id
  sensitive = false
}