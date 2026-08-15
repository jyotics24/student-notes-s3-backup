# Use the official Python 3.11 slim image as the base image
FROM python:3.11-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the dependency file into the container
COPY requirements.txt .

# Install Python dependencies without storing pip's cache
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application files into the container
COPY . .

# Document that the application listens on port 5000
EXPOSE 5000

# Start the Flask/Python application
CMD ["python", "app.py"]
