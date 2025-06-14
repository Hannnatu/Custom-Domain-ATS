import json
import os
import boto3
from datetime import datetime

# Set default region if not provided (for CI/CD or testing but if done in github yaml then ignore)
region = os.environ.get("AWS_REGION", "us-east-1")

# Initialize DynamoDB resource and table
dynamodb = boto3.resource('dynamodb', region_name=region)
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

        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Domain saved successfully'})
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'message': f'Internal server error: {str(e)}'})
        }

    except Exception as e:
        print(f"Error: {e}")
        # Internal server error response
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'Internal Server Error'})
        }

