# 🚀 Deployment Guide for WebApps2024

This guide provides multiple deployment options for your Django application.

## 📋 Prerequisites

- AWS EC2 instance running Ubuntu (IP: 52.203.137.55)
- SSH access to the server
- SSL certificates (webapps.crt and webapps.pem) in the server
- Domain configured (ec2-52-203-137-55.compute-1.amazonaws.com)

## 🎯 Deployment Options

### Option 1: Automated AWS EC2 Deployment (Recommended)

1. **From Windows (Local):**
   ```cmd
   # Run the deployment batch file
   deploy.bat
   ```

2. **On AWS EC2 Server:**
   ```bash
   # SSH into your server
   ssh ubuntu@52.203.137.55
   
   # Navigate to project directory
   cd /home/ubuntu/webapps2024
   
   # Make deployment script executable
   chmod +x deploy.sh
   
   # Run deployment
   ./deploy.sh
   ```

### Option 2: Manual Deployment

1. **SSH into server:**
   ```bash
   ssh ubuntu@52.203.137.55
   ```

2. **Clone/Update repository:**
   ```bash
   cd /home/ubuntu
   git clone -b deployment https://github.com/malogomez90/cobro2.git webapps2024
   cd webapps2024
   ```

3. **Setup Python environment:**
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements-prod.txt
   ```

4. **Configure Django:**
   ```bash
   export DJANGO_SETTINGS_MODULE=webapps2024.production_settings
   python manage.py collectstatic --noinput
   python manage.py migrate
   ```

5. **Start services:**
   ```bash
   # Copy service files (as shown in deploy.sh)
   sudo systemctl enable webapps2024
   sudo systemctl start webapps2024
   sudo systemctl enable nginx
   sudo systemctl restart nginx
   ```

### Option 3: Docker Deployment

1. **On server with Docker installed:**
   ```bash
   cd /home/ubuntu/webapps2024
   docker-compose up -d
   ```

## 🔍 Monitoring and Troubleshooting

### Check Service Status
```bash
# Check Gunicorn service
sudo systemctl status webapps2024

# Check Nginx
sudo systemctl status nginx

# View logs
sudo journalctl -u webapps2024 -f
sudo tail -f /var/log/nginx/error.log
```

### Application URLs
- **HTTP:** http://52.203.137.55
- **HTTPS:** https://52.203.137.55
- **Admin:** https://52.203.137.55/admin/

## 🔧 Configuration Files

- `deploy.sh` - Main deployment script for AWS EC2
- `deploy.bat` - Windows deployment helper
- `gunicorn.conf.py` - Gunicorn production configuration
- `webapps2024/production_settings.py` - Django production settings
- `requirements-prod.txt` - Production Python dependencies
- `Dockerfile` & `docker-compose.yml` - Docker deployment

## 🔐 Security Notes

- SSL certificates are configured for HTTPS
- Debug mode is disabled in production
- Security headers are enabled
- Database is isolated

## 📞 Support

If you encounter issues:
1. Check the logs (commands above)
2. Verify SSL certificates are in place
3. Ensure all ports (80, 443, 9090) are open in AWS Security Groups
4. Check that the domain is properly configured

## 🔄 Future Deployments

After initial setup, for future deployments:
1. Push code changes to GitHub
2. SSH into server
3. Run: `./deploy.sh`

The script will automatically pull latest changes and restart services.