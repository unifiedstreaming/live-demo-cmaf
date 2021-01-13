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
        RELEASE_NAME = sh(returnStdout: true, script: 'echo -n live-demo-cmaf-${BRANCH_NAME}')
        GIT_COMMIT = sh(returnStdout: true, script: 'git rev-parse HEAD').trim()
        USP_LICENSE_KEY = credentials('development-license.key')
        // Additional env variable which can be parsed at helm install or called
        // via chart/values.yaml
        // For origin
        // CHANNEL=test
        // LOG_LEVEL=warn
        // PUB_POINT_OPTS=--archiving=1 --archive_length=3600 --archive_segment_length=1800 --dvr_window_length=30 --restart_on_encoder_reconnect --mpd.min_buffer_time=48/25 --mpd.suggested_presentation_delay=48/25 --hls.minimum_fragment_length=48/25 --mpd.minimum_fragment_length=48/25 --mpd.segment_template=time --hls.client_manifest_version=4 --hls.fmp4
        // For ffmpeg
        // - PUB_POINT_URI=http://live-origin/test/test.isml
        //'TRACKS={ "video": [ { "width": 1024, "height": 576, "bitrate": "500k", "codec": "libx264", "framerate": 25, "gop": 24, "timescale": 50 }, { "width": 1280, "height": 720, "bitrate": "1000k", "codec": "libx264", "framerate": 50, "gop": 48, "timescale": 50 } ], "audio": [ { "samplerate": 48000, "bitrate": "64k", "codec": "aac", "language": "eng", "timescale": 48000 }, { "samplerate": 48000, "bitrate": "64k", "codec": "aac", "language": "dut", "timescale": 48000 } ] }'
    }
    stages {
        stage('build') {
            steps {
                container('kaniko') {
                    sh 'echo "{\\"auths\\":{\\"$REGISTRY_URL\\":{\\"username\\":\\"$REGISTRY_TOKEN_USR\\",\\"password\\":\\"$REGISTRY_TOKEN_PSW\\"}}}" > /kaniko/.docker/config.json'
                    sh '''
                        cd `pwd`/ffmpeg && \
                        /kaniko/executor \
                            -f `pwd`/Dockerfile \
                            -c `pwd` \
                            --cache=true \
                            --cache-repo=$DOCKER_REPO/cache \
                            --destination $DOCKER_REPO/$BRANCH_NAME:$GIT_COMMIT \
                            --destination $DOCKER_REPO/$BRANCH_NAME:latest \
                    '''
                }
            }
        }
        stage('deploy') {
            steps {
                container('helm') {
                    sh '''
                        helm --kubeconfig $KUBECONFIG \
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
                            --set image.tag=$GIT_COMMIT \
                            --set environment=$BRANCH_NAME \
                            $RELEASE_NAME \
                            ./chart
                    '''
                }
            }
        }
        stage('test') {
            steps {
                sh 'curl --silent --fail --show-error http://$RELEASE_NAME.$RELEASE_NAME.svc.k8s.unified-streaming.com/test/test.isml/.mpd'
            }
        }
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
    }
}
