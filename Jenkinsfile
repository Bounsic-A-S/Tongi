pipeline {
    agent any

    options {
        timestamps()
        ansiColor('xterm')
    }

    triggers {
        githubPush() // se ejecuta automáticamente cuando haces push a main
    }

    stages {
        stage('Prepare') {
            steps {
                echo '🔧 Initializing main pipeline...'
                sh 'ls -l'
            }
        }

        stage('Run Subprojects') {
            parallel {
                stage('Frontend') {
                    steps {
                        dir('frontend') {
                            echo '🚀 Running Frontend Pipeline...'
                            sh 'jenkinsfile-runner -f Jenkinsfile' // o simplemente ejecutar el Jenkinsfile si ya está integrado
                        }
                    }
                }

                stage('Backend') {
                    steps {
                        dir('backend') {
                            echo '🧱 Running Backend Pipeline (Pistache)...'
                            sh 'jenkinsfile-runner -f Jenkinsfile'
                        }
                    }
                }

                stage('Servers') {
                    parallel {
                        stage('Server stt') {
                            steps {
                                dir('servers/stt_server') {
                                    echo '⚙️ Running Server 1 pipeline...'
                                    sh 'jenkinsfile-runner -f Jenkinsfile'
                                }
                            }
                        }
                        stage('Server tts') {
                            steps {
                                dir('servers/tts_server') {
                                    echo '⚙️ Running Server 2 pipeline...'
                                    sh 'jenkinsfile-runner -f Jenkinsfile'
                                }
                            }
                        }
                        stage('Server ttt') {
                            steps {
                                dir('servers/ttt_server') {
                                    echo '⚙️ Running Server 3 pipeline...'
                                    sh 'jenkinsfile-runner -f Jenkinsfile'
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            echo '✅ All pipelines completed successfully!'
        }
        failure {
            echo '❌ One or more pipelines failed.'
        }
    }
}
