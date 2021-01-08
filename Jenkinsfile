pipeline {
  agent {
    kubernetes {
      containerTemplate {
        name 'ubuntu'
        image 'ubuntu:20.04'
        command 'sleep'
        args 'infinity'
      }
    }
  }
  stages {
    stage("docker-compose build ffmpeg") {
      steps {
        container('ubuntu') {
          sh "docker-compose build ffmpeg-1"
        }
      }
    }
  }
}
