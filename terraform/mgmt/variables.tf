variable "instance_count" {
  default = "3"
}

variable "instance_tags" {
  type    = list(string)
  default = ["Jenkins", "AnsibleController", "Monitoring"]
}

variable "ami" {
  type    = string
  default = "ami-0914547665e6a707c"
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}