# 📚 Student Notes App with Docker, MySQL & Amazon S3 Backup

A Dockerized Student Notes application built with **Flask, MySQL, Docker, Terraform, and Amazon S3**.

This lab demonstrates:

- Running a Flask application in Docker
- Running MySQL in Docker
- Connecting Flask to MySQL using a Docker network
- Adding student notes through the Flask UI
- Creating MySQL database backups using `mysqldump`
- Creating an Amazon S3 bucket using Terraform
- Uploading MySQL backups to Amazon S3
- Performing both manual and script-based backups
- Encrypting S3 backup storage
- Blocking public access to the S3 bucket
- Verifying backups in S3
- Downloading and restoring a database backup

---

# 🏗️ Project Architecture

```text
                         ┌──────────────────────┐
                         │      Web Browser      │
                         │   localhost:5000     │
                         └──────────┬───────────┘
                                    │
                                    │ HTTP
                                    ▼
                         ┌──────────────────────┐
                         │   Flask Application  │
                         │   Docker Container   │
                         │   Port 5000          │
                         └──────────┬───────────┘
                                    │
                                    │ Docker Network
                                    │ student-notes-network
                                    ▼
                         ┌──────────────────────┐
                         │    MySQL Database    │
                         │   Docker Container   │
                         │   Port 3306          │
                         │   student_notes      │
                         └──────────┬───────────┘
                                    │
                                    │ mysqldump
                                    ▼
                         ┌──────────────────────┐
                         │    Backup Script     │
                         │ backup-mysql-to-s3.sh│
                         └──────────┬───────────┘
                                    │
                                    │ AWS CLI
                                    ▼
                         ┌──────────────────────┐
                         │     Amazon S3        │
                         │   Backup Storage     │
                         │                      │
                         │   AES-256 Encryption │
                         │   Public Access Block│
                         └──────────────────────┘
```

---

# 🛠️ Technologies Used

| Technology | Purpose |
|---|---|
| Python 3.11 | Application development |
| Flask | Web application framework |
| HTML/CSS | User interface |
| MySQL | Application database |
| Docker | Containerization |
| Docker Network | Communication between containers |
| Terraform | AWS infrastructure provisioning |
| Amazon S3 | Backup storage |
| AWS CLI | S3 management and backup upload |
| mysqldump | MySQL database backup |

---

# 📁 Project Structure

```text
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
```

---

# 🚀 Lab Setup

## 1. Clone the Repository

```bash
git clone https://github.com/jyotics24/student-notes-s3-backup.git
cd student-notes-s3-backup
```

---

## 2. Create Docker Network

Create a Docker network so that Flask and MySQL can communicate.

```bash
docker network create student-notes-network
```

Check the network:

```bash
docker network ls
```

If the network already exists, Docker may display:

```text
network with name student-notes-network already exists
```

In that case, no action is required.

---

# 🐬 MySQL Setup

## 3. Run MySQL Container

Start the MySQL container:

```bash
docker run -d \
  --name student-notes-mysql \
  --network student-notes-network \
  -e MYSQL_ROOT_PASSWORD=root \
  -e MYSQL_DATABASE=student_notes \
  mysql:latest
```

Check the container:

```bash
docker ps
```

You should see:

```text
student-notes-mysql
```

---

## 4. Check MySQL

Wait for MySQL to start.

Then run:

```bash
docker exec student-notes-mysql \
mysqladmin ping -u root -proot
```

Expected result:

```text
mysqld is alive
```

---

## 5. Create the Notes Table

Create the `notes` table:

```bash
docker exec student-notes-mysql \
mysql -u root -proot student_notes \
-e "CREATE TABLE notes (
id INT AUTO_INCREMENT PRIMARY KEY,
title VARCHAR(255) NOT NULL,
content TEXT NOT NULL
);"
```

---

# 🐳 Flask Application Setup

## 6. Build the Flask Docker Image

From the project root:

```bash
docker build -t student-notes-s3-backup .
```

Check the image:

```bash
docker image ls
```

---

## 7. Run the Flask Application

Start the Flask container:

```bash
docker run -d \
  --name student-notes-app \
  --network student-notes-network \
  -p 5000:5000 \
  student-notes-s3-backup:latest
```

Check both containers:

```bash
docker ps
```

Expected containers:

