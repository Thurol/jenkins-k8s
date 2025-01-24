# Déploiement Kubernetes sur AWS avec Terraform

Ce projet utilise Terraform pour déployer un cluster Kubernetes sur AWS. Il configure un nœud maître et des nœuds de travail, ainsi qu'un bastion pour se connecter aux instances.

## Prérequis

- [Terraform](https://www.terraform.io/downloads.html) v1.8.4 ou supérieur
- [AWS CLI](https://aws.amazon.com/cli/)
- Un compte AWS avec les permissions nécessaires
- Une paire de clés SSH pour se connecter aux instances

## Structure du projet

- `main.tf` : Définit les ressources principales, y compris les instances EC2 pour le maître et les nœuds de travail.
- `variables.tf` : Définit les variables utilisées dans le projet.
- `provider.tf` : Configure le fournisseur AWS.
- `data.tf` : Récupère les informations sur le VPC et les subnets.
- `sg.tf` : Définit les groupes de sécurité pour le maître et les nœuds de travail.
- `iam.tf` : Configure les rôles et les profils IAM pour les instances.
- `version.tf` : Spécifie la version de Terraform et les fournisseurs requis.
- `Jenkinsfile` : Pipeline Jenkins pour automatiser le déploiement.
- `scripts/master_userdata.sh.tpl` : Script d'initialisation pour le nœud maître.
- `scripts/nodes_userdata.sh.tpl` : Script d'initialisation pour les nœuds de travail.

## Utilisation

### Configuration

1. Clonez ce dépôt :
    ```sh
    git clone https://github.com/votre-utilisateur/votre-repo.git
    cd votre-repo
    ```

2. Configurez vos variables dans `variables.tf` si nécessaire.

3. Assurez-vous que votre paire de clés SSH est générée et disponible à `~/.ssh/id_rsa.pub`.

### Déploiement

1. Initialisez Terraform :
    ```sh
    terraform init
    ```

2. Planifiez le déploiement :
    ```sh
    terraform plan -out=tfplan
    ```

3. Appliquez le plan :
    ```sh
    terraform apply -auto-approve tfplan
    ```

### Connexion aux instances

1. Connectez-vous au bastion :
    ```sh
    ssh -i ~/.ssh/id_rsa ec2-user@<bastion-public-ip>
    ```

2. Depuis le bastion, connectez-vous au nœud maître ou aux nœuds de travail en utilisant leur IP privée.

### Déploiement d'une application Nginx

Pour déployer une application Nginx sur votre cluster Kubernetes, suivez ces étapes :

1. Connectez-vous au nœud maître :
    ```sh
    ssh -i ~/.ssh/id_rsa ec2-user@<master-private-ip>
    ```

2. Créez un fichier de déploiement Nginx `nginx-deployment.yaml` :
    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: nginx-deployment
      labels:
        app: nginx
    spec:
      replicas: 3
      selector:
        matchLabels:
          app: nginx
      template:
        metadata:
          labels:
            app: nginx
        spec:
          containers:
          - name: nginx
            image: nginx:1.14.2
            ports:
            - containerPort: 80
    ```

3. Appliquez le fichier de déploiement :
    ```sh
    kubectl apply -f nginx-deployment.yaml
    ```

4. Vérifiez que les pods Nginx sont en cours d'exécution :
    ```sh
    kubectl get pods
    ```

5. Exposez le déploiement Nginx en tant que service :
    ```sh
    kubectl expose deployment nginx-deployment --type=LoadBalancer --name=nginx-service
    ```

6. Obtenez l'URL du service Nginx :
    ```sh
    kubectl get services nginx-service
    ```

### Nettoyage

Pour détruire les ressources créées par Terraform :
```sh
terraform destroy -auto-approve