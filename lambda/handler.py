import json
import os
import boto3
from datetime import datetime

def lambda_handler(event, context):
    # Set AWS region to avoid NoRegionError
    region = os.getenv('AWS_REGION', 'us-east-1')
    dynamodb = boto3.resource('dynamodb', region_name=region)

    # Get DynamoDB table name from environment variable at runtime
    table_name = os.environ['DYNAMODB_TABLE']
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
            'body': json.dumps({'message': 'Internal Server Error'})
        }
    except Exception:
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'Internal Server Error'})
        }



