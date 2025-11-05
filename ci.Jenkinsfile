pipeline {
    agent any

    triggers {
        pollSCM('* * * * *') // Check every minute
    }

    environment {
        GIT_REPO = 'git@github.com:Ivannosal/BH-HW-4.git'
        SSH_CREDENTIALS_ID = 'J'
    }

    stages {
        stage('Clone Repository') {
            steps {
                script {
                    echo "Cloning repository ${env.GIT_REPO}"
                    checkout([
                        $class: 'GitSCM',
                        branches: [[name: '*/master']],
                        extensions: [],
                        userRemoteConfigs: [[
                            credentialsId: env.SSH_CREDENTIALS_ID,
                            url: env.GIT_REPO
                        ]]
                    ])
                }
            }
        }

        stage('Check Tags and Commits') {
            steps {
                script {
                    // Get information about the latest tag
                    def gitDescribe = sh(
                        script: 'git describe --tags --always 2>/dev/null || echo "no-tags"',
                        returnStdout: true
                    ).trim()

                    echo "Git describe result: ${gitDescribe}"

                    // Check if there are new commits after the last tag
                    if (gitDescribe == "no-tags") {
                        echo "No tags found in repository"
                        currentBuild.result = 'SUCCESS'
                        return
                    }

                    if (gitDescribe.contains('-')) {
                        echo "New commits detected after the last tag"

                        // Get the last tag
                        def lastTag = sh(
                            script: 'git describe --tags --abbrev=0',
                            returnStdout: true
                        ).trim()

                        echo "Last tag: ${lastTag}"

                        // Increase patch version
                        def versionParts = lastTag.tokenize('.')
                        if (versionParts.size() >= 3) {
                            def major = versionParts[0]
                            def minor = versionParts[1]
                            def patch = versionParts[2].toInteger() + 1
                            def newTag = "${major}.${minor}.${patch}"

                            echo "New tag: ${newTag}"

                            // Create annotated tag
                            sh "git tag -a ${newTag} -m 'Jenkins auto-tag: ${newTag}'"

                            // Push tag to remote repository
                            withCredentials([sshUserPrivateKey(
                                credentialsId: env.SSH_CREDENTIALS_ID,
                                keyFileVariable: 'SSH_KEY'
                            )]) {
                                sh """
                                    eval `ssh-agent -s`
                                    ssh-add ${SSH_KEY}
                                    git push origin ${newTag}
                                    ssh-agent -k
                                """
                            }

                            echo "Tag ${newTag} successfully created and pushed"
                        } else {
                            error "Invalid tag format: ${lastTag}. Expected format: X.Y.Z"
                        }
                    } else {
                        echo "No changes - latest tag points to the most recent commit"
                    }
                }
            }
        }

        stage('Cleanup') {
            steps {
                script {
                    // Remove local repository copy
                    deleteDir()
                    echo "Local repository copy deleted"
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully"
        }

        failure {
            echo "Pipeline failed"
        }
    }
}