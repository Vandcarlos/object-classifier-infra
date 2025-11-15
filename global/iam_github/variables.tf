variable "github_oidc_provider_arn" {
  type = string
}

variable "allowed_repos" {
  description = "Repos filhos aprovados: role_name e prefixo do state"

  type = map(object({
    owner     = string
    name      = string
    role_name = string
  }))
  default = {}
}
