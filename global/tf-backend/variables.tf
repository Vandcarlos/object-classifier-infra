variable "state_bucket_name" {
  type    = string
  default = "tfstate-ml-sandbox"
}

variable "lock_table_name" {
  type    = string
  default = "tfstate-ml-locks"
}