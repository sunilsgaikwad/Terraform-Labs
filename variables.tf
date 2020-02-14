variable "loc" {
    default = "southeastasia"
}
variable "rg" {
    default = "sunil-rg"
}

variable "tags" {
    type = "map"
 default = {
        environment = "nps tf training "
        source      = "nps"
    }
}
