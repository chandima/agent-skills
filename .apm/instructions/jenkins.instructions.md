---
applyTo: "**/Jenkinsfile*"
description: "Jenkins pipeline standards with declarative syntax, shared libraries, and security best practices"
---

# Jenkins Pipeline Standards

## Pipeline Types

### Declarative vs Scripted

| Aspect | Declarative | Scripted |
|--------|-------------|----------|
| Syntax | Structured, opinionated | Flexible, Groovy-based |
| Learning curve | Lower | Higher |
| Validation | Built-in | Runtime only |
| Use case | Most pipelines | Complex logic |
| **Recommendation** | **Default choice** | When needed |

### Declarative Pipeline Structure

```groovy
pipeline {
    agent any
    
    options {
        timeout(time: 30, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '10'))
        disableConcurrentBuilds()
    }
    
    environment {
        APP_NAME = 'myapp'
        REGISTRY = 'registry.example.com'
    }
    
    stages {
        stage('Build') {
            steps {
                sh 'npm ci'
                sh 'npm run build'
            }
        }
        
        stage('Test') {
            steps {
                sh 'npm test'
            }
        }
        
        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                sh './deploy.sh'
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
```

## Agent Configuration

### Agent Types

```groovy
pipeline {
    // Run on any available agent
    agent any
    
    // Run on agent with specific label
    agent {
        label 'linux && docker'
    }
    
    // Run in Docker container
    agent {
        docker {
            image 'node:20-alpine'
            args '-v /tmp:/tmp'
        }
    }
    
    // Run in Kubernetes pod
    agent {
        kubernetes {
            yaml '''
            apiVersion: v1
            kind: Pod
            spec:
              containers:
              - name: node
                image: node:20
                command: ['sleep']
                args: ['infinity']
              - name: docker
                image: docker:24-dind
                securityContext:
                  privileged: true
            '''
            defaultContainer 'node'
        }
    }
}
```

### Stage-Level Agents

```groovy
pipeline {
    agent none  // No global agent
    
    stages {
        stage('Build') {
            agent {
                docker { image 'node:20' }
            }
            steps {
                sh 'npm ci && npm run build'
            }
        }
        
        stage('Test') {
            agent {
                docker { image 'node:20' }
            }
            steps {
                sh 'npm test'
            }
        }
        
        stage('Deploy') {
            agent {
                label 'deploy-server'
            }
            steps {
                sh './deploy.sh'
            }
        }
    }
}
```

## Stages and Steps

### Stage Best Practices

```groovy
stages {
    // Descriptive stage names
    stage('Install Dependencies') {
        steps {
            sh 'npm ci'
        }
    }
    
    stage('Run Unit Tests') {
        steps {
            sh 'npm run test:unit'
        }
    }
    
    stage('Run Integration Tests') {
        steps {
            sh 'npm run test:integration'
        }
    }
    
    // Avoid generic names like "Stage 1", "Build", etc. without context
}
```

### Parallel Execution

```groovy
stage('Tests') {
    parallel {
        stage('Unit Tests') {
            agent { docker { image 'node:20' } }
            steps {
                sh 'npm run test:unit'
            }
        }
        stage('Integration Tests') {
            agent { docker { image 'node:20' } }
            steps {
                sh 'npm run test:integration'
            }
        }
        stage('E2E Tests') {
            agent { label 'e2e-runner' }
            steps {
                sh 'npm run test:e2e'
            }
        }
    }
}
```

### Matrix Builds

```groovy
stage('Build Matrix') {
    matrix {
        axes {
            axis {
                name 'NODE_VERSION'
                values '18', '20', '22'
            }
            axis {
                name 'OS'
                values 'linux', 'windows'
            }
        }
        excludes {
            exclude {
                axis {
                    name 'OS'
                    values 'windows'
                }
                axis {
                    name 'NODE_VERSION'
                    values '18'
                }
            }
        }
        stages {
            stage('Build') {
                steps {
                    echo "Building on ${OS} with Node ${NODE_VERSION}"
                }
            }
        }
    }
}
```

## Credentials and Secrets

### Credential Types

```groovy
pipeline {
    environment {
        // Username/password credentials
        DOCKER_CREDS = credentials('docker-registry-creds')
        // Exposes: DOCKER_CREDS_USR, DOCKER_CREDS_PSW
        
        // Secret text
        API_KEY = credentials('api-key')
        
        // Secret file
        KUBECONFIG = credentials('kubeconfig-file')
    }
    
    stages {
        stage('Deploy') {
            steps {
                sh '''
                    echo $DOCKER_CREDS_PSW | docker login -u $DOCKER_CREDS_USR --password-stdin
                    docker push myimage
                '''
            }
        }
    }
}
```

