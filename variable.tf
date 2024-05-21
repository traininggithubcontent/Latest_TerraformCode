variable "aws_region"{    
}

variable "vpc_cidr" {
    default = "10.0.0.0/16"
}
variable "subnets_cidr" {
    type = list
    default = [ "10.0.1.0/24", "10.0.2.0/24"]
}
variable "azs" {
    type = string
    default = "ap-south-1a"
}
variable "tags" {
  description = "Additional tags (e.g., `map('BusinessUnit','XYZ')`)"
  type        = map(string)
  default     = {}
}