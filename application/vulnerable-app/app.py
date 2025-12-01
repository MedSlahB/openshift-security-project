#!/usr/bin/env python3
from flask import Flask, request, render_template_string, jsonify
import os
import sqlite3
import subprocess
from datetime import datetime

app = Flask(__name__)

def init_db():
    conn = sqlite3.connect('vulnerable.db')
    cursor = conn.cursor()
    cursor.execute('''CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        email TEXT)''')
    cursor.execute('''CREATE TABLE IF NOT EXISTS comments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        comment TEXT,
        created_at TIMESTAMP)''')
    cursor.execute("INSERT OR IGNORE INTO users (id, username, password, email) VALUES (1, 'admin', 'admin123', 'admin@example.com')")
    cursor.execute("INSERT OR IGNORE INTO users (id, username, password, email) VALUES (2, 'user', 'password', 'user@example.com')")
    conn.commit()
    conn.close()

init_db()

HOME_TEMPLATE = '''<!DOCTYPE html>
<html><head><title>Vulnerable App</title>
<style>body{font-family:Arial;margin:40px;background:#f0f0f0}
.container{background:white;padding:30px;border-radius:10px}
h1{color:#d9534f}.vulnerability{background:#fff3cd;padding:15px;margin:10px 0}
.warning{color:#d9534f;font-weight:bold}
input,textarea{width:100%;padding:8px;margin:5px 0}
button{background:#007bff;color:white;padding:10px 20px;border:none;border-radius:5px}
</style></head><body><div class="container">
<h1>Vulnerable Application</h1><p class="warning">WARNING: Contains vulnerabilities!</p>
<h2>Endpoints:</h2><div class="vulnerability"><h3>1. SQL Injection</h3>
<p>Try: <code>/search?username=admin' OR '1'='1</code></p></div>
<div class="vulnerability"><h3>2. XSS</h3><form action="/comment" method="POST">
<input type="text" name="comment" placeholder="Comment"><button type="submit">Submit</button></form></div>
<div class="vulnerability"><h3>3. Command Injection</h3><p>Try: <code>/ping?host=localhost;ls</code></p></div>
<h2>Comments:</h2><div>{{ comments|safe }}</div>
<h2>Health:</h2><p>Status: <span style="color:green">Running</span></p>
<p>Version: 1.0.0</p><p>Time: {{ timestamp }}</p></div></body></html>'''

@app.route('/')
def home():
    conn = sqlite3.connect('vulnerable.db')
    cursor = conn.cursor()
    cursor.execute("SELECT comment, created_at FROM comments ORDER BY created_at DESC LIMIT 10")
    comments = cursor.fetchall()
    conn.close()
    comments_html = ""
    for comment, created_at in comments:
        comments_html += f"<div>{comment} - {created_at}</div>"
    return render_template_string(HOME_TEMPLATE, comments=comments_html, timestamp=datetime.now().strftime('%Y-%m-%d %H:%M:%S'))

@app.route('/health')
def health():
    return jsonify({'status': 'healthy', 'timestamp': datetime.now().isoformat()})

@app.route('/search')
def search():
    username = request.args.get('username', '')
    conn = sqlite3.connect('vulnerable.db')
    cursor = conn.cursor()
    query = f"SELECT * FROM users WHERE username = '{username}'"
    try:
        cursor.execute(query)
        results = cursor.fetchall()
        conn.close()
        return jsonify({'query': query, 'results': results, 'vulnerability': 'SQL Injection'})
    except Exception as e:
        conn.close()
        return jsonify({'error': str(e), 'query': query}), 500

@app.route('/comment', methods=['POST'])
def add_comment():
    comment = request.form.get('comment', '')
    conn = sqlite3.connect('vulnerable.db')
    cursor = conn.cursor()
    cursor.execute("INSERT INTO comments (comment, created_at) VALUES (?, ?)", (comment, datetime.now()))
    conn.commit()
    conn.close()
    return f'<html><body><h2>Comment added!</h2><p>{comment}</p><a href="/">Back</a></body></html>'

@app.route('/ping')
def ping():
    host = request.args.get('host', 'localhost')
    try:
        result = subprocess.check_output(f'ping -c 1 {host}', shell=True, stderr=subprocess.STDOUT)
        return jsonify({'command': f'ping -c 1 {host}', 'output': result.decode(), 'vulnerability': 'Command Injection'})
    except subprocess.CalledProcessError as e:
        return jsonify({'error': e.output.decode()}), 500

@app.route('/env')
def show_env():
    return jsonify({'environment': dict(os.environ), 'vulnerability': 'Data Exposure'})

@app.route('/metrics')
def metrics():
    conn = sqlite3.connect('vulnerable.db')
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM users")
    user_count = cursor.fetchone()[0]
    cursor.execute("SELECT COUNT(*) FROM comments")
    comment_count = cursor.fetchone()[0]
    conn.close()
    return f"""# HELP app_users_total Total users
# TYPE app_users_total gauge
app_users_total {user_count}
# HELP app_comments_total Total comments
# TYPE app_comments_total gauge
app_comments_total {comment_count}
# HELP app_up Application status
# TYPE app_up gauge
app_up 1
""", 200, {'Content-Type': 'text/plain'}

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, debug=True)
