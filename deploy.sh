#!/bin/bash

# Django Deployment Script for AWS EC2
# This script deploys the Django application to production server

set -e  # Exit on any error

echo "🚀 Starting deployment process..."

# Configuration
PROJECT_NAME="webapps2024"
PROJECT_DIR="/home/ubuntu/webapps2024"
REPO_URL="https://github.com/malogomez90/cobro2.git"
BRANCH="deployment"
PYTHON_ENV="/home/ubuntu/webapps2024/venv"

echo "📦 Step 1: Updating system packages..."
sudo apt-get update -y

echo "🔄 Step 2: Installing required system packages..."
sudo apt-get install -y python3-pip python3-venv git nginx supervisor

echo "📁 Step 3: Setting up project directory..."
if [ ! -d "$PROJECT_DIR" ]; then
    sudo mkdir -p $PROJECT_DIR
    sudo chown ubuntu:ubuntu $PROJECT_DIR
fi

cd $PROJECT_DIR

echo "📥 Step 4: Pulling latest code from Git..."
if [ -d ".git" ]; then
    echo "Repository exists, pulling latest changes..."
    git fetch origin
    git reset --hard origin/$BRANCH
else
    echo "Cloning repository..."
    git clone -b $BRANCH $REPO_URL .
fi

echo "🐍 Step 5: Setting up Python virtual environment..."
if [ ! -d "$PYTHON_ENV" ]; then
    python3 -m venv $PYTHON_ENV
fi

source $PYTHON_ENV/bin/activate

echo "📦 Step 6: Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements.txt
pip install gunicorn

echo "🗄️ Step 7: Setting up database..."
python manage.py collectstatic --noinput
python manage.py migrate

echo "🔧 Step 8: Setting up Gunicorn service..."
sudo tee /etc/systemd/system/webapps2024.service > /dev/null <<EOF
[Unit]
Description=Gunicorn instance to serve webapps2024
After=network.target

[Service]
User=ubuntu
Group=www-data
WorkingDirectory=$PROJECT_DIR
Environment="PATH=$PYTHON_ENV/bin"
ExecStart=$PYTHON_ENV/bin/gunicorn --config gunicorn.conf.py webapps2024.wsgi:application
ExecReload=/bin/kill -s HUP \$MAINPID
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

echo "🌐 Step 9: Setting up Nginx..."
sudo tee /etc/nginx/sites-available/webapps2024 > /dev/null <<EOF
server {
    listen 80;
    server_name 52.203.137.55 ec2-52-203-137-55.compute-1.amazonaws.com;

    location = /favicon.ico { access_log off; log_not_found off; }
    
    location /static/ {
        root $PROJECT_DIR;
    }

    location / {
        include proxy_params;
        proxy_pass http://unix:$PROJECT_DIR/webapps2024.sock;
    }
}

server {
    listen 443 ssl;
    server_name 52.203.137.55 ec2-52-203-137-55.compute-1.amazonaws.com;

    ssl_certificate /home/ubuntu/webapps2024/webapps.crt;
    ssl_certificate_key /home/ubuntu/webapps2024/webapps.pem;

    location = /favicon.ico { access_log off; log_not_found off; }
    
    location /static/ {
        root $PROJECT_DIR;
    }

    location / {
        include proxy_params;
        proxy_pass https://127.0.0.1:443;
    }
}
EOF

# Enable the site
sudo ln -sf /etc/nginx/sites-available/webapps2024 /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

echo "🔄 Step 10: Starting services..."
sudo systemctl daemon-reload
sudo systemctl enable webapps2024
sudo systemctl restart webapps2024
sudo systemctl enable nginx
sudo systemctl restart nginx

echo "🔍 Step 11: Checking service status..."
sudo systemctl status webapps2024 --no-pager -l
sudo systemctl status nginx --no-pager -l

echo "✅ Deployment completed successfully!"
echo "🌐 Your application should now be available at:"
echo "   HTTP:  http://52.203.137.55"
echo "   HTTPS: https://52.203.137.55"
echo ""
echo "📊 To check logs:"
echo "   Gunicorn: sudo journalctl -u webapps2024 -f"
echo "   Nginx:    sudo tail -f /var/log/nginx/error.log"