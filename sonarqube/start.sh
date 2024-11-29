#!/bin/bash
set -e

/opt/sonarqube/docker/entrypoint.sh &

# Wait until localhost:9000 is up
while ! curl -s -o /dev/null -w "%{http_code}" http://localhost:9000/api/settings/login_message | grep -q '^200$'; do
  echo "Waiting for Sonarqube server to be available..."
  sleep 3
done

NEW_PASSWORD=${SQ_PASSWORD:-"admin"}
NEW_PROJECT_NAME=${SQ_PROJECT_NAME:-"MyDefaultProject"}
NEW_PROJECT_KEY=${SQ_PROJECT_KEY:-"default_project_key"}
NEW_PROJECT_TOKEN_NAME=${SQ_PROJECT_TOKEN_NAME:-"MyProjectToken"}

check_invalid_password() {
  if [[ "$NEW_PASSWORD" =~ [^a-zA-Z0-9] ]]; then
    echo "Error: Password contains spaces or special characters: $NEW_PASSWORD"
    exit 1
  fi
}

check_invalid_password

NEW_PROJECT_NAME=$(echo "$NEW_PROJECT_NAME" | tr -d -c '[:alnum:]')
NEW_PROJECT_KEY=$(echo "$NEW_PROJECT_KEY" | tr -d -c '[:alnum:]')
NEW_PROJECT_TOKEN_NAME=$(echo "$NEW_PROJECT_TOKEN_NAME" | tr -d -c '[:alnum:]')

echo "Sonarqube is up!"

echo "Changing password..."
curl -u admin:admin -X POST "http://localhost:9000/api/users/change_password?login=admin&previousPassword=admin&password=$NEW_PASSWORD"
echo "Creating project..."
curl -u admin:"$NEW_PASSWORD" -X POST "http://localhost:9000/api/projects/create?name=$NEW_PROJECT_NAME&project=$NEW_PROJECT_KEY"
echo "Creating project token..."
TOKEN=$(curl --silent -u admin:"$NEW_PASSWORD" -X POST "http://localhost:9000/api/user_tokens/generate?name=$NEW_PROJECT_TOKEN_NAME" | grep -o '"token":"[^"]*"' | sed 's/"token":"\([^"]*\)"/\1/')

mkdir -p /tmp/sonarqube
touch /tmp/sonarqube/token.txt
echo "$TOKEN" > /tmp/sonarqube/token.txt

echo "==================================="
echo "       SonarQube Token"
echo "==================================="
echo ""
echo "Token: $TOKEN"
echo ""
echo "==================================="
echo "The token has also been saved to: /tmp/sonarqube/token.txt"

cat <<EOF > /tmp/sonarqube/README.md
## Install \`sonar-scanner\`

\`\`\`shell
brew install sonar-scanner
\`\`\`

## Trigger analysis of your code on SonarQube

\`\`\`shell
cd /path/to/your/code/root

sonar-scanner \
  -Dsonar.projectKey="${NEW_PROJECT_KEY}" \
  -Dsonar.projectVersion=main \
  -Dsonar.python.version=3.11 \
  -Dsonar.sources=. \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.token="${TOKEN}"
\`\`\`

## Pass a branch name for reference

This helps to keep track of different branches

\`\`\`shell
sonar-scanner \
  -Dsonar.projectKey="${NEW_PROJECT_KEY}" \
   -Dsonar.projectVersion=$(git rev-parse --abbrev-ref HEAD) \
  -Dsonar.python.version=3.11 \
  -Dsonar.sources=. \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.token="${TOKEN}"
\`\`\`

EOF

tail -f /opt/sonarqube/logs/*

exec "$@"