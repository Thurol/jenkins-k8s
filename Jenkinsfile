pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        TF_VAR_region = "${AWS_REGION}"
        TF_VAR_ami = 'ami-04b4f1a9cf54c11d0'
        TF_VAR_instance_type = 't3.medium'
    }

    stages {
        stage('Prepare Environment') {
            steps {
                script {
                    sh '''
                    echo "Préparation de l'environnement pour Terraform..."
                    rm -rf .terraform || true
                    rm -f .terraform.lock.hcl || true
                    terraform init -upgrade
                    '''
                }
            }
        }

        stage('Plan Infrastructure') {
            steps {
                script {
                    sh '''
                    echo "Génération du plan Terraform..."
                    terraform plan -var "region=${TF_VAR_region}" \
                                   -var "ami=${TF_VAR_ami}" \
                                   -var "instance_type=${TF_VAR_instance_type}" \
                                   -out=tfplan               
                    '''
                }
            }
        }

        stage('Apply Infrastructure') {
            steps {
                script {
                    sh '''
                    echo "Application de l'infrastructure Terraform..."
                    terraform apply -auto-approve tfplan
                    '''
                }
            }
        }

        stage('Validate Deployment') {
            steps {
                script {
                    sh '''
                    echo "Validation des instances EC2 déployées..."
                    aws ec2 describe-instances --region ${AWS_REGION} --filters "Name=tag:Role,Values=K8sMaster" "Name=instance-state-name,Values=running"
                    '''
                }
            }
        }
    }

    post {
        always {
            script {
                sh '''
                echo "Sauvegarde des logs Terraform..."
                terraform output > terraform_output.log
                '''
            }
        }
        success {
            echo "Infrastructure déployée avec succès !"
        }
        failure {
            echo "Échec du déploiement de l'infrastructure."
        }
        cleanup {
            script {
                echo "Nettoyage final après exécution..."
            }
        }
    }
}
