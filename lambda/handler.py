import json
import os
import boto3
from datetime import datetime

# Use os.getenv with fallback to avoid KeyError
DYNAMODB_TABLE_NAME = os.getenv('DYNAMODB_TABLE', 'mock-table')
AWS_REGION = os.getenv('AWS_REGION', 'us-east-1')

dynamodb = boto3.resource('dynamodb', region_name=AWS_REGION)
table = dynamodb.Table(DYNAMODB_TABLE_NAME)

def lambda_handler(event, context):
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
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'Internal Server Error'})
        }


