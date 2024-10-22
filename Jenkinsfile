pipeline
{
    agent any
    stages
    {
        stage("Cleaning the workspace")
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

        stage("Cloning the repository")
        {
            steps
            {
                script
                {
                    git branch: 'portfolio', credentialsId: 'Github-ID', url: 'https://github.com/RameshXT/PORTFOLIO.git'
                }
            }
        }

        stage("Deleting Existing Images and Containers")
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
                    } else
                    {
                        echo "No images are there to delete!"
                    }
                }
            }
        }

        stage("Building dockerfile")
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

        stage("Update the image version in the deployment")
        {
            steps
            {
                sh "sudo bash /var/lib/jenkins/workspace/portfolio-ramesh/deploy/imageupdater.sh"
            }
        }


        stage("Docker login")
        {
            steps 
            {
                withCredentials([string(credentialsId: 'Docker-ID', variable: 'Docker')])
                {
                    sh '''
                        sudo docker login -u rameshxt -p $Docker
                    '''
                    echo "Docker loged in successfully."
                }
            }
        }

        stage("Pushing image to Docker Hub")
        {
            steps
            {
                script
                {
                    def dockerImageTag = "rameshxt/portfolio-ramesh:v1.0.0.${env.BUILD_NUMBER}"
                    def dockerImageLatestTag = "rameshxt/portfolio-ramesh:latest"

                    sh "sudo docker push ${dockerImageTag}"
                    echo "Docker image ${dockerImageTag} pushed to Docker Hub successfully."

                    sh "sudo docker tag ${dockerImageTag} ${dockerImageLatestTag}"
                    sh "sudo docker push ${dockerImageLatestTag}"
                    echo "Docker image ${dockerImageLatestTag} pushed to Docker Hub successfully."
                }
            }
        }

        stage('Deploy to Kubernetes')
        {
            steps
            {
                sh "kubectl apply -f /var/lib/jenkins/workspace/portfolio-ramesh/deploy/deployment.yaml"
                sh "kubectl apply -f /var/lib/jenkins/workspace/portfolio-ramesh/deploy/service.yaml"

                sh "nohup kubectl port-forward service/portfolio-service 30050:80 --address 0.0.0.0 > /var/log/port-forward.log 2>&1 &"
            }
        }
    }
}
