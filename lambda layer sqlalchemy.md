# Lambda Layer Creation for SQLAlchemy

## Versions
- **AWS CLI:** `aws-cli/2.23.6 Python/3.12.6 Linux/6.1.119-129.201.amzn2023.x86_64 exe/x86_64.amzn.2023`
- **Python:** `Python 3.11.6`
- **pip:** `pip 24.3.1 from /home/ec2-user/.local/lib/python3.11/site-packages/pip (python 3.11)`

## Steps

### 1. Create the Lambda Layer Directory
To begin, create the directory structure for your Lambda layer:
```bash
mkdir -p lambda_layer/python/lib/python3.11/site-packages


### 2. Install the SQLAlchemy Package
pip install SQLAlchemy -t lambda_layer/python/lib/python3.11/site-packages

### 3. Zip the Layer
cd lambda_layer
zip -r sqlalchemy_layer.zip python

### 4. Publish the Lambda Layer
aws lambda publish-layer-version --layer-name sqlalchemy \
    --description "SQLAlchemy ORM for Python" \
    --license-info "MIT" \
    --zip-file fileb:///home/ec2-user/lambda_layer/sqlalchemy_layer.zip \
    --compatible-runtimes python3.9 python3.10 python3.11 \
    --compatible-architectures arm64 x86_64
