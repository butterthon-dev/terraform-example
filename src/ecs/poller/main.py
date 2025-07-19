import os
import time
import json

import boto3
import requests


def main():
    """
    SQSキューからメッセージを継続的にポーリングし、処理する
    """
    sqs_client = boto3.client("sqs")

    queue_url = os.environ["SQS_QUEUE_URL"]
    print("SQSポーリングを開始します...")

    while True:
        try:
            response = sqs_client.receive_message(
                QueueUrl=queue_url,
                MaxNumberOfMessages=10,
                WaitTimeSeconds=20,
                AttributeNames=['All'],
                MessageAttributeNames=['All']
            )

            messages = response.get("Messages", [])

            if not messages:
                print("メッセージはありません。ポーリングを継続します...")
                continue

            for message in messages:
                message_dict = json.dumps(message, ensure_ascii=False, indent=2)
                print(f"受信したメッセージ: {message_dict}")

                # consumerにメッセージを送信
                message_body = message["Body"]
                response = requests.post(
                    os.environ["CALLBACK_URL"],
                    data=message_body,
                    headers={"Content-Type": "application/json"},
                    timeout=10
                )
                response.raise_for_status()
                print(f"consumerにメッセージを送信しました: {response.status_code} {response.text}")

                # メッセージを処理したのでキューから削除
                sqs_client.delete_message(
                    QueueUrl=queue_url,
                    ReceiptHandle=message['ReceiptHandle']
                )
                print(f"メッセージ {message['MessageId']} を削除しました。")

        except Exception as e:
            print(f"エラーが発生しました: {e}")

        finally:
            time.sleep(60)

if __name__ == "__main__":
    main() 
