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
          sh 'apt-get update'
          sh 'DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install \
                curl
                ca-certificates'
          sh 'curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose'
          sh 'docker-compose build ffmpeg-1'
        }
      }
    }
  }
}
