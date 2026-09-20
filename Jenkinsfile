pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
        timeout(time: 25, unit: 'MINUTES')
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
                    maven '-DskipUnitTests=true -DskipITs=true -DskipATs=true compile'
                }
            }
        }

        stage('Tests') {
            steps {
                script {
                    maven 'test -DskipITs=true -DskipATs=true'
                    maven "verify -DskipUnitTests=true -DskipATs=true -Dheadless=${env.HEADLESS}"
                }
            }
            post {
                always {
                    junit allowEmptyResults: false,
                          testResults: 'target/surefire-reports/*.xml,target/failsafe-reports/*.xml'
                    archiveArtifacts artifacts: 'target/surefire-reports/**,target/failsafe-reports/**',
                                    allowEmptyArchive: true
                }
            }
        }

        stage('Acceptance') {
            steps {
                script {
                    maven "verify -DskipUnitTests=true -DskipITs=true -Dheadless=${env.HEADLESS}"
                }
            }
            post {
                always {
                    junit allowEmptyResults: false,
                          testResults: 'target/failsafe-reports-at/*.xml'
                    archiveArtifacts artifacts: 'target/failsafe-reports-at/**',
                                    allowEmptyArchive: true
                }
            }
        }

        stage('Despliegue ambiente de prueba') {
            steps {
                script {
                    maven '-DskipUnitTests=true -DskipITs=true -DskipATs=true package'
                    if (isUnix()) {
                        sh 'chmod +x scripts/desplegar-ambiente-prueba.sh && ./scripts/desplegar-ambiente-prueba.sh'
                    } else {
                        bat 'powershell -ExecutionPolicy Bypass -File scripts\\desplegar-ambiente-prueba.ps1'
                    }
                }
            }
            post {
                success {
                    archiveArtifacts artifacts: 'ambiente-prueba/**',
                                    allowEmptyArchive: false
                }
            }
        }
    }

    post {
        success {
            echo 'Tests, acceptance y despliegue en ambiente de prueba OK.'
        }
        failure {
            echo 'El pipeline falló. No se despliega si tests o acceptance fallan.'
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
