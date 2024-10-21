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
                    git branch: 'portfolio', credentialsId: 'GitHub-ID', url: 'https://github.com/RameshXT/PORTFOLIO.git'                
                }
            }
        }
        // stage("Deleting exiting images and container")
        // {
        //     steps
        //     {
        //         script
        //         {
        //             def containers = sh(script: "sudo docker ps -a -q", returnStdout: true).trim()
                    
        //             if (containers)
        //             {
        //                 sh "sudo docker stop $containers"
        //                 sh "sudo docker rm $containers"
        //                 echo "Containers successfully deleted!!"
        //             }
        //             else
        //             {
        //                 echo "No containers are there to delete!!"
        //             }
                    
        //             def images = sh(script: "sudo docker images -q", returnStdout: true).trim()
                    
        //             if (images)
        //             {
        //                 sh "sudo docker rmi $images"
        //                 echo "Images successfully deleted!!"
        //             }
        //             else
        //             {
        //                 echo "No images are there to delete!!"
        //             }
        //         }
        //     }
        // }


        stage("Deleting Existing Images and Containers") {
    steps {
        script {
            // Define the image and container to keep
            def keepImage = "gcr.io/k8s-minikube/kicbase:v0.0.45"
            def keepContainer = "minikube"

            // Get a list of all container IDs
            def containers = sh(script: "sudo docker ps -a -q", returnStdout: true).trim()

            if (containers) {
                // Stop and remove all containers except the specified one
                sh "sudo docker ps -q | grep -v \$(sudo docker ps --filter 'name=${keepContainer}' -q) | xargs -r sudo docker stop"
                sh "sudo docker ps -a -q | grep -v \$(sudo docker ps --filter 'name=${keepContainer}' -q) | xargs -r sudo docker rm"
                echo "Containers successfully deleted, except '${keepContainer}'!"
            } else {
                echo "No containers are there to delete!"
            }
            
            // Get a list of all image IDs
            def images = sh(script: "sudo docker images -q", returnStdout: true).trim()

            if (images) {
                // Remove all images except the specified one
                sh "sudo docker images -q | grep -v \$(sudo docker images --filter=reference=${keepImage} -q) | xargs -r sudo docker rmi --force"
                echo "Images successfully deleted, except '${keepImage}'!"
            } else {
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

        // stage("Running docker images")
        // {
        //     steps
        //     {
        //         script
        //         {
        //             def dockerImageTag = "rameshxt/portfolio-ramesh:V.1.${env.BUILD_NUMBER}"
                    
        //             sh "sudo docker run -i -t -d --name portfolio-cont -p 5050:80 ${dockerImageTag}"
                    
        //             echo "Docker container 'Portfolio-cont' is running successfully."
        //         }
        //     }
        // }

        // stage("Deployment on kubernetes cluser")
        // {
        //     steps
        //     {
        //         sh "kubectl apply -f /var/lib/jenkins/workspace/portfolio-ramesh/deploy/service.yaml"
        //         sh "kubectl port-forward /var/lib/jenkins/workspace/portfolio-ramesh/deploy/service.yaml 5050:80"
        //         sh "kubectl apply -f /var/lib/jenkins/workspace/portfolio-ramesh/deploy/ingress.yaml"
        //     }
        // }

        stage("Docker login") {
            steps {
                withCredentials([string(credentialsId: 'Docker-ID', variable: 'Docker')]) {
                    // Use an environment variable to avoid exposing the secret
                    sh '''
                        sudo docker login -u rameshxt -p $Docker
                    '''
                    echo "Docker login successful."
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

                    // Push the versioned image
                    sh "sudo docker push ${dockerImageTag}"
                    echo "Docker image ${dockerImageTag} pushed to Docker Hub successfully."

                    // Tag the image as latest
                    sh "sudo docker tag ${dockerImageTag} ${dockerImageLatestTag}"

                    // Push the latest image
                    sh "sudo docker push ${dockerImageLatestTag}"
                    echo "Docker image ${dockerImageLatestTag} pushed to Docker Hub successfully."
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                // Deploy your application using kubectl
                // withCredentials([file(credentialsId: 'minikube-kubeconfig', variable: 'KUBECONFIG')])
                withCredentials([string(credentialsId: 'Kube-ID', variable: 'Kubeconfig')])
                {
                    sh '''
                    $kubectl apply -f /var/lib/jenkins/workspace/portfolio-ramesh/deploy/deployment.yaml
                    $kubectl~ apply -f /var/lib/jenkins/workspace/portfolio-ramesh/deploy/service.yaml
                    '''
                }
            }
        }
    }
}
