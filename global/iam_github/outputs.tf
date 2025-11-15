output "roles" {
  value = {
    for key, role in aws_iam_role.github_roles :
    key => {
      name      = var.allowed_repos[key].name
      role_name = role.name
    }
  }
}
