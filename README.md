.

# 📚 Student Notes App with Docker, MySQL & Amazon S3 Backup


A Dockerized Student Notes application built with **Flask, MySQL, Docker, Terraform, and Amazon S3**.


The project demonstrates how a Flask application can store student notes in MySQL running inside Docker and how the MySQL database can be backed up to Amazon S3.


---


## 🏗️ Project Architecture


```text
                         ┌──────────────────────┐
                         │      Web Browser      │
                         │   http://localhost:5000
                         └──────────┬───────────┘
                                    │
                                    ▼
                         ┌──────────────────────┐
                         │   Flask Application  │
                         │   Docker Container   │
                         │   Port 5000          │
                         └──────────┬───────────┘
                                    │
                         Docker Network
                         student-notes-network
                                    │
                                    ▼
                         ┌──────────────────────┐
                         │    MySQL Database    │
                         │   Docker Container   │
                         │   Port 3306          │
                         │   student_notes      │
                         └──────────┬───────────┘
                                    │
                              mysqldump
                                    │
                                    ▼
                         ┌──────────────────────┐
                         │   Backup Script      │
                         │ backup-mysql-to-s3.sh│
                         └──────────┬───────────┘
                                    │
                               AWS CLI
                                    │
                                    ▼
                         ┌──────────────────────┐
                         │    Amazon S3 Bucket  │
                         │ MySQL Backup Storage │
                         │                      │
                         │ Encryption: AES-256  │
                         │ Public Access: Blocked│
                         └──────────────────────┘
🛠️ Technologies Used
Technology	Purpose
Python 3.11	Application development
Flask	Web application framework
HTML/CSS	User interface
MySQL	Application database
Docker	Containerization
Docker Network	Communication between containers
Terraform	AWS infrastructure provisioning
Amazon S3	Backup storage
AWS CLI	Uploading and verifying backups
mysqldump	MySQL database backup
📁 Project Structure
student-notes-s3-backup/
│
├── app.py
├── Dockerfile
├── requirements.txt
├── README.md
├── .gitignore
│
├── templates/
│   └── index.html
│
├── backups/
│   └── student_notes.sql
│
├── restore/
│
├── scripts/
│   └── backup-mysql-to-s3.sh
│
└── terraform/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── terraform.tfvars
    └── .terraform.lock.hcl
1. Clone the Repository

Clone the project:

git clone https://github.com/jyotics24/student-notes-s3-backup.git

Enter the project directory:

cd student-notes-s3-backup
2. Create Docker Network

Create a Docker network so that the Flask application and MySQL container can communicate with each other.

docker network create student-notes-network

If the network already exists, Docker will show:

network with name student-notes-network already exists

In that case, no action is required.

Check the network:

docker network ls
3. Run MySQL Container

Start the MySQL database:

docker run -d \
  --name student-notes-mysql \
  --network student-notes-network \
  -e MYSQL_ROOT_PASSWORD=root \
  -e MYSQL_DATABASE=student_notes \
  mysql:latest

Check the container:

docker ps
4. Check MySQL

Wait for MySQL to start and check whether the database is ready:

docker exec student-notes-mysql \
mysqladmin ping -u root -proot

Expected result:

mysqld is alive
5. Create the Notes Table

Create the notes table:

docker exec student-notes-mysql \
mysql -u root -proot student_notes \
-e "CREATE TABLE notes (
id INT AUTO_INCREMENT PRIMARY KEY,
title VARCHAR(255) NOT NULL,
content TEXT NOT NULL
);"
6. Build the Flask Docker Image

From the project root directory:

docker build -t student-notes-s3-backup .

Check the image:

docker image ls
7. Run the Flask Application

Start the Flask container:

docker run -d \
  --name student-notes-app \
  --network student-notes-network \
  -p 5000:5000 \
  student-notes-s3-backup:latest

Check both containers:

docker ps

Expected:

student-notes-app
student-notes-mysql
8. Open the Application

Open a web browser and visit:

http://localhost:5000

The Flask application provides the user interface for:

Adding notes
Viewing notes
Deleting notes

Notes entered through the Flask UI are stored in MySQL.

9. Verify Data in MySQL

After adding a note from the browser, verify the data:

docker exec student-notes-mysql \
mysql -u root -proot student_notes \
-e "SELECT * FROM notes;"

Example:

id    title           content
1     S3 Backup Test  This data will be backed up to Amazon S3.
2     S3 Backup Lab   This note was created from the Flask UI.

This confirms that:

Browser
   ↓
Flask
   ↓
MySQL

is working correctly.

10. Configure Amazon S3 Using Terraform

The project uses Terraform to create the S3 backup infrastructure.

Go to the Terraform directory:

cd terraform

Initialize Terraform:

terraform init

Review the infrastructure:

terraform plan

Apply the infrastructure:

terraform apply

When prompted:

Do you want to perform these actions?

Enter:

yes
11. S3 Infrastructure

Terraform creates an Amazon S3 bucket for MySQL backups.

The infrastructure includes:

S3 Bucket

Stores the MySQL backup files.

Server-Side Encryption

The bucket uses:

AES256

for server-side encryption.

Public Access Block

Public access is blocked using:

block_public_acls       = true
block_public_policy     = true
ignore_public_acls      = true
restrict_public_buckets = true

This prevents the backup bucket from being publicly accessible.

12. Check Terraform Outputs

Run:

terraform output

Example:

s3_bucket_arn = "arn:aws:s3:::student-notes-mysql-backup-651706778443"


s3_bucket_name = "student-notes-mysql-backup-651706778443"

The bucket name is then used by the backup script.

13. Create a MySQL Backup

The project uses mysqldump to create a backup of the MySQL database.

Check the installed version:

docker exec student-notes-mysql mysqldump --version

Create a backup directory:

mkdir -p backups

Create a database backup:

docker exec student-notes-mysql \
mysqldump \
--single-transaction \
--set-gtid-purged=OFF \
-u root -proot \
student_notes > backups/student_notes.sql

Check the backup:

ls -lah backups

The backup file contains the database structure and data.

14. Verify the Backup

The SQL backup can be inspected using:

grep -n "S3 Backup Lab" backups/student_notes.sql

If the note appears in the SQL file, the MySQL backup contains the application data.

15. Upload Backup to Amazon S3 Manually

A backup can be uploaded manually using AWS CLI:

aws s3 cp \
backups/student_notes.sql \
s3://YOUR_BUCKET_NAME/backups/student_notes.sql

Example:

aws s3 cp \
backups/student_notes.sql \
s3://student-notes-mysql-backup-651706778443/backups/student_notes.sql
16. Verify the Backup in S3

List the backup files:

aws s3 ls \
s3://student-notes-mysql-backup-651706778443/backups/

Example:

2026-08-16 18:44:44  2056 student_notes.sql

This confirms that the MySQL backup was successfully stored in Amazon S3.

17. Automated Backup Script

The project also contains a backup script:

scripts/backup-mysql-to-s3.sh

The script automates the following process:

Check MySQL
     ↓
Create mysqldump
     ↓
Save backup locally
     ↓
Upload backup to S3
     ↓
Display success message

Make the script executable:

chmod +x scripts/backup-mysql-to-s3.sh

Run it:

./scripts/backup-mysql-to-s3.sh

Example output:

======================================
Starting MySQL backup
======================================
Checking MySQL container...
MySQL container is running.
Creating MySQL dump...
MySQL dump created:
backups/student_notes_2026-08-16_19-06-08.sql
Uploading backup to S3...
Backup uploaded successfully.
======================================
Backup completed successfully
======================================
18. Verify Automated Backup

Check local backups:

ls -lah backups

Check S3:

aws s3 ls \
s3://student-notes-mysql-backup-651706778443/backups/

Example:

student_notes.sql
student_notes_2026-08-16_19-06-08.sql

Each execution of the backup script creates a timestamped backup.

This makes it possible to keep multiple backup versions.

19. Manual vs Automated Backup

The project supports both approaches.

Manual Backup

The administrator runs:

./scripts/backup-mysql-to-s3.sh

whenever a backup is required.

Flow:

Administrator
     ↓
Backup Script
     ↓
mysqldump
     ↓
S3
Automated Backup

The same script can be scheduled using a scheduler such as:

Linux cron
Windows Task Scheduler
CI/CD scheduler
AWS-native scheduling services

For example, a Linux cron job could run the backup every day:

0 2 * * * /path/to/student-notes-s3-backup/scripts/backup-mysql-to-s3.sh

This runs the backup at 2:00 AM every day.

20. Backup Storage Architecture

The final backup flow is:

┌─────────────────────┐
│   Student Browser   │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│   Flask Application │
│      Docker         │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│    MySQL Database   │
│      Docker         │
└──────────┬──────────┘
           │
       mysqldump
           │
           ▼
┌─────────────────────┐
│   Backup Script     │
└──────────┬──────────┘
           │
        AWS CLI
           │
           ▼
┌─────────────────────┐
│     Amazon S3       │
│                     │
│ Encrypted Backups   │
│ Public Access Block │
└─────────────────────┘
21. Security

The S3 backup infrastructure uses server-side encryption:

AES256

Public access to the bucket is blocked.

The backup bucket should never be made publicly accessible.

For production environments:

Use IAM roles instead of long-lived access keys
Store secrets in AWS Secrets Manager or Parameter Store
Use least-privilege IAM permissions
Enable S3 versioning where required
Configure lifecycle policies
Configure backup retention
Enable monitoring and alerting
Avoid hard-coded database passwords
Use private networking where appropriate
22. Backup Retention

For a production-style environment, backup retention should be defined according to business requirements.

Example:

Daily backups
     ↓
Keep for 7 days
     ↓
Delete expired backups automatically

S3 Lifecycle Rules can be used to automatically transition or delete old backup objects.

The current lab demonstrates the S3 backup mechanism and encryption/public-access controls.

23. Restore Process

A backup stored in S3 can be downloaded when restoration is required.

Download a backup:

aws s3 cp \
s3://YOUR_BUCKET_NAME/backups/student_notes.sql \
restore/student_notes.sql

Create the database if necessary:

docker exec student-notes-mysql \
mysql -u root -proot \
-e "CREATE DATABASE IF NOT EXISTS student_notes;"

Restore the SQL backup:

docker exec -i student-notes-mysql \
mysql -u root -proot student_notes \
< restore/student_notes.sql

Verify the restored data:

docker exec student-notes-mysql \
mysql -u root -proot student_notes \
-e "SELECT * FROM notes;"
24. Useful Docker Commands

Check running containers:

docker ps

Check all containers:

docker ps -a

View Flask logs:

docker logs student-notes-app

View MySQL logs:

docker logs student-notes-mysql

Check Docker networks:

docker network ls

Inspect the application network:

docker network inspect student-notes-network
25. Stop the Application

Stop Flask:

docker stop student-notes-app

Stop MySQL:

docker stop student-notes-mysql
26. Remove Containers

Remove Flask:

docker rm student-notes-app

Remove MySQL:

docker rm student-notes-mysql

The S3 backups are not deleted when the Docker containers are removed because the backups are stored separately in Amazon S3.

27. Terraform Cleanup

If the lab environment is no longer required, Terraform can remove the AWS infrastructure.

First review:

cd terraform
terraform plan -destroy

Then:

terraform destroy

Enter:

yes

when Terraform asks for confirmation.

Do not run terraform destroy if you need to keep the S3 backup bucket and its backup files.

28. Complete Workflow

The complete lab workflow is:

1. Start Docker
       ↓
2. Create Docker network
       ↓
3. Start MySQL container
       ↓
4. Create notes table
       ↓
5. Build Flask Docker image
       ↓
6. Start Flask container
       ↓
7. Open Flask UI
       ↓
8. Add student notes
       ↓
9. Data stored in MySQL
       ↓
10. Terraform creates S3 infrastructure
       ↓
11. mysqldump creates database backup
       ↓
12. Backup script uploads backup to S3
       ↓
13. S3 stores encrypted backup
       ↓
14. Backup can be downloaded and restored
29. Final Architecture
                         USER
                           │
                           ▼
                    ┌─────────────┐
                    │   Browser   │
                    └──────┬──────┘
                           │
                           │ HTTP :5000
                           ▼
                 ┌────────────────────┐
                 │ Flask Docker        │
                 │ student-notes-app   │
                 └─────────┬──────────┘
                           │
                           │ Docker Network
                           ▼
                 ┌────────────────────┐
                 │ MySQL Docker        │
                 │ student-notes-mysql │
                 │ student_notes       │
                 └─────────┬──────────┘
                           │
                           │ mysqldump
                           ▼
                 ┌────────────────────┐
                 │ Backup Script       │
                 │ backup-mysql-to-    │
                 │ s3.sh               │
                 └─────────┬──────────┘
                           │
                           │ AWS CLI
                           ▼
                 ┌────────────────────┐
                 │ Amazon S3           │
                 │ MySQL Backup Bucket │
                 │                    │
                 │ AES-256 Encryption │
                 │ Public Access Block│
                 └────────────────────┘
👨‍💻 Author

Jyotiprakash Khuntia

GitHub: https://github.com/jyotics24