```text
student-notes-app
student-notes-mysql
```

---

## 8. Open the Application

Open the browser:

```text
http://localhost:5000
```

The Flask application allows the user to:

- Add notes
- View notes
- Delete notes

The data entered through the Flask UI is stored in MySQL.

---

# 🗄️ Verify Application Data

## 9. Verify Data in MySQL

After adding a note through the Flask UI, run:

```bash
docker exec student-notes-mysql \
mysql -u root -proot student_notes \
-e "SELECT * FROM notes;"
```

Example:

```text
+----+----------------+------------------------------------------+
| id | title          | content                                  |
+----+----------------+------------------------------------------+
|  1 | S3 Backup Test | This data will be backed up to Amazon S3.|
|  2 | S3 Backup Lab  | This note was created from the Flask UI. |
+----+----------------+------------------------------------------+
```

The application flow is:

```text
Browser
   ↓
Flask
   ↓
MySQL
```

---

# ☁️ Amazon S3 Backup Setup

## 10. Configure AWS

Check the AWS identity:

```bash
aws sts get-caller-identity
```

Check the configured region:

```bash
aws configure get region
```

For this lab, the AWS region is:

```text
us-east-1
```

---

# 🏗️ Terraform Infrastructure

## 11. Initialize Terraform

Go to the Terraform directory:

```bash
cd terraform
```

Initialize Terraform:

```bash
terraform init
```

---

## 12. Review Terraform Configuration

Run:

```bash
terraform plan
```

Review the resources that Terraform will create.

---

## 13. Create the S3 Infrastructure

Apply Terraform:

```bash
terraform apply
```

When Terraform asks for confirmation:

```text
Do you want to perform these actions?
```

Enter:

```text
yes
```

Terraform creates the S3 infrastructure used for storing MySQL backups.

---

# 🪣 S3 Backup Bucket

## 14. S3 Security Configuration

The S3 bucket is configured for backup storage.

The infrastructure provides:

- Server-side encryption
- Public access blocking
- Private backup storage

Encryption uses:

```text
AES256
```

Public access is blocked using:

```text
block_public_acls       = true
block_public_policy     = true
ignore_public_acls      = true
restrict_public_buckets = true
```

The backup files should never be publicly accessible.

---

## 15. Check Terraform Outputs

Run:

```bash
terraform output
```

Example:

```text
s3_bucket_arn = "arn:aws:s3:::student-notes-mysql-backup-651706778443"

s3_bucket_name = "student-notes-mysql-backup-651706778443"
```

The bucket name is used by the backup script.

Return to the project root:

```bash
cd ..
```

---

# 💾 MySQL Backup

## 16. Check mysqldump

Check that `mysqldump` is available inside the MySQL container:

```bash
docker exec student-notes-mysql mysqldump --version
```

Example:

```text
mysqldump  Ver 26.7.0 for Linux on x86_64
```

---

## 17. Create the Backup Directory

```bash
mkdir -p backups
```

---

## 18. Create a MySQL Backup Manually

Create the database dump:

```bash
docker exec student-notes-mysql \
mysqldump \
--single-transaction \
--set-gtid-purged=OFF \
-u root -proot \
student_notes > backups/student_notes.sql
```

The backup is created locally:

```text
backups/student_notes.sql
```

Check the file:

```bash
ls -lah backups
```

---

## 19. Verify the Backup

Search for application data inside the SQL backup:

```bash
grep -n "S3 Backup Lab" backups/student_notes.sql
```

Example:

```text
39:INSERT INTO `notes` VALUES ...
```

This confirms that the MySQL data created through the Flask UI is present in the backup.

---

# ☁️ Upload Backup to S3

## 20. Manual S3 Upload

The backup can be uploaded manually using AWS CLI.

Example:

```bash
aws s3 cp \
backups/student_notes.sql \
s3://student-notes-mysql-backup-651706778443/backups/student_notes.sql
```

Expected output:

```text
upload: backups\student_notes.sql to s3://student-notes-mysql-backup-651706778443/backups/student_notes.sql
```

---

## 21. Verify the Backup in S3

List the backup files:

```bash
aws s3 ls \
s3://student-notes-mysql-backup-651706778443/backups/
```

Example:

```text
2026-08-16 18:44:44       2056 student_notes.sql
```

This confirms that the MySQL backup has been stored in Amazon S3.

