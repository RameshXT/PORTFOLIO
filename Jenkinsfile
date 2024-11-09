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
                echo "Checking out branch: portfolio from repository: https://github.com/RameshXT/PORTFOLIO.git"

                git branch: 'portfolio', credentialsId: 'GitHub-ID', url: 'https://github.com/RameshXT/PORTFOLIO.git'

                echo "Successfully checked out branch: portfolio."
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
                    echo "Building Docker image with tag: ${dockerImageTag}"

                    sh "sudo docker build -t ${dockerImageTag} /var/lib/jenkins/workspace/portfolio-ramesh"
                    echo "Docker image ${dockerImageTag} built successfully."
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
                    echo "Made image-updater.sh executable."

                    sh "/var/lib/jenkins/workspace/portfolio-ramesh/deploy/image-updater.sh"
                    echo "Image has been updated successfully."
                }
            }
        }

        stage('DEPLOY TO KUBERNETES')
        {
            steps
            {
                sh "kubectl apply -f /var/lib/jenkins/workspace/portfolio-ramesh/deploy/kube/deployment.yaml"
                echo "Deployment applied successfully."

                sh "kubectl apply -f /var/lib/jenkins/workspace/portfolio-ramesh/deploy/kube/service.yaml"
                echo "Service applied successfully."
                
                sh "nohup kubectl port-forward service/portfolio-service 30050:80 --address 0.0.0.0 > ~/workspace/port-forward.log 2>&1 &"
                echo "Port forwarding started on port 30050."
            }
        }

        stage('ACCESS PORTFOLIO')
        {
            steps
            {
                script
                {
                    def publicIP = sh(script: 'curl -s ifconfig.me', returnStdout: true).trim()
                    def accessMessage = "Congrats!!🎉 Your portfolio is running at the following link: http://${publicIP}:30050 🚀"
                    
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