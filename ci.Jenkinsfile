pipeline {
    agent any

    // Disable automatic SCM checkout
    options {
        skipDefaultCheckout true
    }

    triggers {
        pollSCM('H/5 * * * *')
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    echo "🔄 Manual checkout from repository"
                    checkout([
                        $class: 'GitSCM',
                        branches: [[name: "*/master"]],
                        extensions: [[$class: 'CloneOption', depth: 1, shallow: true]],
                        userRemoteConfigs: [[
                            url: 'git@github.com:Ivannosal/BH-HW-4.git',
                            credentialsId: 'J'
                        ]]
                    ])

                    def gitCommit = sh(
                        script: 'git log -1 --oneline',
                        returnStdout: true
                    ).trim()
                    echo "📝 Last commit: ${gitCommit}"
                }
            }
        }

        stage('Find version-updater.sh') {
            steps {
                script {
                    echo "🔍 Searching for version-updater.sh..."
                    def foundFiles = findFiles(glob: '**/version-updater.sh')

                    if (foundFiles.length > 0) {
                        echo "✅ version-updater.sh found:"
                        foundFiles.each { file ->
                            echo " - ${file.path}"
                            env.SCRIPT_PATH = file.path
                        }
                    } else {
                        echo "❌ version-updater.sh not found"
                        sh 'find . -type f -name "*.sh" || echo "No shell scripts found"'
                        error "version-updater.sh not found!"
                    }
                }
            }
        }

        stage('Execute Script') {
            steps {
                script {
                    echo "🚀 Running version-updater.sh..."
                    sh "chmod +x '${env.SCRIPT_PATH}' && './${env.SCRIPT_PATH}'"
                }
            }
        }

        stage('Commit Changes') {
            when {
                expression {
                    def changes = sh(script: 'git status --porcelain', returnStdout: true).trim()
                    return changes != ''
                }
            }
            steps {
                script {
                    echo "💾 Committing changes..."
                    sh '''
                        git config user.name "Jenkins"
                        git config user.email "jenkins@ci.com"
                        git add .
                        git commit -m "Auto-update versions by Jenkins"
                        git push origin master
                    '''
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline execution completed"
        }
    }
}