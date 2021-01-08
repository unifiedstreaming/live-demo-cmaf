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
    stage("docker run hello world") {
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
          sh 'curl -sSL https://get.docker.com/ | sh'
          sh 'usermod -aG docker root'
          sh 'nohup dockerd >/dev/null 2>&1 & sleep 10 && docker run --privileged -it -v /var/run/docker.sock:/var/run/docker.sock hello-world'
        }
      }
    }
  }
}
