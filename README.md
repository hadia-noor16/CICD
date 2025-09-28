# CICD

**Project Overview**
**Introduction**
This project demonstrate the automated deployment of infrastructure by following DevOps best practices along with secure and efficient website deployment.
**Key Features**
1. Automated CI/CD pipeline - secure and efficient deployments
2. Infrastructure as Code (IaC) - Terraform for automated provisioning
3. Cost optimization
4. Security

   <img width="2450" height="1482" alt="image" src="https://github.com/user-attachments/assets/4ac35790-c4ac-4ac3-8c02-ff16e1d8f34c" />


**Architecture Overview**
**Infrastructure Components**
**1. CI/CD Pipeline**
   . Integrated with GitHub repository.
   . CodeBuild stage.
   . CodePipeline (To streamline the CI/CD pipeline)
   . Deploying website to Dev S3 bucket.
   . SNS subscription (via email) for production approval.
   
**2. S3**
   . Artifacts S3 bucket shared by source, build, and deploy stage.
   . Remote S3 with DynamoDb for state locking.
   
**3. AWS IAM**
   . Service role creation for pipeline with required permissions.
   . Access keys for IAM user.

**4. CloudFront**
   . Origin Access Control in place to by pass direct access to S3 prod bucket.
   . Redirect all HTTP content to HTTPs.
   . SSL/TLS certificate from Amazon Certificate Manager.
   
**5. Route 53**
   . Personal domain with Alias records serving CloudFront content.




   
   

