pipeline {
    agent { label 'AGENT-1' }
    environment { 
        PROJECT = 'expense'
        COMPONENT = 'backend'
        appVersion = ''
        ACC_ID = '315069654700'
        //GITHUB_TOKEN = credentials('github-token') // store in Jenkins credentials
    }
    options {
        disableConcurrentBuilds()
        timeout(time: 30, unit: 'MINUTES')
    }
    parameters{
        booleanParam(name: 'deploy', defaultValue: false, description: 'Toggle this value')
    }
    stages {
        /* stage('Check for Critical Vulnerabilities') {
    environment {
        GITHUB_TOKEN = credentials('github-token') // Use Jenkins credentials store
    }
    steps {
        sh '''
        echo "$GITHUB_TOKEN" | gh auth login --with-token

        gh api graphql -f query='
          query {
  repository(owner: "joindevops-1", name: "backend3") {
    vulnerabilityAlerts(first: 100) {
      nodes {
        securityVulnerability {
          severity
          package {
            name
          }
        }
      }
    }
  }
}
' > vuln_output.json

        critical_count=$(jq '[.data.repository.vulnerabilityAlerts.nodes[] | select(.securityVulnerability.severity == "CRITICAL")] | length')

        echo "Found $critical_count critical vulnerabilities"

        if [ "$critical_count" -gt 0 ]; then
            echo "❌ Critical vulnerabilities found! Failing the build."
            exit 1
        else
            echo "✅ No critical vulnerabilities found."
        fi
        '''
    }
} */

        stage('Read Version') {
            steps {
               script{
                 def packageJson = readJSON file: 'package.json'
                 appVersion = packageJson.version
                 echo "Version is: $appVersion"
               }
            }
        }
        stage('Install Dependencies') {
            steps {
               script{ 
                 sh """
                    npm install
                 """
               }
            }
        }
        /* stage('Run Sonarqube') {
            environment {
                scannerHome = tool 'sonar-scanner-7.1';
            }
            steps {
              withSonarQubeEnv('sonar-scanner-7.1') {
                sh "${scannerHome}/bin/sonar-scanner"
                // This is generic command works for any language
              }
            }
        }
        stage("Quality Gate") {
            steps {
              timeout(time: 1, unit: 'HOURS') {
                waitForQualityGate abortPipeline: true
              }
            }
        } */
        stage('Snyk Test') {
           steps {
               script {
                   // Run Snyk test
                   /* withCredentials([string(credentialsId: 'synk-token1', variable: 'SNYK_TOKEN')]) {
                       sh 'snyk test --token=$SNYK_TOKEN'
                   } */
                   withEnv(["PATH+SNYK=${tool 'synk'}/bin"]) {
                    sh 'snyk test --all-projects --severity-threshold=medium'
                    }
               }
           }
       }
        stage('Docker Build') {
            steps {
               script{
                withAWS(region: 'us-east-1', credentials: 'aws-creds') {
                    sh """
                    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${ACC_ID}.dkr.ecr.us-east-1.amazonaws.com

                    docker build -t  ${ACC_ID}.dkr.ecr.us-east-1.amazonaws.com/${project}/${component}:${appVersion} .

                    docker push ${ACC_ID}.dkr.ecr.us-east-1.amazonaws.com/${project}/${component}:${appVersion}
                    """
                }
                 
               }
            }
        }
        stage('Trigger Deploy'){
            when { 
                expression { params.deploy }
            }
            steps{
                build job: 'backend-cd', parameters: [string(name: 'version', value: "${appVersion}")], wait: true
            }
        }
    }
    post { 
        always { 
            echo 'I will always say Hello again!'
            deleteDir()
        }
        failure { 
            echo 'I will run when pipeline is failed'
        }
        success { 
            echo 'I will run when pipeline is success'
        }
    }
}