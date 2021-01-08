pipeline {
  agent any
  stages {
    stage("Docker Build") {
      agent {
        dockerfile {
          filename "ffmpeg/Dockerfile"
        }
      }

      steps {
        sh "cd back-end && bin/ci"
      }
    }
  }
}
