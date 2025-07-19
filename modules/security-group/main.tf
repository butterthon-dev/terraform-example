module "security-group" {
    source = "terraform-aws-modules/security-group/aws"
    version = "v5.3.0"

    name = var.name
    description = var.description
    vpc_id = var.vpc_id

    ingress_cidr_blocks = var.ingress_cidr_blocks
    ingress_rules = var.ingress_rules
    ingress_with_cidr_blocks = var.ingress_with_cidr_blocks
    egress_rules = var.egress_rules
    egress_with_cidr_blocks = var.egress_with_cidr_blocks
}
