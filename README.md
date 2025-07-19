🍱 Serverless Microservices – Food Ordering App
This project is a serverless, event-driven microservices architecture built entirely on AWS, using Infrastructure as Code (IaC) with Terraform and CI/CD pipelines via GitHub Actions. It simulates a food ordering application where users and restaurants interact through various decoupled microservices.

📌 Objectives
The main goals of this project were to:

Understand serverless architecture and event-driven patterns (e.g. EventBridge, SQS).

Practice Infrastructure as Code using Terraform.

Learn CI/CD automation with GitHub Actions.

Implement authentication/authorization with AWS Cognito and Lambda Authorizers.

Explore API Gateway integrations (proxy, AWS service).

Write unit and integration tests using pytest and moto.

🧱 Requirements
Python 3.10+

Terraform

AWS CLI

Visual Studio Code

☁️ Technologies Used
AWS Services
Lambda (with AWS Powertools for observability)

DynamoDB

API Gateway (REST)

Cognito (User Pools & Authorizers)

EventBridge

SQS

CloudWatch

X-Ray

IAM

Other Tools
Terraform – Infrastructure as Code

GitHub Actions – CI/CD pipelines

OpenAPI 2.0 – API definitions

pytest – for unit/integration testing

moto – for mocking AWS infrastructure

GitHub Secrets and AWS Secrets Manager – for sensitive credentials

🧪 Debugging Tools
Amazon CloudWatch

AWS X-Ray

Amazon Q

ChatGPT

Project notes / ideas : 
🔮 Obsidian 

📦 Project Structure
.
├── global_api_settings/               # Shared API configuration (e.g. gateway settings, throttling)
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
├── main.tf                            # Root-level Terraform definition
├── outputs.tf
├── variables.tf
│
├── orders/                            # Order management service
│   ├── main.tf
│   ├── outputs.tf
│   ├── variables.tf
│   ├── modules/                       # Infrastructure modules for the orders service
│   │   ├── orders_api_iam/           # IAM roles and policies for Orders API
│   │   ├── orders_apigateway/        # API Gateway configuration
│   │   ├── orders_dynamodb/          # DynamoDB tables for storing order data
│   │   ├── orders_lambda/            # Lambda functions for order operations
│   │   └── orders_lambda_iam/        # IAM permissions for Lambda functions
│   ├── src/
│   │   ├── lambda_functions/         # Source code for Lambda functions (CRUD operations)
│   │   └── layers/                   # Shared layers (e.g. utilities, dependencies)
│   └── tests/                        # Integration tests for the orders module
│
├── pooling_service/                  # Service for processing order-related events (updating status by restaurant) and polling by client
│   ├── events/                       # Sample test event payloads in JSON
│   ├── main.tf
│   ├── outputs.tf
│   ├── variables.tf
│   ├── polling-api.sh                # Helper script for testing the polling API
│   ├── modules/                      # EventBridge and Lambda infrastructure modules
│   ├── src/                          # Lambda function source code for API
│   └── tests/                        # Integration tests
│
├── user_profile_service/             # User profile and favorites management service
│   ├── main.tf
│   ├── outputs.tf
│   ├── variables.tf
│   ├── modules/                      # Modules for DynamoDB, Lambda, API Gateway, EventBridge, etc.
│   ├── src/                          # Lambda functions for address and favorites management
│   └── tests/                        # Integration tests for user profile service
│
├── users/                            # User account management service
│   ├── main.tf
│   ├── outputs.tf
│   ├── variables.tf
│   ├── modules/                      # Modules for API Gateway, Cognito, Lambda, SQS, SNS, etc.
│   ├── src/                          # Lambda functions for authorization and user operations
│   └── tests/                        # Integration and unit tests (including test event data)


The repository contains 4 modules (modules 2–5). The first module was basic and deployed manually for bootstrapping and is not included in the repository.

⚠️ This is a backend-only, infrastructure-focused project — no frontend included.

🧩 Module Overview
🔐 Module 2 – User Management & Authorization
User registration via Cognito

JWT token validation via a Lambda Authorizer connected to API Gateway

🍔 Module 3 – Orders Service (Synchronous)
Authenticated users (Cognito Authorizer) can create food orders

CRUD operations handled by Lambda + API Gateway (proxy integration)

Orders stored in DynamoDB

Includes idempotency logic to handle retries or failures gracefully

📨 Module 4 – Asynchronous Services (CQRS Pattern)
CQRS pattern used to split command (write) and query (read) responsibilities.

Address Service (via EventBridge)
Incoming requests routed via EventBridge to specific Lambda functions for address handling

Users immediately receive a response about status; actual processing is async

Favorites Service (via SQS)
Users add favorite restaurants

API Gateway sends request to SQS (custom AWS integration)

Lambda function consumes messages from the queue

No immediate response needed to the user

API Gateway Integrations used:

Lambda Proxy Integration

AWS Service Integration (EventBridge, SQS)

📡 Module 5 – Order Status Polling
EventBridge used by restaurants to change order status

Lambda updates the order's status in DynamoDB

Clients can poll the current order status by sending a GET request to the API

🔁 CI/CD Pipeline (GitHub Actions)
The project includes a complete CI/CD pipeline implemented using GitHub Actions.
Key features:

Trigger on push to test or main branches

Terraform environment initialization

AWS Credentials setup

Lambda packaging using GitHub matrix strategy:

Conditional logic to skip builds if they already exist in S3

(Future improvement idea: hash comparison for local vs remote builds)

Deployment steps:

terraform init, validate, plan, and apply

Unit & integration tests triggered post-deployment per module

Secrets like credentials, Terraform variables, and S3 bucket configurations are securely stored using GitHub Secrets.

🧪 Testing
Unit Tests: written using pytest and moto to simulate AWS services

Integration Tests: included for verifying service behavior post-deployment

Tests run automatically in GitHub Actions runners

🚧 Future Improvements
Add hash comparison for S3 build versions before replacing existing Lambda packages

Extend to include a frontend or integrate with Amplify

Add Step Functions for managing workflows across microservices
