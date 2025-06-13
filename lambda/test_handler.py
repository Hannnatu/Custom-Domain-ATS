import json
import pytest
from handler import lambda_handler

def test_lambda_handler_success(monkeypatch):
    # Mock boto3 DynamoDB Table put_item
    class MockTable:
        def put_item(self, Item):
            assert 'domain' in Item
            assert 'createdAt' in Item
            return {}

    class MockDynamoDB:
        def Table(self, name):
            return MockTable()

    monkeypatch.setattr('handler.boto3.resource', lambda service: MockDynamoDB())

    event = {
        "body": json.dumps({"domain": "example.com"})
    }
    context = {}
    response = lambda_handler(event, context)
    assert response['statusCode'] == 200
    body = json.loads(response['body'])
    assert body['message'] == 'Domain saved successfully'

def test_lambda_handler_missing_domain():
    event = {
        "body": json.dumps({})
    }
    context = {}
    response = lambda_handler(event, context)
    assert response['statusCode'] == 400
    body = json.loads(response['body'])
    assert body['message'] == 'Domain is required'

def test_lambda_handler_invalid_json():
    event = {
        "body": "not-a-json"
    }
    context = {}
    response = lambda_handler(event, context)
    assert response['statusCode'] == 500
    body = json.loads(response['body'])
    assert body['message'] == 'Internal Server Error'