### WithCredentials Block

```groovy
stage('Deploy') {
    steps {
        withCredentials([
            usernamePassword(
                credentialsId: 'docker-creds',
                usernameVariable: 'DOCKER_USER',
                passwordVariable: 'DOCKER_PASS'
            ),
            string(
                credentialsId: 'api-token',
                variable: 'API_TOKEN'
            ),
            file(
                credentialsId: 'ssh-key',
                variable: 'SSH_KEY_FILE'
            ),
            sshUserPrivateKey(
                credentialsId: 'ssh-creds',
                keyFileVariable: 'SSH_KEY',
                usernameVariable: 'SSH_USER'
            )
        ]) {
            sh '''
                echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                curl -H "Authorization: Bearer $API_TOKEN" https://api.example.com
                ssh -i $SSH_KEY_FILE user@host "deploy.sh"
            '''
        }
    }
}
```

### Credential Scoping

```groovy
// Use folder-scoped credentials for team isolation
// Configure in Jenkins: Folder > Credentials

// Use domain-scoped credentials for specific services
// Configure in Jenkins: Manage Jenkins > Credentials > Domains
```

## Environment Variables

### Environment Block

```groovy
pipeline {
    environment {
        // Static values
        APP_NAME = 'myapp'
        
        // Credentials
        DOCKER_CREDS = credentials('docker-creds')
        
        // Dynamic values using returnStdout
        GIT_COMMIT_SHORT = sh(
            script: 'git rev-parse --short HEAD',
            returnStdout: true
        ).trim()
    }
    
    stages {
        stage('Build') {
            environment {
                // Stage-specific variables
                BUILD_ENV = 'production'
            }
            steps {
                echo "Building ${APP_NAME} at ${GIT_COMMIT_SHORT}"
            }
        }
    }
}
```

### Built-in Variables

| Variable | Description |
|----------|-------------|
| `BUILD_NUMBER` | Current build number |
| `BUILD_ID` | Build identifier |
| `JOB_NAME` | Name of the job |
| `WORKSPACE` | Workspace directory path |
| `JENKINS_URL` | Jenkins server URL |
| `BRANCH_NAME` | Branch being built (multibranch) |
| `CHANGE_ID` | Pull request ID (multibranch) |
| `GIT_COMMIT` | Git commit hash |

## Conditional Execution

### When Directive

```groovy
stages {
    stage('Deploy to Staging') {
        when {
            branch 'develop'
        }
        steps {
            sh './deploy.sh staging'
        }
    }
    
    stage('Deploy to Production') {
        when {
            allOf {
                branch 'main'
                triggeredBy 'user'
            }
        }
        steps {
            sh './deploy.sh production'
        }
    }
    
    stage('Run on PR') {
        when {
            changeRequest()
        }
        steps {
            sh './pr-checks.sh'
        }
    }
    
    stage('Skip CI') {
        when {
            not {
                changelog '.*\\[skip ci\\].*'
            }
        }
        steps {
            sh './build.sh'
        }
    }
}
```

### Complex Conditions

```groovy
stage('Conditional Deploy') {
    when {
        anyOf {
            branch 'main'
            tag pattern: 'v\\d+\\.\\d+\\.\\d+', comparator: 'REGEXP'
        }
        beforeAgent true  // Evaluate before allocating agent
    }
    steps {
        sh './deploy.sh'
    }
}

stage('Environment Check') {
    when {
        expression {
            return env.DEPLOY_TARGET == 'production' && currentBuild.resultIsBetterOrEqualTo('SUCCESS')
        }
    }
    steps {
        echo 'Deploying to production'
    }
}
```

## Input and Approval

### Manual Approval

```groovy
stage('Deploy to Production') {
    steps {
        script {
            def userInput = input(
                id: 'deploy-approval',
                message: 'Deploy to production?',
                parameters: [
                    choice(
                        name: 'ENVIRONMENT',
                        choices: ['staging', 'production'],
                        description: 'Target environment'
                    ),
                    booleanParam(
                        name: 'DRY_RUN',
                        defaultValue: true,
                        description: 'Perform dry run'
                    )
                ],
                submitter: 'admin,deployers'
            )
            
            env.DEPLOY_ENV = userInput.ENVIRONMENT
            env.DRY_RUN = userInput.DRY_RUN
        }
        
        sh "./deploy.sh ${env.DEPLOY_ENV}"
    }
}
```

