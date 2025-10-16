import multiprocessing
import os

def post_fork(server, worker):
    """Start Thrift server after forking worker process"""
    from thrift_timestamp.server import ThriftServerSingleton
    thrift_server = ThriftServerSingleton()
    thrift_server.start_server()

# Server socket
bind = "unix:/home/ubuntu/webapps2024/webapps2024.sock"
backlog = 2048

# Worker processes
workers = multiprocessing.cpu_count() * 2 + 1
worker_class = "sync"
worker_connections = 1000
timeout = 30
keepalive = 2

# Restart workers after this many requests, to help prevent memory leaks
max_requests = 1000
max_requests_jitter = 50

# Logging
accesslog = "/home/ubuntu/webapps2024/gunicorn-access.log"
errorlog = "/home/ubuntu/webapps2024/gunicorn-error.log"
loglevel = "info"

# Process naming
proc_name = "webapps2024"

# Server mechanics
preload_app = True
daemon = False
pidfile = "/home/ubuntu/webapps2024/gunicorn.pid"
user = "ubuntu"
group = "www-data"
tmp_upload_dir = None

# SSL Configuration (if using HTTPS directly with Gunicorn)
# certfile = '/home/ubuntu/webapps2024/webapps.crt'
# keyfile = '/home/ubuntu/webapps2024/webapps.pem'
