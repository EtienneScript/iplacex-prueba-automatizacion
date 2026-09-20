pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
        timeout(time: 20, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    tools {
        jdk 'JDK17'
    }

    environment {
        HEADLESS = 'true'
        MAVEN_OPTS = '-Dhttps.protocols=TLSv1.2'
    }

    stages {
        stage('Build') {
            steps {
                script {
                    maven '-DskipTests compile'
                }
            }
        }

        stage('Test') {
            steps {
                script {
                    maven "test -Dheadless=${env.HEADLESS}"
                }
            }
            post {
                always {
                    junit allowEmptyResults: false,
                          testResults: 'target/surefire-reports/*.xml'
                    archiveArtifacts artifacts: 'target/surefire-reports/**',
                                    allowEmptyArchive: true
                }
            }
        }
    }

    post {
        success {
            echo 'Build y pruebas automatizadas OK.'
        }
        failure {
            echo 'El pipeline falló. Revisa el stage Build o Test.'
        }
        cleanup {
            deleteDir()
        }
    }
}

void maven(String args) {
    if (isUnix()) {
        sh "./mvnw -B ${args}"
    } else {
        bat ".\\mvnw.cmd -B ${args}"
    }
}
