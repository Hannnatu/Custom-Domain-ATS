import json
import os
import boto3
from datetime import datetime

# Initialize DynamoDB resource and table from environment variable
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['DYNAMODB_TABLE'])

def lambda_handler(event, context):
    try:
        # Parse the JSON body from API Gateway event
        body = json.loads(event.get('body', '{}'))
        domain = body.get('domain')

        # Validate that domain is provided
        if not domain:
            return {
                'statusCode': 400,
                'body': json.dumps({'message': 'Domain is required'})
            }

        # Put item into DynamoDB with current UTC timestamp
        table.put_item(Item={
            'domain': domain,
            'createdAt': datetime.utcnow().isoformat()
        })

        # Success response
        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Domain saved successfully'})
        }

    except Exception as e:
        print(f"Error: {e}")
        # Internal server error response
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'Internal Server Error'})
        }

