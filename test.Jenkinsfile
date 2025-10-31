pipeline {
    agent any
    options {
        timestamps()
    }

    stages {
        stage('Test Git SSH') {
            steps {
                script {
                    // Минимальная проверка SSH
                    sh 'ssh -o BatchMode=yes -o ConnectTimeout=10 -T git@github.com 2>&1 | grep -v "authenticated" || true'

                    // Тихая проверка git (ошибки только при реальных проблемах)
                    sh '''
                        git ls-remote git@github.com:Ivannosal/BH-HW-4.git HEAD > /dev/null 2>&1
                        echo "Git SSH connection: OK"
                    '''
                }
            }
        }
    }
}