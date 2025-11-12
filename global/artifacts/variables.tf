variable "producers" {
  # cada repo de modelo aprovado (PR altera aqui)
  type = map(object({
    role_name : string   # IAM role do repo
    project_key : string # ex: "object-classifier"
  }))
  default = {}
}

variable "consumers" {
  # repos que precisam ler modelos convertidos (endpoint, apis, apps builders, etc.)
  type = map(object({
    role_name : string
    project_key : string
  }))
  default = {}
}

variable "converter_role_arn" {
  type        = string
  default     = null
  description = "ARN do role do conversor (Lambda/ECS/StepFunctions). Se null, não cria a permissão."
}
