/* groovylint-disable-next-line CompileStatic */
pipeline {
    agent {
        kubernetes {
            yaml '''
            apiVersion: v1
            kind: Pod
            metadata:
              labels:
                jenkins/kube-default: true
                app: jenkins
                component: agent
            spec:
              containers:
                - name: maven
                  image: maven:alpine
                  command:
                  - cat
                  tty: true
                  imagePullPolicy: Always
                  env:
                  - name: POD_IP
                    valueFrom:
                      fieldRef:
                       fieldPath: status.podIP
                  - name: DOCKER_HOST
                    value: tcp://localhost:2375
                - name: docker
                  image: docker:dind
                  securityContext:
                    privileged: true
                  volumeMounts:
                    - name: dind-storage
                      mountPath: /var/lib/docker
              volumes:
                - name: dind-storage
                  emptyDir: {}
    
            '''
        }
    }

    stages {
        stage('Clone') {
            steps {
                container('maven') {
                    /* groovylint-disable-next-line LineLength */
                    git branch: 'main', changelog: false, poll: false, url: 'https://github.com/Abvirk/statichtmldocker.git'
                }
            }
        }
        stage('Build-Docker-Image') {
            steps {
                container('docker') {
                    sh 'docker build -t abvirk/statichtml:${BUILD_NUMBER} .'
                }
            }
        }
        stage('Docker Buil') {
            steps {
                /* groovylint-disable-next-line DuplicateStringLiteral */
                container('docker') {
                    sh 'docker login -u abvirk -p dckr_pat_zx_8UEdcLTOhc-BPvU-1T1zwD2E'
                }
            }
        }
        stage('Docker Push') {
            steps {
                /* groovylint-disable-next-line DuplicateStringLiteral */
                container('docker') {
                    sh 'docker push abvirk/statichtml:${BUILD_NUMBER}'
                }
            }
        }
        stage('Update Deployment File') {
            steps {
                /* groovylint-disable-next-line DuplicateStringLiteral */
                container('maven') {
                    /* groovylint-disable-next-line NestedBlockDepth */
                    /* groovylint-disable-next-line GStringExpressionWithinString */
                    sh '''
                    git config user.email "se.abvirk@gmail.com"
                    git config user.name "Abrar Ahmad"
                    BUILD_NUMBER=${BUILD_NUMBER}
                    sed -i "s/replaceImageTag/${BUILD_NUMBER}/g" deployment.yml
                    git add deployment.yml
                    git commit -m "Update deployment image to version ${BUILD_NUMBER}"
                    git push https://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@github.com/abvirk/statichtmldocker HEAD:main
                '''
                }
            }
        }
    }
    post {
        always {
            /* groovylint-disable-next-line DuplicateStringLiteral */
            container('docker') {
                sh 'docker logout'
            }
        }
    }
}
