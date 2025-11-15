variable "artifacts_bucket_name" {
  type        = string
  description = "Nome do bucket de artifacts (já em formato global único)"
}

variable "producers" {
  description = "Roles que escrevem artifacts no bucket, por prefixo"
  type = map(object({
    arn    = string
    prefix = string
  }))
  default = {}
}

variable "consumers" {
  description = "Roles que só leem artifacts no bucket, por prefixo"
  type = map(object({
    arn    = string
    prefix = string
  }))
  default = {}
}

variable "converter_role_arn" {
  type        = string
  default     = null
  description = "ARN de uma role 'conversora' (Lambda/ECS/etc) que pode ler e escrever tudo no bucket. Se null, não cria permissão."
}
