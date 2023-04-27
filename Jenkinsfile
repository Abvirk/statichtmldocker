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
                  image: abhishekf5/maven-abhishek-docker-agent:v1
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
                    withCredentials([string(credentialsId: 'github-token', variable: 'GITHUB_TOKEN')]) {
                        sh '''
                    git config user.email "se.abvirk@gmail.com"
                    git config user.name "Abrar Ahmad"
                    BUILD_NUMBER=${BUILD_NUMBER}
                    
                    sed -i "s/replaceImageTag/${BUILD_NUMBER}/g" manifests/deployment.yaml
                    git add manifests/deployment.yaml
                    git commit -m "Update deployment image to version ${BUILD_NUMBER}"
                    git push "https://${GITHUB_TOKEN}@github.com/Abvirk/statichtmldocker.git"  
   '''
                    }
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
