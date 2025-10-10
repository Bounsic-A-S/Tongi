pipeline {
    agent any

    options {
        timestamps()
    }

    triggers {
        githubPush() // Se ejecuta automáticamente cuando haces push a main
    }

    stages {
        stage('Prepare') {
            steps {
                ansiColor('xterm') {
                    echo '🔧 Initializing main pipeline...'
                    sh 'ls -l'
                }
            }
        }

        stage('Run Subprojects') {
            steps {
                script {
                    // Definimos los pipelines paralelos
                    def jobs = [:]

                    jobs['Frontend'] = {
                        dir('frontend') {
                            ansiColor('xterm') {
                                echo '🚀 Running Frontend Pipeline...'
                                sh 'jenkinsfile-runner -f Jenkinsfile'
                            }
                        }
                    }

                    jobs['Backend'] = {
                        dir('backend') {
                            ansiColor('xterm') {
                                echo '🧱 Running Backend Pipeline (Pistache)...'
                                sh 'jenkinsfile-runner -f Jenkinsfile'
                            }
                        }
                    }

                    jobs['Server stt'] = {
                        dir('servers/stt_server') {
                            ansiColor('xterm') {
                                echo '⚙️ Running Server 1 pipeline...'
                                sh 'jenkinsfile-runner -f Jenkinsfile'
                            }
                        }
                    }

                    jobs['Server tts'] = {
                        dir('servers/tts_server') {
                            ansiColor('xterm') {
                                echo '⚙️ Running Server 2 pipeline...'
                                sh 'jenkinsfile-runner -f Jenkinsfile'
                            }
                        }
                    }

                    jobs['Server ttt'] = {
                        dir('servers/ttt_server') {
                            ansiColor('xterm') {
                                echo '⚙️ Running Server 3 pipeline...'
                                sh 'jenkinsfile-runner -f Jenkinsfile'
                            }
                        }
                    }

                    // Ejecutamos todos los jobs en paralelo
                    parallel jobs
                }
            }
        }
    }

    post {
        success {
            script {
                ansiColor('xterm') {
                    echo '✅ All pipelines completed successfully!'
                    jiraSendBuildInfo()
                }
            }
        }
        failure {
            script {
                ansiColor('xterm') {
                    echo '❌ One or more pipelines failed.'
                    jiraSendBuildInfo()
                }
            }
        }
    }
}
