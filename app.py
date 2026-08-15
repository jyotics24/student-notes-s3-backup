from flask import Flask, render_template, request, redirect
import mysql.connector

# Create the Flask application
app = Flask(__name__)


# Function to establish a connection with the MySQL database
def get_db():
    return mysql.connector.connect(
        # MySQL container name on the Docker network
        host="student-notes-mysql",

        # MySQL username
        user="root",

        # MySQL root password
        password="root",

        # Database created inside the MySQL container
        database="student_notes"
    )


# Route for the home page
@app.route("/")
def index():
    # Connect to the MySQL database
    db = get_db()

    # Create a cursor that returns database rows as dictionaries
    cursor = db.cursor(dictionary=True)

    # Get all notes, showing the newest note first
    cursor.execute("SELECT * FROM notes ORDER BY id DESC")

    # Store all database results in the notes variable
    notes = cursor.fetchall()

    # Close the cursor and database connection
    cursor.close()
    db.close()

    # Send the notes to the index.html template
    return render_template("index.html", notes=notes)


# Route used to add a new note
# Only POST requests are allowed
@app.route("/add", methods=["POST"])
def add_note():
    # Get the title submitted from the HTML form
    title = request.form["title"]

    # Get the content submitted from the HTML form
    content = request.form["content"]

    # Connect to the MySQL database
    db = get_db()

    # Create a database cursor
    cursor = db.cursor()

    # Insert the new note into the notes table
    # %s placeholders safely pass user input to the SQL query
    cursor.execute(
        "INSERT INTO notes (title, content) VALUES (%s, %s)",
        (title, content)
    )

    # Save the changes to the database
    db.commit()

    # Close the cursor and database connection
    cursor.close()
    db.close()

    # Redirect the user back to the home page
    return redirect("/")


# Route used to delete a note
# <int:id> means the note ID is expected to be an integer
@app.route("/delete/<int:id>")
def delete_note(id):
    # Connect to the MySQL database
    db = get_db()

    # Create a database cursor
    cursor = db.cursor()

    # Delete the note with the specified ID
    cursor.execute(
        "DELETE FROM notes WHERE id = %s",
        (id,)
    )

    # Save the deletion
    db.commit()

    # Close the cursor and database connection
    cursor.close()
    db.close()

    # Redirect back to the home page
    return redirect("/")


# Start the Flask application
if __name__ == "__main__":
    # Listen on all network interfaces
    # Port 5000 is the port inside the Docker container
    app.run(host="0.0.0.0", port=5000)