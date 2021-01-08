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
                apt-transport-https \
                ca-certificates \
                curl \
                gnupg-agent \
                software-properties-common'
          sh 'curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -'
          sh 'DEBIAN_FRONTEND=noninteractive add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"'
          sh 'apt-get update'
          sh 'DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install \
              docker-ce \
              docker-ce-cli \
              containerd.io'
          sh 'curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose'
          sh 'chmod +x /usr/local/bin/docker-compose'
          sh '/usr/local/bin/docker-compose build ffmpeg-1'
        }
      }
    }
  }
}
