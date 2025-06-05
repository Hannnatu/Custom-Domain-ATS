import json
import os
import boto3
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['DYNAMODB_TABLE'])

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

    except Exception as e:
        print(e)
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'Internal Server Error'})
        }