### Timeout for Input

```groovy
stage('Approval') {
    options {
        timeout(time: 1, unit: 'HOURS')
    }
    steps {
        input message: 'Proceed with deployment?'
    }
}
```

## Shared Libraries

### Library Structure

```
vars/
├── buildApp.groovy       # Global variable (call steps)
├── deployApp.groovy      # Global variable
└── utils.groovy          # Utility functions

src/
└── com/
    └── example/
        ├── Docker.groovy # Classes
        └── Slack.groovy

resources/
├── scripts/
│   └── deploy.sh
└── templates/
    └── config.yaml
```

### Global Variables (vars/)

```groovy
// vars/buildApp.groovy
def call(Map config = [:]) {
    def nodeVersion = config.nodeVersion ?: '20'
    def skipTests = config.skipTests ?: false
    
    pipeline {
        agent {
            docker { image "node:${nodeVersion}" }
        }
        
        stages {
            stage('Install') {
                steps {
                    sh 'npm ci'
                }
            }
            
            stage('Build') {
                steps {
                    sh 'npm run build'
                }
            }
            
            stage('Test') {
                when {
                    expression { !skipTests }
                }
                steps {
                    sh 'npm test'
                }
            }
        }
    }
}
```

### Using Shared Libraries

```groovy
// Jenkinsfile
@Library('my-shared-library@main') _

buildApp(
    nodeVersion: '20',
    skipTests: false
)

// Or use specific functions
@Library('my-shared-library@v1.2.0') _

pipeline {
    agent any
    stages {
        stage('Deploy') {
            steps {
                deployApp(
                    environment: 'production',
                    version: env.BUILD_NUMBER
                )
            }
        }
    }
}
```

### Library Classes

```groovy
// src/com/example/Docker.groovy
package com.example

class Docker implements Serializable {
    def steps
    
    Docker(steps) {
        this.steps = steps
    }
    
    def build(String imageName, String dockerfile = 'Dockerfile') {
        steps.sh "docker build -t ${imageName} -f ${dockerfile} ."
    }
    
    def push(String imageName, String registry) {
        steps.sh "docker push ${registry}/${imageName}"
    }
}

// Usage in Jenkinsfile
@Library('my-shared-library') _
import com.example.Docker

pipeline {
    agent any
    stages {
        stage('Build Image') {
            steps {
                script {
                    def docker = new Docker(this)
                    docker.build("myapp:${BUILD_NUMBER}")
                }
            }
        }
    }
}
```

## Post Actions

### Post Block

```groovy
pipeline {
    agent any
    
    stages {
        stage('Build') {
            steps {
                sh 'npm run build'
            }
        }
    }
    
    post {
        always {
            // Always runs
            junit '**/test-results/*.xml'
            archiveArtifacts artifacts: 'dist/**/*', fingerprint: true
            cleanWs()
        }
        
        success {
            // Only on success
            slackSend(
                channel: '#builds',
                color: 'good',
                message: "Build ${BUILD_NUMBER} succeeded"
            )
        }
        
        failure {
            // Only on failure
            slackSend(
                channel: '#builds',
                color: 'danger',
                message: "Build ${BUILD_NUMBER} failed"
            )
            emailext(
                subject: "Build Failed: ${JOB_NAME}",
                body: "Check console output: ${BUILD_URL}",
                to: 'team@example.com'
            )
        }
        
        unstable {
            // Test failures but build completed
            echo 'Build is unstable'
        }
        
        changed {
            // State changed from previous build
            echo 'Build status changed'
        }
        
        fixed {
            // Previous build failed, this one succeeded
            echo 'Build is fixed!'
        }
        
        regression {
            // Previous build succeeded, this one failed
            echo 'Build regressed!'
        }
        
        cleanup {
            // Runs after all other post conditions
            deleteDir()
        }
    }
}
```

## Pipeline Options

### Common Options

