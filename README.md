# SonarQube Quickstart

This setup provides a simple way to quickly launch a SonarQube instance with pre-configured admin credentials, a project
setup, and an authentication token ready to run static code analysis. The goal is to minimize setup time and allow you
to focus on your code quality.

---

<p align="center">
  <a href="https://hub.docker.com/repository/docker/amithkoujalgi/sonarqube-10.6-community-qs/general" target="_blank"><img src="https://img.shields.io/docker/pulls/amithkoujalgi/sonarqube-10.6-community-qs?style=for-the-badge&link=https%3A%2F%2Fhub.docker.com%2Fr%2Famithkoujalgi%2Fpdf-bot"/></a>
</p>


## Getting Started

### Start SonarQube Server

To quickly start a SonarQube instance in a Docker container, run the following command:

```shell
docker run -d \
  -p 9000:9000 \
  -e SQ_PASSWORD=sonar \
  -e SQ_PROJECT_NAME="My Cool Project" \
  -e SQ_PROJECT_KEY="mycoolproject" \
  -e SQ_PROJECT_TOKEN_NAME="my-cool-project-token" \
  -v ~/sonarqube-quickstart:/tmp/sonarqube \
  --name sonarqube \
  amithkoujalgi/sonarqube-10.6-community-qs:latest
```

This will:

- Launch SonarQube in a container.
- Automatically reset admin credentials
- Creates a new project.
- Generates a token.

Once the server is up and running, you can access the SonarQube dashboard at http://localhost:9000.

The token is saved in the `~/sonarqube-quickstart/token.txt` file.
A README file is available at `~/sonarqube-quickstart/README.md`, which explains how to run static code analysis on your
local code.

### IDE Integration

To integrate SonarQube into your development
workflow, [install](https://www.sonarsource.com/products/sonarlint/ide-login/)
the [SonarLint](https://www.sonarsource.com/products/sonarlint/) plugin in your preferred IDE.

Supported IDEs

- JetBrains (e.g., IntelliJ IDEA, PyCharm, WebStorm)
- Visual Studio
- VS Code
- Eclipse

After installation, configure SonarLint with the token (found in the above mentioned file) and URL (
typically `http://localhost:9000`) of your SonarQube instance to start analyzing code
directly from your IDE.

### Running Static Code Analysis

Once the SonarQube server is running and your IDE is integrated, follow the steps outlined in the README file in the
`~/sonarqube-quickstart` folder to begin running static code analysis on your projects.

You can now analyze your code quality, identify potential bugs, security vulnerabilities, and code smells directly
within your development environment.
