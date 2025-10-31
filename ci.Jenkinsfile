pipeline {
    agent any

    triggers {
        pollSCM('H/5 * * * *')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm: [
                    $class: 'GitSCM',
                    branches: [[name: 'master']],
                    userRemoteConfigs: [[
                        url: 'git@github.com:Ivannosal/BH-HW-4.git',
                        credentialsId: 'J'
                    ]]
                ]
            }
        }

        stage('Find and Run Script') {
            steps {
                script {
                    def scriptFile = findFiles(glob: '**/version-updater.sh')[0]
                    if (!scriptFile) {
                        error "version-updater.sh not found"
                    }

                    dir(scriptFile.path) {
                        sh """
                            chmod +x version-updater.sh
                            ./version-updater.sh
                        """
                    }
                }
            }
        }

        stage('Push Updates') {
            steps {
                sh '''
                    git add . || true
                    git diff --staged --quiet || (
                        git config user.name "Jenkins"
                        git config user.email "jenkins@ci.com"
                        git commit -m "Auto-update versions"
                        git push origin main
                    )
                '''
            }
        }
    }
}