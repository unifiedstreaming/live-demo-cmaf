pipeline {
    agent {
      dockerfile {
        dir "ffmpeg" 
        }
      }
    stages {
        stage('Test') {
            steps {
                sh 'ffmpeg --version'
            }
        }
    }
}
