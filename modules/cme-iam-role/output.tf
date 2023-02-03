output "cme_iam_role_arn" {
  value = aws_iam_role.cme_iam_role.arn
}
output "cme_iam_role_name" {
  value = aws_iam_role.cme_iam_role.name
}

output "cme_read_policy_arn" {
  value = aws_iam_policy.cme_role_read_policy[0].arn
}

/* output "cme_write_policy_arn" {
  value = aws_iam_policy.cme_role_write_policy[0].arn
} */