```groovy
pipeline {
    options {
        // Build timeout
        timeout(time: 30, unit: 'MINUTES')
        
        // Retry on failure
        retry(3)
        
        // Discard old builds
        buildDiscarder(logRotator(
            numToKeepStr: '10',
            daysToKeepStr: '30',
            artifactNumToKeepStr: '5'
        ))
        
        // Prevent concurrent builds
        disableConcurrentBuilds()
        
        // Add timestamps to console output
        timestamps()
        
        // Skip default checkout
        skipDefaultCheckout()
        
        // Preserve stashes for restarts
        preserveStashes(buildCount: 5)
        
        // Quiet period before build
        quietPeriod(30)
        
        // ANSI color output
        ansiColor('xterm')
    }
}
```

### Stage Options

```groovy
stage('Deploy') {
    options {
        timeout(time: 10, unit: 'MINUTES')
        retry(2)
        lock('deploy-lock')  // Prevent parallel deploys
    }
    steps {
        sh './deploy.sh'
    }
}
```

## Triggers

### Build Triggers

```groovy
pipeline {
    triggers {
        // Poll SCM
        pollSCM('H/5 * * * *')
        
        // Cron schedule
        cron('H 2 * * *')  // Daily at 2 AM (with hash for load balancing)
        
        // Upstream job
        upstream(
            upstreamProjects: 'job1,job2',
            threshold: hudson.model.Result.SUCCESS
        )
        
        // GitHub webhook (configure in GitHub)
        githubPush()
    }
}
```

## Anti-Patterns

### Avoid These Patterns

```groovy
// Bad: Hardcoded credentials
stage('Deploy') {
    steps {
        sh 'curl -u admin:password123 ...'  // Never hardcode
    }
}

// Bad: No timeout
pipeline {
    agent any
    // Missing: options { timeout(...) }
}

// Bad: Using sh for everything
stage('Read File') {
    steps {
        script {
            def content = sh(script: 'cat config.json', returnStdout: true)
            // Use readFile() instead
        }
    }
}

// Bad: Excessive scripted blocks in declarative
stage('Build') {
    steps {
        script {
            // 50+ lines of Groovy
            // Should use shared library
        }
    }
}

// Bad: No error handling
stage('Deploy') {
    steps {
        sh './deploy.sh'
        // No post { failure { ... } }
    }
}
```

### Preferred Patterns

```groovy
// Good: Use credentials binding
stage('Deploy') {
    steps {
        withCredentials([usernamePassword(credentialsId: 'api-creds', ...)]) {
            sh 'curl -u $USERNAME:$PASSWORD ...'
        }
    }
}

// Good: Timeout and error handling
pipeline {
    options {
        timeout(time: 30, unit: 'MINUTES')
    }
    post {
        failure {
            slackSend(...)
        }
    }
}

// Good: Use built-in steps
stage('Read Config') {
    steps {
        script {
            def content = readFile('config.json')
            def config = readJSON(file: 'config.json')
        }
    }
}

// Good: Extract to shared library
@Library('my-lib') _

pipeline {
    stages {
        stage('Build') {
            steps {
                buildApp(nodeVersion: '20')
            }
        }
    }
}
```

## Docker Integration

### Docker Pipeline

```groovy
pipeline {
    agent {
        docker {
            image 'node:20-alpine'
            args '-v $HOME/.npm:/root/.npm'  // Cache npm
        }
    }
    
    stages {
        stage('Build') {
            steps {
                sh 'npm ci'
                sh 'npm run build'
            }
        }
    }
}
```

### Building Docker Images

```groovy
stage('Build Image') {
    steps {
        script {
            def image = docker.build("myapp:${BUILD_NUMBER}")
            
            docker.withRegistry('https://registry.example.com', 'registry-creds') {
                image.push()
                image.push('latest')
            }
        }
    }
}
```

### Docker Compose

```groovy
stage('Integration Tests') {
    steps {
        sh 'docker-compose -f docker-compose.test.yml up -d'
        sh 'npm run test:integration'
    }
    post {
        always {
            sh 'docker-compose -f docker-compose.test.yml down -v'
        }
    }
}
```

## Debugging

### Debug Techniques

```groovy
stage('Debug') {
    steps {
        // Print environment
        sh 'printenv | sort'
        
        // Print workspace contents
        sh 'ls -la'
        
        // Echo variables
        echo "Build: ${BUILD_NUMBER}"
        echo "Branch: ${BRANCH_NAME}"
        
        // Interactive debugging (development only)
        // input message: 'Paused for debugging'
    }
}
```

### Replay and Restart

- Use "Replay" to modify pipeline and rerun without commit
- Use "Restart from Stage" to resume from specific stage
- Use Blue Ocean for visual pipeline editing
