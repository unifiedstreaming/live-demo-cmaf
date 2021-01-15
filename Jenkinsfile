pipeline {
    agent {
        kubernetes {
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
    environment {
        KUBECONFIG = credentials('kubeconfig')
        GL_REGISTRY_TOKEN = credentials('gitlab-registry-operations')
        GL_REGISTRY_URL = 'registry.internal.unified-streaming.com'
        GL_DOCKER_REPO = 'registry.internal.unified-streaming.com/operations/demo/live-demo-cmaf'
        DH_REGISTRY_TOKEN = credentials('docker-hub')
        DH_REGISTRY_URL = 'registry.hub.docker.com'
        DH_DOCKER_REPO = 'registry.hub.docker.com/unifiedstreaming/live'
        RELEASE_NAME = sh(returnStdout: true, script: 'echo -n live-demo-cmaf-${BRANCH_NAME}')
        GIT_COMMIT = sh(returnStdout: true, script: 'git rev-parse HEAD').trim()
        USP_LICENSE_KEY = credentials('development-license.key')
        VERSION = '1.10.28'
        CHANNEL = 'cmaf'
        // Channel & version need to also be set in values.yaml
    }
    stages {
        stage('build') {
            steps {
                container('kaniko') {
                    sh '''
                    echo "{
                            \\"auths\\":
                            {
                                \\"$GL_REGISTRY_URL\\":
                                {
                                    \\"username\\":\\"$GL_REGISTRY_TOKEN_USR\\",
                                    \\"password\\":\\"$GL_REGISTRY_TOKEN_PSW\\"
                                 },
                                \\"$DH_REGISTRY_URL\\":
                                {
                                    \\"username\\":\\"$DH_REGISTRY_TOKEN_USR\\",
                                    \\"password\\":\\"$DH_REGISTRY_TOKEN_PSW\\"
                                }
                                }
                            }" > /kaniko/.docker/config.json
                        '''
                    sh '''
                        cd `pwd`/ffmpeg && \
                        /kaniko/executor \
                            -f `pwd`/Dockerfile \
                            -c `pwd` \
                            --cache=true \
                            --cache-repo=$GL_DOCKER_REPO/cache \
                            --destination $GL_DOCKER_REPO/$BRANCH_NAME:$VERSION \
                    '''
                }
            }
        }
        stage('deploy') {
            steps {
                container('helm') {
                    sh '''
                        helm --kubeconfig $KUBECONFIG \
                            upgrade \
                            --install \
                            --wait \
                            --timeout 300s \
                            --namespace $RELEASE_NAME \
                            --create-namespace \
                            --set licenseKey=$USP_LICENSE_KEY \
                            --set originPullSecret.username=$DH_REGISTRY_TOKEN_USR \
                            --set originPullSecret.password=$DH_REGISTRY_TOKEN_PSW \
                            --set originPullSecret.secretName=docker-hub \
                            --set originImage.repository=$DH_DOCKER_REPO/$BRANCH_NAME \
                            --set originImage.tag=$VERSION \
                            --set ffmpegPullSecret.username=$GL_REGISTRY_TOKEN_USR \
                            --set ffmpegPullSecret.password=$GL_REGISTRY_TOKEN_PSW \
                            --set ffmpegPullSecret.secretName=gitlab-reg-secret \
                            --set ffmpegPullSecret.registryURL=$GL_REGISTRY_URL \
                            --set ffmpegImage.repository=$GL_DOCKER_REPO/$BRANCH_NAME \
                            --set ffmpegImage.tag=$VERSION \
                            --set environment=$BRANCH_NAME \
                            $RELEASE_NAME \
                            ./chart
                    '''
                }
            }
        }
        stage('test') {
            steps {
                sh 'sleep 10; curl --silent --fail --show-error http://$RELEASE_NAME.$RELEASE_NAME.svc.k8s.unified-streaming.com/$CHANNEL/$CHANNEL.isml/.mpd'
            }
        }
        /* 
        stage('publish chart') {
            steps {
                container('helm') {
                    sh '''
                        VERSION=`grep "^version:.*$" chart/Chart.yaml | awk '{print $2}'`-$GIT_COMMIT
                        helm --kubeconfig $KUBECONFIG \
                            push \
                            --version $VERSION \
                            ./chart \
                            $CHART_REPO
                    '''
                }
            }
        }
        */
    }
}
