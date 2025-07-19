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
| [aws_secretsmanager_secret.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_description"></a> [description](#input\_description) | シークレットの説明 | `string` | `""` | no |
| <a name="input_force_overwrite_replica_secret"></a> [force\_overwrite\_replica\_secret](#input\_force\_overwrite\_replica\_secret) | Destination Regionにある同名のシークレットを上書きするかどうか | `bool` | `null` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | シークレットの暗号化に使用するKMSキーのID | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | シークレットの名前 | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | シークレットの名前のプレフィックス | `string` | `null` | no |
| <a name="input_recovery_window_in_days"></a> [recovery\_window\_in\_days](#input\_recovery\_window\_in\_days) | AWS Secrets Managerがシークレットを削除するまでの待機日数。7～30日の範囲を指定可能。リカバリせずに強制的に削除する場合は0。デフォルト値は30。 | `number` | `null` | no |
| <a name="input_replica"></a> [replica](#input\_replica) | シークレットのレプリカ | <pre>map(object({<br/>    region     = string<br/>    kms_key_id = string<br/>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | SecretsManagerのタグ | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_secret_arn"></a> [secret\_arn](#output\_secret\_arn) | SecretsManagerのシークレットARN |
| <a name="output_secret_name"></a> [secret\_name](#output\_secret\_name) | SecretsManagerのシークレット名 |
