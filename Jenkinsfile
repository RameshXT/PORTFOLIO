pipeline
{
    agent any
    stages
    {
        stage("CLEANING THE WORKSPACE")
        {
            steps
            {
                script
                {
                    def workspaceDir = "/var/lib/jenkins/workspace/portfolio-ramesh/"
                    
                    if (fileExists(workspaceDir))
                    {
                        sh "sudo rm -rf ${workspaceDir}*"
                    }
                    else
                    {
                        echo "Workspace directory doesn't exist."
                    }
                }
            }
        }

        stage("GIT CHECKOUT")
        {
            steps
            {
                git branch: 'portfolio', credentialsId: 'GitHub-ID', url: 'https://github.com/RameshXT/PORTFOLIO.git'
            }
        }

        stage("DELETING EXISTING IMAGES AND CONTAINERS")
        {
            steps
            {
                script
                {
                    def keepImage = "gcr.io/k8s-minikube/kicbase:v0.0.45"
                    def keepContainer = "minikube"

                    // CHECK AND DELETE ALL CONTAINERS EXCEPT 'minikube'
                    def containers = sh(script: "sudo docker ps -a -q", returnStdout: true).trim()
                    if (containers)
                    {
                        sh "sudo docker ps -q | grep -v \$(sudo docker ps --filter 'name=${keepContainer}' -q) | xargs -r sudo docker stop"
                        sh "sudo docker ps -a -q | grep -v \$(sudo docker ps --filter 'name=${keepContainer}' -q) | xargs -r sudo docker rm"
                        echo "Containers successfully deleted, except '${keepContainer}'!"
                    }
                    else
                    {
                        echo "No containers are there to delete!"
                    }

                    // CHECK AND DELETE ALL IMAGES EXCEPT 'kicbase'
                    def images = sh(script: "sudo docker images -q", returnStdout: true).trim()
                    if (images)
                    {
                        sh "sudo docker images -q | grep -v \$(sudo docker images --filter=reference=${keepImage} -q) | xargs -r sudo docker rmi --force"
                        echo "Images successfully deleted, except '${keepImage}'!"
                    }
                    else
                    {
                        echo "No images are there to delete!"
                    }
                }
            }
        }

        stage("BUILDING DOCKER IMAGE")
        {
            steps
            {
                script
                {
                    def dockerImageTag = "rameshxt/portfolio-ramesh:v1.0.0.${env.BUILD_NUMBER}"
                    sh "sudo docker build -t ${dockerImageTag} /var/lib/jenkins/workspace/portfolio-ramesh"
                }
            }
        }

        stage("DOCKER LOGIN")
        {
            steps
            {
                withCredentials([string(credentialsId: 'Docker-ID', variable: 'Docker')])
                {
                    sh """
                        sudo docker login -u rameshxt -p "${Docker}"
                    """
                    echo "Docker logged in successfully."
                }
            }
        }

        stage('PUSHING IMAGE TO DOCKER HUB')
        {
            steps
            {
                script
                {
                    def dockerImageTag = "rameshxt/portfolio-ramesh:v1.0.0.${env.BUILD_NUMBER}"
                    sh "sudo docker push ${dockerImageTag}"
                    echo "Docker image ${dockerImageTag} pushed to Docker Hub successfully."
                }
            }
        }

        stage('IMAGE VERSION UPDATER')
        {
            steps
            {
                script
                {
                    echo "Current Build Number: ${env.BUILD_NUMBER}"
                    sh "chmod +x /var/lib/jenkins/workspace/portfolio-ramesh/deploy/image-updater.sh"
                    sh "/var/lib/jenkins/workspace/portfolio-ramesh/deploy/image-updater.sh"
                }
            }
        }

        stage('DEPLOY TO KUBERNETES')
        {
            steps
            {
                sh "kubectl apply -f /var/lib/jenkins/workspace/portfolio-ramesh/deploy/kube/deployment.yaml"
                sh "kubectl apply -f /var/lib/jenkins/workspace/portfolio-ramesh/deploy/kube/service.yaml"
                sh "nohup kubectl port-forward service/portfolio-service 30050:80 --address 0.0.0.0 > ~/workspace/port-forward.log 2>&1 &"
            }
        }

        stage('ACCESS PORTFOLIO')
        {
            steps
            {
                script
                {
                    def publicIP = sh(script: 'curl -s ifconfig.me', returnStdout: true).trim()
                    def accessMessage = "Congratulations!🎉 Your portfolio is running at the following link: http://${publicIP}:30050 🚀"
                    echo "${accessMessage}"
                }
            }
        }
    }

    post
    {
        success
        {
            echo '✅ BUILD COMPLETED SUCCESSFULLY!'
        }
        failure
        {
            echo '❌ BUILD FAILED!'
        }
    }
}