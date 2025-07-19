# ################################################################################
# # ECSのproducerサービスのスケーリング設定
# #
# # ・スケールアウト条件
# #  ・SQSキューのApproximateNumberOfMessagesVisibleが50件を超えたとき
# #  ・CPU使用率が70%以上のとき
# ################################################################################
# resource "aws_appautoscaling_target" "appautoscaling_ecs_target_producer" {
#   service_namespace  = "ecs" # 今回はecsがターゲット
#   resource_id        = "service/${module.ecs_cluster.cluster_name}/${module.ecs_service_producer.service_name}"
#   scalable_dimension = "ecs:service:DesiredCount"
#   min_capacity       = 1 # スケーリングする最小タスク数
#   max_capacity       = 2 # スケーリングする最大タスク数
# }

# # スケールアウトの定義(タスク増加数)
# resource "aws_appautoscaling_policy" "appautoscaling_cpu_high_producer" {
#   name               = "${module.ecs_service_producer.service_name}-scale_out" # ポリシーの名前(任意だが、環境がわかるように設定したい)
#   resource_id        = aws_appautoscaling_target.appautoscaling_ecs_target_producer.resource_id
#   scalable_dimension = aws_appautoscaling_target.appautoscaling_ecs_target_producer.scalable_dimension
#   service_namespace  = aws_appautoscaling_target.appautoscaling_ecs_target_producer.service_namespace

#   # ステップスケーリングポリシーの設定
#   step_scaling_policy_configuration {
#     adjustment_type = "ChangeInCapacity"

#     cooldown                = 120       # クールダウンタイム。120秒後に再度スケーリングする。
#     metric_aggregation_type = "Average" # メトリクスの集計タイプ、今回は「平均値」

#     # ステップ調整の設定(タスクの増加数)
#     step_adjustment {
#       metric_interval_lower_bound = 0
#       scaling_adjustment          = 1 # 一度に増加させたいタスク数を設定
#     }
#   }
# }

# # スケールアウトするためのアラーム
# resource "aws_cloudwatch_metric_alarm" "alarm_cpu_high_producer" {
#   alarm_name = "${module.ecs_service_producer.service_name}-cpu_utilization_high" # アラームの名前(任意だが、環境がわかるように設定したい)

#   # しきい値（threshold）以上の時にアラートが鳴るように設定
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = "1"
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/ECS"
#   period              = "60"
#   statistic           = "Average"

#   threshold = "70" # CPU使用率が80%以上のとき、アラーム

#   # ターゲットのECSクラスター名とサービス名を指定
#   dimensions = {
#     ClusterName = module.ecs_cluster.cluster_name
#     ServiceName = module.ecs_service_producer.service_name
#   }

#   # アラート発生時に実行するpolicyを設定。スケールアウトの定義のものを記載する。
#   alarm_actions = [aws_appautoscaling_policy.appautoscaling_cpu_high_producer.arn]
# }


# # スケールアウトの定義(タスク増加数)
# resource "aws_appautoscaling_policy" "appautoscaling_number_of_message_producer" {
#   name               = "${module.ecs_service_producer.service_name}-number-of-message" # ポリシーの名前(任意だが、環境がわかるように設定したい)
#   resource_id        = aws_appautoscaling_target.appautoscaling_ecs_target_producer.resource_id
#   scalable_dimension = aws_appautoscaling_target.appautoscaling_ecs_target_producer.scalable_dimension
#   service_namespace  = aws_appautoscaling_target.appautoscaling_ecs_target_producer.service_namespace

#   # ステップスケーリングポリシーの設定
#   step_scaling_policy_configuration {
#     adjustment_type = "ChangeInCapacity"

#     cooldown = 120 # クールダウンタイム。120秒後に再度スケーリングする。
#     # metric_aggregation_type = "Average"  # メトリクスの集計タイプ、今回は「平均値」

#     # ステップ調整の設定(タスクの増加数)
#     step_adjustment {
#       metric_interval_lower_bound = 0
#       scaling_adjustment          = 1 # 一度に増加させたいタスク数を設定
#     }
#   }
# }

# # スケールアウトするためのアラーム
# resource "aws_cloudwatch_metric_alarm" "alarm_number_of_message_producer" {
#   alarm_name = "${module.ecs_service_producer.service_name}-number-of-message"

#   # しきい値（threshold）以上の時にアラートが鳴るように設定
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = "1"
#   metric_name         = "ApproximateNumberOfMessagesVisible"
#   namespace           = "AWS/SQS"
#   period              = "60"
#   statistic           = "Sum"

#   threshold = "50"

#   # ターゲットのECSクラスター名とサービス名を指定
#   dimensions = {
#     QueueName = module.sqs.name
#   }

#   # アラート発生時に実行するpolicyを設定。スケールアウトの定義のものを記載する。
#   alarm_actions = [aws_appautoscaling_policy.appautoscaling_number_of_message_producer.arn]
# }
