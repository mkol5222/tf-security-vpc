output "cme_iam_role_arn" {
  value = aws_iam_role.cme_iam_role.arn
}
output "cme_iam_role_name" {
  value = aws_iam_role.cme_iam_role.name
}
output "cme_iam_profile_arn" {
  value = aws_iam_instance_profile.iam_instance_profile.arn
}
output "cme_iam_profile_name" {
  value = aws_iam_instance_profile.iam_instance_profile.name
}


output "cme_read_policy_arn" {
  value = aws_iam_policy.cme_role_read_policy[0].arn
}