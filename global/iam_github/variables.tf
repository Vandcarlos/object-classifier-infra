variable "allowed_repos" {
  description = "Repos filhos aprovados: role_name e prefixo do state"

  type = map(object({
    owner     = string
    name      = string
    role_name = string
    allow_main = bool
    workflows  = list(string) # ex: ["deploy.yml"]
  }))
  default = {}
}