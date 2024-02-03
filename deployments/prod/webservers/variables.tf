# Instance type
variable "instance_type" {
  default = {
    "prod"    = "t3.medium"
    "test"    = "t3.micro"
    "staging" = "t2.micro"
    "dev"     = "t2.micro"
  }
  description = "Type of the instance"
  type        = map(string)
}

# Variable to signal the current environment 
variable "env" {
  default     = "prod"
  type        = string
  description = "Deployment Environment"
}

variable "service_ports" {
  type        = list(string)
  default     = ["22"]
  description = "Ports that should be open on a webserver"
}


