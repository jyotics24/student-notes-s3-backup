Paste this:

# 📚 Student Notes App


A simple Student Notes application built with **Flask**, **MySQL**, and **Docker**.


The application allows users to:


- Add student notes
- View all notes
- Delete notes
- Store notes in a MySQL database
- Run Flask and MySQL in separate Docker containers


---


## 🛠️ Technologies Used


- Python 3.11
- Flask
- MySQL
- MySQL Connector/Python
- Docker
- HTML/CSS


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
🐳 Docker Setup

The Flask application runs inside a Docker container.

The application container listens on:

5000

The host exposes it on:

5001

So the application can be accessed at:

http://localhost:5001
🗄️ MySQL Container

The application uses a separate MySQL container.

The MySQL container is connected to the Flask container using a Docker bridge network.

Example:

docker network create student-notes-network

Create the MySQL container:

docker run -d \
  --name student-notes-mysql \
  --network student-notes-network \
  -e MYSQL_ROOT_PASSWORD=root \
  -e MYSQL_DATABASE=student_notes \
  mysql:latest
🗃️ Create the Notes Table

After the MySQL container starts, create the notes table:

docker exec -it student-notes-mysql \
mysql -uroot -proot student_notes \
-e "CREATE TABLE notes (
id INT AUTO_INCREMENT PRIMARY KEY,
title VARCHAR(255) NOT NULL,
content TEXT NOT NULL
);"
🔨 Build the Flask Docker Image

From the project directory:

docker build -t student-notes-app .
▶️ Run the Flask Container

Run the Flask application on the Docker network:

docker run -d \
  -p 5001:5000 \
  --name student-notes-container \
  --network student-notes-network \
  student-notes-app
🌐 Open the Application

Open your browser and visit:

http://localhost:5001
🔌 Database Configuration

The Flask application connects to MySQL using the MySQL container name:

host="student-notes-mysql"

Database configuration:

Host: student-notes-mysql
User: root
Password: root
Database: student_notes
Port: 3306

Because both containers are on the same Docker network, the Flask container can communicate with MySQL using the container name.

📋 Useful Docker Commands

Check running containers:

docker ps

Check all containers:

docker ps -a

View Flask logs:

docker logs student-notes-container

View MySQL logs:

docker logs student-notes-mysql

Check Docker networks:

docker network ls

Inspect the application network:

docker inspect student-notes-network
🧹 Stop Containers
docker stop student-notes-container
docker stop student-notes-mysql

Remove containers:

docker rm student-notes-container
docker rm student-notes-mysql
⚠️ Important

This project is intended for learning Docker, Flask, and MySQL.

The database credentials used in this project are for local development only and should not be used in a production environment.

For production, use environment variables or Docker secrets instead of storing passwords directly in the application.

👩‍💻 Author

Jyotiprakash Khuntia

GitHub: https://github.com/jyotics24