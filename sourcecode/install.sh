#!/bin/bash

# Update and clear screen
sudo apt update && clear

# Get public IP address
get_public_ip=$(wget -T 10 -t 1 -4qO- "http://ip1.dynupdate.no-ip.com/" || curl -m 10 -4Ls "http://ip1.dynupdate.no-ip.com/" | grep -m 1 -oE '^[0-9]{1,3}(\.[0-9]{1,3}){3}$')
read -p "Public IPv4 address / hostname [$get_public_ip]: " public_ip
until [[ -n "$get_public_ip" || -n "$public_ip" ]]; do
    echo "Invalid input."
    read -p "Public IPv4 address / hostname: " public_ip
done
[[ -z "$public_ip" ]] && public_ip="$get_public_ip"
clear

# Update and clear screen
sudo apt update
sudo apt upgrade -y
clear

# Install Node.js
echo "
################################################
#                INSTALL NODEJS                #
################################################
"
sudo apt install curl -y
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install v18.20.2
node -v

# Set up application configuration
read -p "Your sub-domain (admin.yourdomain.com): " your_domain

read -p "Your app name: " app_name

# Firebase credentials 
echo "
########################################################
#                  CONFIGURING FIREBASE                #
########################################################
"
read -p "Your apiKey: " apiKey

read -p "Your authDomain: " authDomain

read -p "Your projectId: " projectId

read -p "Your storageBucket: " storageBucket

read -p "Your messagingSenderId: " messagingSenderId

read -p "Your appId: " appId

read -p "Your measurementId: " measurementId

clear

# Mongodb User Name
mongodbUser_name=$(echo "$app_name" | tr '[:upper:]' '[:lower:]' | tr -d ' ')
echo "Your mongodb user name formatted: $mongodbUser_name"

get_shared_secret_key="5TIvw5cpc0"
read -p "Shared Secret key [5TIvw5cpc0]: " shared_secret_key
[[ -z "$shared_secret_key" ]] && shared_secret_key="$get_shared_secret_key"

get_shared_jwt_secret="2FhKmINItB"
read -p "Shared Jwt Secret [2FhKmINItB]: " shared_jwt_secret
[[ -z "$shared_jwt_secret" ]] && shared_jwt_secret="$get_shared_jwt_secret"

clear

# Install Nginx
echo "
################################################
#                INSTALL NGINX                 #
################################################
"
sudo apt install -y nginx
sudo systemctl status nginx
clear

# Configure Nginx
echo "
################################################
#                CONFIGURE NGINX               #
################################################
"
sudo tee /etc/nginx/sites-available/default > /dev/null << EOF
server {
    server_name $your_domain www.$your_domain;
    client_max_body_size 300M;

    access_log /var/log/nginx/$mongodbUser_name.access.log;
    error_log /var/log/nginx/$mongodbUser_name.error.log;

    root /path;

    location /_next/static/ {
        alias /var/www/$mongodbUser_name/frontend/.next/static/;
        expires 365d;
        access_log off;
    }

    location /storage/ {
        proxy_pass http://localhost:5000/storage/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_redirect off;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header X-Nginx-Proxy true;
    }

    location /api {
        proxy_pass http://localhost:5000; # Node.js backend port
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_redirect off;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header X-Nginx-Proxy true;
    }

    location /socket.io/ {
        proxy_pass http://localhost:5000; # Node.js backend port
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_redirect off;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header X-Nginx-Proxy true;
    }

    location / {
        proxy_pass http://localhost:5001; # Next.js frontend port
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_redirect off;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header X-Nginx-Proxy true;
    }
}
EOF
sudo systemctl restart nginx
sudo systemctl status nginx

# Secure Nginx with Let's Encrypt 
echo "
################################################
#      Secure Nginx with Let's Encrypt         #
################################################
"
cd ../..
sudo snap install core; sudo snap refresh core
sudo apt remove certbot
sudo snap install --classic certbot
sudo systemctl reload nginx
sudo certbot --nginx -d $your_domain
clear

# Install PM2
echo "
################################################
#                INSTALL PM2                   #
################################################
"
sudo apt install npm -y
npm install pm2 -g
clear

# Install MongoDB
echo "
################################################
#                INSTALL MONGODB               #
################################################
"

