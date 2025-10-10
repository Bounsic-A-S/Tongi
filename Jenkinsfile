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
                echo '🔧 Initializing main pipeline...'
                sh 'ls -l'
            }
        }

        stage('Run Subprojects') {
            steps {
                script {
                    // Definimos los pipelines paralelos
                    def jobs = [:]

                    jobs['Frontend'] = {
                        dir('frontend') {
                            echo '🚀 Running Frontend Pipeline...'
                            sh 'jenkinsfile-runner -f Jenkinsfile'
                        }
                    }

                    jobs['Backend'] = {
                        dir('backend') {
                            echo '🧱 Running Backend Pipeline (Pistache)...'
                            sh 'jenkinsfile-runner -f Jenkinsfile'
                        }
                    }

                    jobs['Server stt'] = {
                        dir('servers/stt_server') {
                            echo '⚙️ Running Server 1 pipeline...'
                            sh 'jenkinsfile-runner -f Jenkinsfile'
                        }
                    }

                    jobs['Server tts'] = {
                        dir('servers/tts_server') {
                            echo '⚙️ Running Server 2 pipeline...'
                            sh 'jenkinsfile-runner -f Jenkinsfile'
                        }
                    }

                    jobs['Server ttt'] = {
                        dir('servers/ttt_server') {
                            echo '⚙️ Running Server 3 pipeline...'
                            sh 'jenkinsfile-runner -f Jenkinsfile'
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
            echo '✅ All pipelines completed successfully!'
            jiraSendBuildInfo()
        }
        failure {
            echo '❌ One or more pipelines failed.'
            jiraSendBuildInfo()
        }
    }
}
