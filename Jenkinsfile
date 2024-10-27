pipeline
{
    agent any
    stages
    {
        stage("Clone")
        {
            steps
            {
                git branch: 'portfolio', credentialsId: 'GitHub-ID', url: 'https://github.com/RameshXT/PORTFOLIO.git'
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
                    // def dockerImageLatestTag = "rameshxt/portfolio-ramesh:latest"

                    sh "sudo docker push ${dockerImageTag}"
                    echo "Docker image ${dockerImageTag} pushed to Docker Hub successfully."

                    // sh "sudo docker tag ${dockerImageTag} ${dockerImageLatestTag}"
                    // sh "sudo docker push ${dockerImageLatestTag}"
                    // echo "Docker image ${dockerImageLatestTag} pushed to Docker Hub successfully."
                }
            }
        }
        stage('Image updater')
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
        stage('Deploy to Kubernetes')
        {
            steps
            {
                sh "kubectl apply -f /var/lib/jenkins/workspace/portfolio-ramesh/deploy/kube/deployment.yaml"

                sh "kubectl apply -f /var/lib/jenkins/workspace/portfolio-ramesh/deploy/kube/service.yaml"

                sh "nohup kubectl port-forward service/portfolio-service 30050:80 --address 0.0.0.0 > ~/workspace/port-forward.log 2>&1 &"

                // Uncomment and run the following if you face permissions issues with port-forward:
                // sh "sudo chown jenkins:jenkins /var/log"
            }
        }

        stage('Access Portfolio')
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
    post {
        always {
            script {
                def recipient = 'rameshkanna841@gmail.com'
                def sender = 'rameshxt.1@gmail.com'
                def subject = "Jenkins Build #${currentBuild.number} - ${currentBuild.currentResult}"
                def body = """
                The build has completed with status: ${currentBuild.currentResult}.
                
                You can access your web application at: http://<your-web-app-url>:30050

                Check the console output at ${env.BUILD_URL} to view the results.
                """

                emailext (
                    subject: subject,
                    body: body,
                    recipientProviders: [[$class: 'CulpritsRecipientProvider'], [$class: 'RequesterRecipientProvider']],
                    to: recipient,
                    from: sender
                )
            }
        }
    }
}