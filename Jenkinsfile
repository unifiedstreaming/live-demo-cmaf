pipeline {
    agent {
        kubernetes {
            // Rather than inline YAML, in a multibranch Pipeline you could use: yamlFile 'jenkins-pod.yaml'
            // Or, to avoid YAML:
            // containerTemplate {
            //     name 'shell'
            //     image 'ubuntu'
            //     command 'sleep'
            //     args 'infinity'
            // }
            yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    entrypoint:
    - ""
    command:
    - sleep
    args:
    - infinity
  - name: helm
    image: registry.internal.unified-streaming.com/operations/kubernetes/helm-kubectl/trunk:latest
    command:
    - sleep
    args:
    - infinity
  imagePullSecrets:
  - name: gitlab-registry
'''
            // Can also wrap individual steps:
            // container('shell') {
            //     sh 'hostname'
            // }
        }
    }
    environment {
        KUBECONFIG = credentials('kubeconfig')
        REGISTRY_TOKEN = credentials('gitlab-registry-operations')
        REGISTRY_URL = 'registry.internal.unified-streaming.com'
        DOCKER_REPO = 'registry.internal.unified-streaming.com/operations/demo/live-demo-cmaf'
    }
    stages {
        stage('build') {
            steps {
                container('kaniko') {
                    sh 'echo "{\\"auths\\":{\\"$REGISTRY_URL\\":{\\"username\\":\\"$REGISTRY_TOKEN_USR\\",\\"password\\":\\"$REGISTRY_TOKEN_PSW\\"}}}" > /kaniko/.docker/config.json'
                    sh '''
                        /kaniko/executor \
                            -f `pwd`/Dockerfile \
                            -c `pwd` \
                            --cache=true \
                            --cache-repo=$DOCKER_REPO/cache \
                            --destination $DOCKER_REPO/$BRANCH_NAME:latest
                    '''
                }
            }
        }

}
}
