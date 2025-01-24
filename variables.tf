variable "region" {
  default     = "us-east-1"
  description = "Region AWS où déployer les ressources"
}

variable "ami" {
  default     = "ami-04b4f1a9cf54c11d0"
  description = "ID de l'AMI Ubuntu à utiliser"
}

variable "instance_type" {
  default     = "t3.medium"
  description = "Type d'instance pour le master et les workers"
}