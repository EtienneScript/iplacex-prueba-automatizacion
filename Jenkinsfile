pipeline {
    agent any

    parameters {
        choice(name: 'ACCION', choices: ['desplegar', 'rollback'],
               description: 'desplegar = Blue-Green; rollback = volver al slot anterior')
    }

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
            when { expression { params.ACCION != 'rollback' } }
            steps {
                script {
                    maven '-DskipUnitTests=true -DskipITs=true -DskipATs=true compile'
                }
            }
        }

        stage('Tests') {
            when { expression { params.ACCION != 'rollback' } }
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
            when { expression { params.ACCION != 'rollback' } }
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
            when { expression { params.ACCION != 'rollback' } }
            steps {
                script {
                    maven '-DskipUnitTests=true -DskipITs=true -DskipATs=true package'
                    desplegarBlueGreen()
                    desplegarBlueGreen()
                }
            }
            post {
                success {
                    archiveArtifacts artifacts: 'ambiente-prueba/**',
                                    allowEmptyArchive: false
                }
            }
        }

        stage('Rollback') {
            when { expression { params.ACCION == 'rollback' } }
            steps {
                script {
                    copyArtifacts projectName: env.JOB_NAME,
                                  selector: lastSuccessful(),
                                  filter: 'ambiente-prueba/**',
                                  optional: false
                    if (isUnix()) {
                        sh 'chmod +x scripts/rollback-ambiente-prueba.sh && ./scripts/rollback-ambiente-prueba.sh'
                    } else {
                        bat 'powershell -ExecutionPolicy Bypass -File scripts\\rollback-ambiente-prueba.ps1'
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

void desplegarBlueGreen() {
    if (isUnix()) {
        sh 'chmod +x scripts/desplegar-ambiente-prueba.sh && ./scripts/desplegar-ambiente-prueba.sh'
    } else {
        bat 'powershell -ExecutionPolicy Bypass -File scripts\\desplegar-ambiente-prueba.ps1'
    }
}
