pipeline {
  agent {
    kubernetes {
      containerTemplate {
        name 'ubuntu-live-demo-cmaf'
        image 'ubuntu:18.04'
        command 'sleep'
        args 'infinity'
      }
    }
  }
  stages {
    stage("docker-compose build ffmpeg") {
      steps {
        container('ubuntu-live-demo-cmaf') {
          sh 'apt-get update'
          sh 'DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install \
                apt-transport-https \
                ca-certificates \
                curl \
                gnupg-agent \
                software-properties-common'
          sh 'curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -'
          sh 'curl -sSL https://get.docker.com/ | sh'
          sh 'apt-get update'
          //sh 'DEBIAN_FRONTEND=noninteractive apt-get -y --allow-downgrades --no-install-recommends install \
          //    docker-ce=5:19.03.9~3-0~ubuntu-focal \
          //    docker-ce-cli=5:19.03.9~3-0~ubuntu-focal \
          //    containerd.io'
          //sh 'export DOCKER_HOST=127.0.0.1'
          sh 'usermod -aG docker root'
          //sh 'service docker start'
          //sh 'docker -D info'
          sh 'curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose'
          sh 'chmod +x /usr/local/bin/docker-compose'
          sh '/usr/local/bin/docker-compose build ffmpeg-1'
        }
      }
    }
  }
}
