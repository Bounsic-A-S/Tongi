pipeline {
    agent any

    options {
        timestamps()
    }

    triggers {
        githubPush()
    }

    stages {
        stage('Prepare') {
            steps {
                echo '🔧 Initializing main pipeline...'
                sh 'ls -l'
            }
        }

        stage('Detect and Run Subprojects') {
            steps {
                script {
                    // Obtener subdirectorios
                    def dirs = sh(script: "find . -maxdepth 2 -type d", returnStdout: true).trim().split("\n")
                    def jobs = [:]

                    for (dirPath in dirs) {
                        // Ignorar el directorio raíz
                        if (dirPath == "." || dirPath == "./frontend" || dirPath == "./backend" || dirPath.startsWith("./.git")) {
                            continue
                        }

                        def folder = dirPath.replace("./", "")
                        def jenkinsfileExists = fileExists("${folder}/Jenkinsfile")

                        if (jenkinsfileExists) {
                            // Cada subproyecto con Jenkinsfile se ejecuta como job paralelo
                            jobs[folder] = {
                                dir(folder) {
                                    echo "🚀 Running Jenkinsfile in ${folder}"
                                    load 'Jenkinsfile'
                                }
                            }
                        } else {
                            // Si no hay Jenkinsfile, solo listar archivos
                            jobs[folder] = {
                                dir(folder) {
                                    echo "📂 No Jenkinsfile in ${folder}, listing contents..."
                                    sh 'ls -l'
                                }
                            }
                        }
                    }

                    parallel jobs
                }
            }
        }
    }

    post {
        success {
            echo '✅ All subprojects completed successfully!'
            jiraSendBuildInfo()
        }
        failure {
            echo '❌ One or more subprojects failed.'
            jiraSendBuildInfo()
        }
    }
}
