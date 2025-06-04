# Authenticate
aws ecr get-login-password --region us-east-2 | \
docker login --username AWS --password-stdin 333661424489.dkr.ecr.us-east-2.amazonaws.com

# Tag image
docker tag hello-world:latest \
333661424489.dkr.ecr.us-east-2.amazonaws.com/libertytestecr:latest

# Push image
docker push 333661424489.dkr.ecr.us-east-2.amazonaws.com/libertytestecr:latest