---

# 🤖 Script-Based Backup

## 22. Backup Script

The project contains:

```text
scripts/backup-mysql-to-s3.sh
```

The script performs the following operations:

```text
Check MySQL container
        ↓
Create mysqldump
        ↓
Save backup locally
        ↓
Upload backup to S3
        ↓
Display backup status
```

---

## 23. Make the Script Executable

Run:

```bash
chmod +x scripts/backup-mysql-to-s3.sh
```

Check the script:

```bash
ls -lah scripts
```

---

## 24. Run the Backup Script

Run:

```bash
./scripts/backup-mysql-to-s3.sh
```

Example output:

```text
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
```

---

# 🔄 Manual and Automated Backup

## 25. Manual Backup

The backup script can be executed manually whenever a backup is required:

```bash
./scripts/backup-mysql-to-s3.sh
```

The process is:

```text
Administrator
      ↓
Backup Script
      ↓
mysqldump
      ↓
S3
```

---

## 26. Automated Backup

The same script can be scheduled so that backups happen automatically.

Possible schedulers include:

- Linux cron
- Windows Task Scheduler
- CI/CD schedulers
- AWS scheduling services

For example, a Linux cron job can execute the script every day at 2:00 AM:

```cron
0 2 * * * /path/to/student-notes-s3-backup/scripts/backup-mysql-to-s3.sh
```

The automated flow becomes:

```text
Scheduler
    ↓
Backup Script
    ↓
mysqldump
    ↓
Amazon S3
```

---

# 📦 Verify Multiple Backups

## 27. Check Local Backups

```bash
ls -lah backups
```

Example:

```text
student_notes.sql
student_notes_2026-08-16_19-06-08.sql
```

---

## 28. Check S3 Backups

```bash
aws s3 ls \
s3://student-notes-mysql-backup-651706778443/backups/
```

Example:

```text
2026-08-16 18:44:44       2056 student_notes.sql
2026-08-16 19:06:11       2056 student_notes_2026-08-16_19-06-08.sql
```

Each execution of the script creates a timestamped backup.

This allows multiple backup versions to be stored in S3.

---

# 🔁 Complete Backup Architecture

The complete application and backup flow is:

```text
                    USER
                      │
                      ▼
               ┌─────────────┐
               │   Browser   │
               └──────┬──────┘
                      │
                      │ HTTP
                      ▼
               ┌─────────────┐
               │    Flask    │
               │   Docker    │
               └──────┬──────┘
                      │
                      │ Docker Network
                      ▼
               ┌─────────────┐
               │    MySQL    │
               │   Docker    │
               └──────┬──────┘
                      │
                      │ mysqldump
                      ▼
               ┌─────────────┐
               │   Backup    │
               │   Script    │
               └──────┬──────┘
                      │
                      │ AWS CLI
                      ▼
               ┌─────────────┐
               │  Amazon S3  │
               │   Backup    │
               │   Storage   │
               └─────────────┘
```

---

# 🔐 Backup Security

The S3 backup storage uses:

```text
Server-Side Encryption
        ↓
AES256
```

Public access is blocked.

The backup bucket should not be publicly accessible.

For a production environment, additional security practices should include:

- Use IAM roles instead of long-lived access keys
- Use least-privilege IAM permissions
- Store application secrets securely
- Avoid hard-coded database passwords
- Use AWS Secrets Manager or Parameter Store
- Use private networking where appropriate
- Enable S3 versioning when required
- Enable monitoring and alerting

---

# 🗓️ Backup Retention

A production backup system should define a retention policy.

Example:

```text
Daily Backup
     ↓
Keep for 7 Days
     ↓
Delete Expired Backups
```

S3 Lifecycle Rules can be used to automatically delete old backup objects or transition them to lower-cost storage classes.

The current lab demonstrates the backup storage mechanism and S3 security configuration.

---

# ♻️ Restore Process

A backup stored in S3 can be downloaded and restored when required.

## 29. Download Backup from S3

Create the restore directory:

```bash
mkdir -p restore
```

Download the backup:

```bash
aws s3 cp \
s3://student-notes-mysql-backup-651706778443/backups/student_notes.sql \
restore/student_notes.sql
```

---

## 30. Create the Database

If the database does not exist:

