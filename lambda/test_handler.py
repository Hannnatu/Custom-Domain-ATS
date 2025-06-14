import os
import json
import pytest

# Set required environment variables before importing the handler
os.environ['DYNAMODB_TABLE'] = 'mock-table'
os.environ['AWS_REGION'] = 'us-east-1'

from handler import lambda_handler

def test_lambda_handler_success(monkeypatch):
    # Mock the boto3 Table class
    class MockTable:
        def put_item(self, Item):
            assert 'domain' in Item
            assert 'createdAt' in Item
            return {}

    class MockDynamoDB:
        def Table(self, name):
            return MockTable()

    # Patch the boto3 resource to use our mock
    monkeypatch.setattr('handler.boto3.resource', lambda service, region_name=None: MockDynamoDB())

    event = {
        "body": json.dumps({"domain": "example.com"})
    }
    context = {}
    response = lambda_handler(event, context)
    assert response['statusCode'] == 200
    assert json.loads(response['body'])['message'] == 'Domain saved successfully'

def test_lambda_handler_missing_domain(monkeypatch):
    event = {
        "body": json.dumps({})
    }
    context = {}
    # No need to patch if we just test logic before boto3 is hit
    response = lambda_handler(event, context)
    assert response['statusCode'] == 400
    assert json.loads(response['body'])['message'] == 'Domain is required'

def test_lambda_handler_invalid_json(monkeypatch):
    event = {
        "body": "not-a-json"
    }
    context = {}
    response = lambda_handler(event, context)
    assert response['statusCode'] == 500
    assert json.loads(response['body'])['message'] == 'Invalid JSON'




