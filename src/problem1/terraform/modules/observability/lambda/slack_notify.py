import json
import os
import urllib.error
import urllib.request


def handler(event, context):
    webhook = os.environ.get("SLACK_WEBHOOK_URL")
    if not webhook:
        raise ValueError("SLACK_WEBHOOK_URL not configured")

    records = event.get("Records", [])
    text_parts = []
    for record in records:
        sns = record.get("Sns", {})
        subject = sns.get("Subject", "Alarm")
        message = sns.get("Message", "")
        text_parts.append(f"*{subject}*\n{message}")

    body = json.dumps({"text": "\n\n".join(text_parts)}).encode("utf-8")
    req = urllib.request.Request(
        webhook,
        data=body,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=10) as resp:
        resp.read()
    return {"statusCode": 200}
