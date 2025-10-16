@echo off
echo 🚀 Starting deployment process from Windows...

echo 📦 Step 1: Adding all changes to git...
git add .

echo 💾 Step 2: Committing changes...
set /p commit_msg="Enter commit message (or press Enter for default): "
if "%commit_msg%"=="" set commit_msg=Deploy: Update application for production

git commit -m "%commit_msg%"

echo 📤 Step 3: Pushing to repository...
git push origin deployment

echo ✅ Code pushed successfully to GitHub!
echo.
echo 📋 Next steps:
echo 1. SSH into your AWS EC2 server (52.203.137.55)
echo 2. Run the deployment script on the server:
echo    git clone https://github.com/malogomez90/cobro2.git /home/ubuntu/webapps2024
echo    chmod +x /home/ubuntu/webapps2024/deploy.sh
echo    /home/ubuntu/webapps2024/deploy.sh
echo.
echo 🌐 Your application will be available at:
echo    HTTP:  http://52.203.137.55
echo    HTTPS: https://52.203.137.55
echo.
pause