```bash
docker exec student-notes-mysql \
mysql -u root -proot \
-e "CREATE DATABASE IF NOT EXISTS student_notes;"
```

---

## 31. Restore the Backup

Restore the SQL file:

```bash
docker exec -i student-notes-mysql \
mysql -u root -proot student_notes \
< restore/student_notes.sql
```

---

## 32. Verify Restored Data

Run:

```bash
docker exec student-notes-mysql \
mysql -u root -proot student_notes \
-e "SELECT * FROM notes;"
```

The previously backed-up student notes should be available again.

---

# 🐳 Useful Docker Commands

## Check Running Containers

```bash
docker ps
```

## Check All Containers

```bash
docker ps -a
```

## View Flask Logs

```bash
docker logs student-notes-app
```

## View MySQL Logs

```bash
docker logs student-notes-mysql
```

## Check Docker Networks

```bash
docker network ls
```

## Inspect the Application Network

```bash
docker network inspect student-notes-network
```

---

# 🛑 Stop the Application

Stop Flask:

```bash
docker stop student-notes-app
```

Stop MySQL:

```bash
docker stop student-notes-mysql
```

---

# 🗑️ Remove Containers

Remove Flask:

```bash
docker rm student-notes-app
```

Remove MySQL:

```bash
docker rm student-notes-mysql
```

Removing the Docker containers does not remove the S3 backup files because the backups are stored separately in Amazon S3.

---

# 🧹 Terraform Cleanup

If the AWS infrastructure is no longer required, Terraform can be used to remove it.

Go to Terraform:

```bash
cd terraform
```

Review the destroy plan:

```bash
terraform plan -destroy
```

Destroy the infrastructure:

```bash
terraform destroy
```

When prompted, enter:

```text
yes
```

> **Warning:** Do not run `terraform destroy` if you need to keep the S3 bucket and its backup files.

---

# 🔄 Complete Lab Workflow

The complete lab can be summarized as:

```text
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
10. Create S3 infrastructure with Terraform
       ↓
11. Create MySQL backup using mysqldump
       ↓
12. Upload backup to S3
       ↓
13. Verify backup in S3
       ↓
14. Run backup script for repeated backups
       ↓
15. Schedule script for automated backups
       ↓
16. Download backup when required
       ↓
17. Restore MySQL database
```

---

# 🎯 Final Architecture

```text
                         ┌──────────────────┐
                         │      USER        │
                         └────────┬─────────┘
                                  │
                                  ▼
                         ┌──────────────────┐
                         │     Browser      │
                         │ localhost:5000   │
                         └────────┬─────────┘
                                  │
                                  ▼
                         ┌──────────────────┐
                         │ Flask Application│
                         │    Docker        │
                         └────────┬─────────┘
                                  │
                                  │ Docker Network
                                  ▼
                         ┌──────────────────┐
                         │      MySQL       │
                         │     Docker       │
                         │  student_notes   │
                         └────────┬─────────┘
                                  │
                                  │ mysqldump
                                  ▼
                         ┌──────────────────┐
                         │  Backup Script   │
                         │                  │
                         │ backup-mysql-    │
                         │ to-s3.sh         │
                         └────────┬─────────┘
                                  │
                                  │ AWS CLI
                                  ▼
                         ┌──────────────────┐
                         │    Amazon S3     │
                         │                  │
                         │ MySQL Backups    │
                         │                  │
                         │ AES-256          │
                         │ Encryption       │
                         │                  │
                         │ Public Access    │
                         │ Blocked          │
                         └──────────────────┘
```

---

# 📌 What This Lab Demonstrates

This project demonstrates a complete Docker + MySQL + S3 backup workflow:

```text
Flask
  ↓
MySQL
  ↓
mysqldump
  ↓
Backup Script
  ↓
AWS CLI
  ↓
Amazon S3
```

The backup can be performed:

```text
MANUALLY
    ↓
./scripts/backup-mysql-to-s3.sh
```

or scheduled for:

```text
AUTOMATED BACKUPS
    ↓
Scheduler
    ↓
Backup Script
    ↓
Amazon S3
```

The S3 bucket provides secure backup storage with encryption and public-access blocking.

---

# 👨‍💻 Author

**Jyotiprakash Khuntia**

GitHub: https://github.com/jyotics24/student-notes-s3-backup

---

⭐ If you found this project useful, feel free to star the repository.