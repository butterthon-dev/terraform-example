## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ssm_parameter.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_description"></a> [description](#input\_description) | SSMパラメータの説明 | `string` | `""` | no |
| <a name="input_name"></a> [name](#input\_name) | SSMパラメータ名 | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | SSMパラメータのタグ | `map(string)` | `{}` | no |
| <a name="input_type"></a> [type](#input\_type) | SSMパラメータの型。有効な型は`String`, `StringList`, `SecureString`。 | `string` | `"SecureString"` | no |
| <a name="input_value"></a> [value](#input\_value) | SSMパラメータの値 | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | SSMパラメータのARN |
| <a name="output_id"></a> [id](#output\_id) | SSMパラメータのID |
| <a name="output_name"></a> [name](#output\_name) | SSMパラメータの名前 |
