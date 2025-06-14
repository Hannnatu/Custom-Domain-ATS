import json
import os
import boto3
from datetime import datetime

def lambda_handler(event, context):
    # Read env vars *only inside the function*, not at import time
    region = os.getenv('AWS_REGION', 'us-east-1')
    table_name = os.getenv('DYNAMODB_TABLE', 'mock-table')

    # Create the DynamoDB resource with a fallback region
    dynamodb = boto3.resource('dynamodb', region_name=region)
    table = dynamodb.Table(table_name)

    try:
        body = json.loads(event.get('body', '{}'))
        domain = body.get('domain')

        if not domain:
            return {
                'statusCode': 400,
                'body': json.dumps({'message': 'Domain is required'})
            }

        table.put_item(Item={
            'domain': domain,
            'createdAt': datetime.utcnow().isoformat()
        })

        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Domain saved successfully'})
        }

    except json.JSONDecodeError:
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'Invalid JSON'})
        }
    except Exception:
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'Internal Server Error'})
        }