# Install prerequisites
apt install -y software-properties-common gnupg apt-transport-https ca-certificates curl

# Add MongoDB 8.0 GPG key and APT repository
curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc \
  | gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor

echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" \
  > /etc/apt/sources.list.d/mongodb-org-8.0.list

# Update package list and install MongoDB
apt update -y
apt install -y mongodb-org

# Check version and start MongoDB
mongod --version || true
systemctl enable --now mongod
sleep 6
systemctl status mongod --no-pager || true
ss -pnltu | grep 27017 || true

# ===== Create MongoDB Admin User with readWrite on app DB =====
echo "
################################################
#         CREATE MONGODB ADMIN + APP ROLE      #
################################################
"

# Replace $mongodbUser_name with the actual variable if using in script
cat <<EOF | mongosh
use admin
db.createUser({
  user: "admin",
  pwd: "dbadmin123",
  roles: [
    { role: "userAdminAnyDatabase", db: "admin" },
    { role: "readWrite", db: "${mongodbUser_name}" }
  ]
})
EOF

# ===== Enable MongoDB Authentication and Bind Public IP =====
echo "
################################################
#     ENABLE AUTH AND BIND TO PUBLIC IP        #
################################################
"

# Remove any existing security block
sed -i '/^#*security:/d' /etc/mongod.conf

# Add authorization under security
awk '1; END{print "security:\n  authorization: enabled"}' /etc/mongod.conf > /etc/mongod.conf.new && mv /etc/mongod.conf.new /etc/mongod.conf

# Bind to localhost and public IP
if grep -q 'bindIp:' /etc/mongod.conf; then
  sed -i "s/^ *bindIp: .*/  bindIp: 127.0.0.1,${public_ip}/" /etc/mongod.conf
else
  sed -i "/^net:/a\  bindIp: 127.0.0.1,${public_ip}" /etc/mongod.conf
fi

# Restart MongoDB with new config
systemctl restart mongod
sleep 5
systemctl status mongod --no-pager || true
clear

# Install backend dependencies
echo "
################################################
#                INSTALL BACKEND               #
################################################
"
cd /home/admin/backend || exit
npm install
cat > .env << EOF
#Port
PORT = 5000

#Project Name
projectName = ${app_name}

#Secret key for jwt
JWT_SECRET = ${shared_jwt_secret}

#Server URL
baseURL = https://$your_domain

#Secret key for API
secretKey = ${shared_secret_key}

#Mongodb string
MongoDb_Connection_String = mongodb://admin:dbadmin123@${public_ip}:27017/${mongodbUser_name}?authSource=admin
EOF

cd /home/admin/backend || exit
pm2 start index.js --name backend
pm2 status
node -v
pm2 restart backend --interpreter $(which node)

# Install frontend dependencies and build
echo "
################################################
#                INSTALL FRONTEND              #
################################################
"
cd /home/admin/frontend/src || exit
cat > config.js << EOF
export const baseURL = "https://$your_domain"
export const secretKey = "$shared_secret_key"
export const projectName = "$app_name"
export const firebase_apiKey = "$apiKey"
export const firebase_authDomain = "$authDomain"
export const firebase_projectId = "$projectId"
export const firebase_storageBucket = "$storageBucket"
export const firebase_messagingSenderId = "$messagingSenderId"
export const firebase_appId = "$appId"
export const firebase_measurementId = "$measurementId"
EOF

cd /var/www || exit
sudo mkdir -p "$mongodbUser_name/frontend"
sudo mv /home/admin/frontend/* /var/www/$mongodbUser_name/frontend/
export PATH="$PATH:$HOME/.nvm/versions/node/v18.20.2/bin"
source ~/.bashrc
cd /var/www/$mongodbUser_name/frontend || exit
npm install
npm run build

# Start frontend with PM2
pm2 start npm --name "frontend" -- start
pm2 restart frontend --interpreter $(which node)

echo "
################################################
#                CONGRATULATIONS!              #
################################################
Server setup is complete.
1. baseURL : https://$your_domain/
2. Secret key : $shared_secret_key
3. MONGODB_CONNECTION_STRING: "mongodb://admin:dbadmin123@${public_ip}:27017/${mongodbUser_name}?authSource=admin"
"