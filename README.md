Replace the README with this
# Student Notes - MySQL Backup to Amazon S3


A Dockerized Flask student-notes application with MySQL database backup to Amazon S3.


This project demonstrates how a Dockerized application can store data in MySQL and create database backups that are uploaded to Amazon S3.


## Architecture


```text
                    User
                     |
                     v
              Flask Web UI
                     |
                     v
             MySQL Container
                     |
                     | mysqldump
                     v
              Backup .sql file
                     |
                     v
             AWS CLI / Script
                     |
                     v
              Amazon S3 Bucket
                     |
                     v
          Encrypted Backup Storage
Technologies
Python
Flask
MySQL
Docker
Docker Network
AWS S3
AWS CLI
Terraform
Git / GitHub
Project Structure
student-notes-s3-backup/
│
├── app.py
├── Dockerfile
├── requirements.txt
├── README.md
│
├── templates/
│   └── index.html
│
├── scripts/
│   └── backup-mysql-to-s3.sh
│
├── backups/
│
└── terraform/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── terraform.tfvars
How the Application Works

The Flask application provides a web UI where users can create student notes.

The data flow is:

Flask UI
   |
   v
MySQL
   |
   v
mysqldump
   |
   v
SQL backup
   |
   v
Amazon S3
1. Start MySQL

Create the Docker network if it does not already exist:

docker network create student-notes-network

Run MySQL:

docker run -d \
  --name student-notes-mysql \
  --network student-notes-network \
  -e MYSQL_ROOT_PASSWORD=root \
  -e MYSQL_DATABASE=student_notes \
  mysql:latest

Check MySQL:

docker exec student-notes-mysql mysqladmin ping -u root -proot

Expected:

mysqld is alive
2. Start the Flask Application

Build the application image:

docker build -t student-notes-s3-backup .

Run the Flask container:

docker run -d \
  --name student-notes-app \
  --network student-notes-network \
  -p 5000:5000 \
  student-notes-s3-backup:latest

Open the application:

http://localhost:5000

You can now add student notes from the Flask UI.

3. Verify Data in MySQL

The notes created from the UI are stored in MySQL.

Example:

docker exec student-notes-mysql \
  mysql -u root -proot student_notes \
  -e "SELECT * FROM notes;"
4. Create the S3 Bucket Using Terraform

The S3 bucket is created using Terraform.

Go to the Terraform directory:

cd terraform

Initialize Terraform:

terraform init

Validate the configuration:

terraform validate

Review the infrastructure:

terraform plan

Create the S3 bucket:

terraform apply

Terraform creates an S3 bucket with:

Server-side encryption
Public access blocked
Terraform-managed infrastructure

Get the bucket name:

terraform output
5. Manual MySQL Backup to S3

A MySQL backup can be created manually using:

docker exec student-notes-mysql \
  mysqldump --single-transaction \
  --set-gtid-purged=OFF \
  -u root -proot student_notes \
  > backups/student_notes.sql

Upload the backup to S3:

aws s3 cp backups/student_notes.sql \
  s3://YOUR-BUCKET-NAME/backups/student_notes.sql

Verify:

aws s3 ls s3://YOUR-BUCKET-NAME/backups/
6. Automated Backup Script

The project contains:

scripts/backup-mysql-to-s3.sh

Make it executable:

chmod +x scripts/backup-mysql-to-s3.sh

Run:

./scripts/backup-mysql-to-s3.sh

The script:

Checks whether MySQL is running
Creates a MySQL dump
Adds a timestamp to the backup filename
Stores the backup in the backups/ directory
Uploads the backup to Amazon S3
Reports whether the backup was successful

Example:

Starting MySQL backup
Checking MySQL container...
MySQL container is running.
Creating MySQL dump...
MySQL dump created.
Uploading backup to S3...
Backup uploaded successfully.
Backup completed successfully
7. Verify the Backup in S3

List the backups:

aws s3 ls s3://YOUR-BUCKET-NAME/backups/

Example:

student_notes.sql
student_notes_2026-08-16_19-06-08.sql
8. Restore a Backup

A backup stored in S3 can be downloaded:

aws s3 cp \
  s3://YOUR-BUCKET-NAME/backups/student_notes_YYYY-MM-DD_HH-MM-SS.sql \
  restore/

The SQL file can then be restored into MySQL.

Example:

cat restore/student_notes.sql | \
docker exec -i student-notes-mysql \
mysql -u root -proot student_notes
Security

The project uses:

S3 server-side encryption
S3 public-access blocking
Terraform for infrastructure management
.gitignore to prevent Terraform state and database backups from being committed
Never commit AWS credentials

AWS access keys, secret keys, passwords, .env files and Terraform state files should not be pushed to GitHub.

Lab Question
Q-7: How can you connect Docker with Amazon S3 for storing application data or files?

Docker can connect to Amazon S3 by using AWS CLI or an AWS SDK such as Boto3.

In this project, the Flask application stores student notes in MySQL running inside Docker. A mysqldump backup is created from the MySQL container and uploaded to an Amazon S3 bucket using AWS CLI.

Terraform is used to create and configure the S3 bucket with encryption and public-access blocking.

Therefore, the data flow is:

Dockerized Flask Application
          |
          v
     MySQL Container
          |
          v
     MySQL Backup
          |
          v
       AWS CLI
          |
          v
     Amazon S3
Future Improvements

For a production environment, this architecture could be extended to:

Flask
  ↓
Amazon RDS MySQL
  ↓
Automated backups
  ↓
S3 / backup storage
  ↓
Retention
  ↓
Encryption
  ↓
CloudWatch monitoring

This lab demonstrates the core Docker-to-S3 backup workflow.



### 3. Save the file


In VS Code:


**Ctrl + S**


Then go back to Git Bash and check:


```bash
git status

You should now see:

modified: README.md
modified: .gitignore
untracked: scripts/
untracked: terraform/

Then we can commit everything safely:

git add README.md .gitignore scripts/ terraform/

Before committing, run:

git status

Send me that git status output. I'll check that no .sql, AWS credentials, or terraform.tfstate are accidentally being pushed before you do the final commit/push.