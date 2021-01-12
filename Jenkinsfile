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
        DOCKER_REPO = 'registry.internal.unified-streaming.com/operations/demo/vod2live'
        GIT_COMMIT = sh(returnStdout: true, script: 'git rev-parse HEAD').trim()
        RELEASE_NAME = sh(returnStdout: true, script: 'echo -n vod2live-${BRANCH_NAME}')
        CHART_REPO = 'http://admin:admin@chartmuseum-chartmuseum.chartmuseum.svc.k8s.unified-streaming.com:8080'
        USP_LICENSE_KEY = credentials('development-license.key')
        LAST_STABLE_SVN = sh(returnStdout:true, script: '''
            curl --silent "http://build.unified-streaming.com/job/deploy-master/lastStableBuild/injectedEnvVars/export/" | \
            grep "SVN_REVISION_SOURCE" | \
            awk -F "=" '{print $2}'
        ''').trim()
        REMOTE_STORAGE_URL = "http://s3.internal.unified-streaming.com"
        S3_ACCESS_KEY = "IB3FLXSZRP0HSRE98CHP"
        S3_SECRET_KEY = "oLvKYP9MRcG4KOHE6TEZYZEWPONIpaHKpC6xre2x"
        S3_REGION = "default"
    }
    options {
        quietPeriod(300)
    }
    parameters {
        string(name: 'SVN_COMMIT', defaultValue: '', description: 'SVN commit ID to build')
    }
    triggers {
        GenericTrigger(
            genericRequestVariables: [
                [key: 'SVN_COMMIT', regexpFilter: ''],
            ],
            token: 'mp4split',
            causeString: 'Triggered by webhook with SVN_COMMIT: $SVN_COMMIT',
            printContributedVariables: true,
            printPostContent: true,
            silentResponse: false
        )
    }
    stages {
        stage('build') {
            steps {
                container('kaniko') {
                    sh 'echo "{\\"auths\\":{\\"$REGISTRY_URL\\":{\\"username\\":\\"$REGISTRY_TOKEN_USR\\",\\"password\\":\\"$REGISTRY_TOKEN_PSW\\"}}}" > /kaniko/.docker/config.json'
                    sh '''
                        export COMMIT=${SVN_COMMIT:-$LAST_STABLE_SVN}
                        /kaniko/executor \
                            -f `pwd`/Dockerfile \
                            -c `pwd` \
                            --cache=true \
                            --cache-repo=$DOCKER_REPO/cache \
                            --build-arg REPO=http://artifact.internal.unified-streaming.com/${COMMIT}/artifact/apk/alpine/v3.11 \
                            --destination $DOCKER_REPO/$BRANCH_NAME:$COMMIT-$GIT_COMMIT \
                            --destination $DOCKER_REPO/$BRANCH_NAME:$GIT_COMMIT \
                            --destination $DOCKER_REPO/$BRANCH_NAME:$COMMIT \
                            --destination $DOCKER_REPO/$BRANCH_NAME:latest
                    '''
                }
            }
        }
        stage('deploy') {
            steps {
                container('helm') {
                    sh '''
                        export COMMIT=${SVN_COMMIT:-$LAST_STABLE_SVN}
                        helm --kubeconfig $KUBECONFIG \
                            upgrade \
                            --install \
                            --wait \
                            --timeout 300s \
                            --namespace $RELEASE_NAME \
                            --create-namespace \
                            --set licenseKey=$USP_LICENSE_KEY \
                            --set imagePullSecret.username=$REGISTRY_TOKEN_USR \
                            --set imagePullSecret.password=$REGISTRY_TOKEN_PSW \
                            --set imagePullSecret.secretName=gitlab-reg-secret \
                            --set imagePullSecret.registryURL=$REGISTRY_URL \
                            --set image.repository=$DOCKER_REPO/$BRANCH_NAME \
                            --set image.tag=$COMMIT-$GIT_COMMIT \
                            --set environment=$BRANCH_NAME \
                            --set env[0].name=REMOTE_STORAGE_URL \
                            --set env[0].value=$REMOTE_STORAGE_URL \
                            --set env[1].name=S3_ACCESS_KEY \
                            --set env[1].value=$S3_ACCESS_KEY \
                            --set env[2].name=S3_SECRET_KEY \
                            --set env[2].value=$S3_SECRET_KEY \
                            --set env[3].name=S3_REGION \
                            --set env[3].value=$S3_REGION \
                            $RELEASE_NAME \
                            ./chart
                    '''
                }
            }
        }
        stage('test') {
            steps {
                sh 'curl --silent --fail --show-error http://$RELEASE_NAME.$RELEASE_NAME.svc.k8s.unified-streaming.com/unified-learning.isml/.mpd'
            }
        }
        stage('publish chart') {
            steps {
                container('helm') {
                    sh '''
                        VERSION=`grep "^version:.*$" chart/Chart.yaml | awk '{print $2}'`-$BUILD_NUMBER+$GIT_COMMIT
                        helm --kubeconfig $KUBECONFIG \
                            push \
                            --version $VERSION \
                            ./chart \
                            $CHART_REPO
                    '''
                }
            }
        }
    }
    post {
        fixed {
            slackSend (color: '#00FF00', message: "FIXED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
        }
        failure {
            slackSend (color: '#FF0000', message: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
            container('helm') {
                sh '''
                    kubectl --kubeconfig $KUBECONFIG \
                        --namespace $RELEASE_NAME \
                        logs \
                        deployment/$RELEASE_NAME
                '''
            }
        }
    }
}
