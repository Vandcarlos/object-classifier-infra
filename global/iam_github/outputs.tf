output "roles" {
  value = {
    for key, role in aws_iam_role.github_roles :
    key => {
      arn  = role.arn
      name = role.name
    }
  }
}
