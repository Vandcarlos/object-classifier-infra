variable "artifacts_bucket_name" {
  type    = string
}

variable "producers" {
  type = map(object({
    role_name : string
    project_key : string
  }))
  default = {}
}

variable "consumers" {
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
