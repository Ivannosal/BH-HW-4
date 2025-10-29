pipeline {
    agent any

    parameters {
        string(
            name: 'REPO_URL',
            defaultValue: 'https://github.com/Ivannosal/BH-HW-4',
            description: 'Git repository URL'
        )
        string(
            name: 'BRANCH',
            defaultValue: 'main',
            description: 'Branch to monitor'
        )
        credentials(
            name: 'GIT_CREDENTIALS',
            description: 'Git credentials for private repositories',
            credentialType: 'com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl',
            required: false
        )
    }

    triggers {
        // Poll SCM every 10 minutes
        pollSCM('H/10 * * * *')
    }

    options {
        timeout(time: 30, unit: 'MINUTES')
        disableConcurrentBuilds()
    }

    stages {
        stage('Checkout Script') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/your-org/ci-scripts.git',
                    credentialsId: 'GIT_CREDENTIALS'
            }
        }

        stage('Validate Environment') {
            steps {
                script {
                    // Check if required tools are available
                    sh '''
                        which git || echo "Git not found"
                        git --version
                    '''
                }
            }
        }

        stage('Execute Tag Automation') {
            steps {
                script {
                    withCredentials([usernamePassword(
                        credentialsId: params.GIT_CREDENTIALS ?: 'none',
                        usernameVariable: 'GIT_USERNAME',
                        passwordVariable: 'GIT_PASSWORD'
                    )]) {
                        // Run the tag increment script with parameters
                        sh """
                            chmod +x git_tag_increment.sh
                            ./git_tag_increment.sh \
                                --url "${params.REPO_URL}" \
                                --branch "${params.BRANCH}" \
                                --username "\${GIT_USERNAME}" \
                                --password "\${GIT_PASSWORD}"
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            publishHTML([
                allowMissing: false,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: '',
                reportFiles: 'tag_report.html',
                reportName: 'Tag Automation Report'
            ])

            // Archive any created artifacts
            archiveArtifacts artifacts: '*.log,*.txt', fingerprint: true
        }
        success {
            script {
                echo "Build ${env.BUILD_NUMBER} completed successfully"
                // Update deployment dashboard or send success notification
            }
        }
        failure {
            script {
                echo "Build ${env.BUILD_NUMBER} failed"
                // Send alert to team
            }
        }
    }
}