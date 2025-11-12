variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "state_bucket_name" {
  type    = string
  default = "tfstate-ml-sandbox"
}

variable "lock_table_name" {
  type    = string
  default = "tfstate-ml-locks"
}

# APPROVAL LIST: cada repo aprovado ganha um role e um prefixo
variable "allowed_repos" {
  description = "Repos filhos aprovados: role_name e prefixo do state"

  type = map(object({
    owner     = string
    name      = string
    role_name = string
    # (opcional) travas leves de origem
    allow_main = bool
    workflows  = list(string) # ex: ["deploy.yml"]
  }))
  default = {}
}
