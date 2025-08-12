resource "aws_ecr_repository" "main" {
  name                 = "${var.service_name}-ecr-${var.repository_name}"
  image_tag_mutability = var.image_tag_mutability
  image_scanning_configuration {
    scan_on_push = var.enable_image_scanning
  }
}
