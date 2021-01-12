// Uses Declarative syntax to run commands inside a container.
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
            }
        }
    }
    environment {
        KUBECONFIG = credentials('kubeconfig')
        REGISTRY_TOKEN = credentials('gitlab-registry-operations')
        REGISTRY_URL = 'registry.internal.unified-streaming.com'
        DOCKER_REPO = 'registry.internal.unified-streaming.com/operations/demo/live-demo-cmaf'
        GIT_COMMIT = sh(returnStdout: true, script: 'git rev-parse HEAD').trim()
        CHART_REPO = 'http://admin:admin@chartmuseum-chartmuseum.chartmuseum.svc.k8s.unified-streaming.com:8080'
    }
    options {
        quietPeriod(300)
    }
    stages {
        stage('build') {
            steps {
                container('kaniko') {
                    sh 'echo "{\\"auths\\":{\\"$REGISTRY_URL\\":{\\"username\\":\\"$REGISTRY_TOKEN_USR\\",\\"password\\":\\"$REGISTRY_TOKEN_PSW\\"}}}" > /kaniko/.docker/config.json'
                    sh '''
                        /kaniko/executor \
                            -f `pwd`/ffmpeg/Dockerfile \
                            --destination $DOCKER_REPO/$BRANCH_NAME:latest
                    '''
                }
            }
        }
}
