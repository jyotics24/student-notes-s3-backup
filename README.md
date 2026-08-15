# 📚 Student Notes App

A simple **Student Notes application** built with **Flask, MySQL, and Docker**.

The application allows users to:

- ➕ Add notes
- 📖 View notes
- 🗑️ Delete notes
- 💾 Store notes in MySQL
- 🐳 Run Flask and MySQL using Docker containers

---

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| Python 3.11 | Application language |
| Flask | Web framework |
| MySQL | Database |
| Docker | Containerization |
| HTML/CSS | Frontend |

---

## 📁 Project Structure

```text
student-notes-app/
│
├── app.py
├── Dockerfile
├── requirements.txt
├── README.md
├── .gitignore
│
└── templates/
    └── index.html
```

---

## 🐳 Docker Architecture

The application uses **two containers**:

```text
┌──────────────────────────┐
│   Browser                │
│   localhost:5001         │
└────────────┬─────────────┘
             │
             │ Port 5001
             ▼
┌──────────────────────────┐
│ Flask Container          │
│ student-notes-container  │
│ Port: 5000               │
└────────────┬─────────────┘
             │
             │ Docker Network
             │ student-notes-network
             ▼
┌──────────────────────────┐
│ MySQL Container          │
│ student-notes-mysql      │
│ Port: 3306               │
└──────────────────────────┘
```

The Flask container communicates with MySQL using the MySQL container name:

```text
student-notes-mysql
```

---

## 🔨 Build the Flask Image

From the project directory:

```bash
docker build -t student-notes-app .
```

---

## 🗄️ Create the Docker Network

```bash
docker network create student-notes-network
```

---

## 🐬 Run MySQL Container

```bash
docker run -d \
  --name student-notes-mysql \
  --network student-notes-network \
  -e MYSQL_ROOT_PASSWORD=root \
  -e MYSQL_DATABASE=student_notes \
  mysql:latest
```

---

## 📝 Create the Notes Table

Create the `notes` table inside the MySQL database:

```bash
docker exec -it student-notes-mysql \
mysql -uroot -proot student_notes \
-e "CREATE TABLE notes (
id INT AUTO_INCREMENT PRIMARY KEY,
title VARCHAR(255) NOT NULL,
content TEXT NOT NULL
);"
```

---

## 🚀 Run Flask Container

Run the Flask application on the same Docker network:

```bash
docker run -d \
  -p 5001:5000 \
  --name student-notes-container \
  --network student-notes-network \
  student-notes-app
```

---

## 🌐 Access the Application

Open your browser:

```text
http://localhost:5001
```

---

## 🔌 Database Configuration

The Flask application connects to MySQL using:

```python
host="student-notes-mysql"
```

Database configuration:

```text
Host:     student-notes-mysql
Port:     3306
User:     root
Password: root
Database: student_notes
```

Because both containers are connected to the same Docker network, Docker provides DNS resolution between the containers.

---

## 📋 Useful Docker Commands

### Check running containers

```bash
docker ps
```

### Check all containers

```bash
docker ps -a
```

### View Flask logs

```bash
docker logs student-notes-container
```

### View MySQL logs

```bash
docker logs student-notes-mysql
```

### Check Docker networks

```bash
docker network ls
```

### Inspect the network

```bash
docker network inspect student-notes-network
```

---

## 🛑 Stop Containers

```bash
docker stop student-notes-container
docker stop student-notes-mysql
```

---

## 🗑️ Remove Containers

```bash
docker rm student-notes-container
docker rm student-notes-mysql
```

---

## ⚠️ Development Note

This project is created for learning **Flask, MySQL, and Docker**.

The database credentials used in this project are for local development only.

For production applications, credentials should be stored using environment variables or Docker secrets.

---

## 👨‍💻 Author

**Jyotiprakash Khuntia**

GitHub: [@jyotics24](https://github.com/jyotics24)

---

⭐ If you found this project useful, feel free to star the repository!