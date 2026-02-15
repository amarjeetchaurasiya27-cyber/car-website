# Step 1: Base image chuna (Nginx ka stable version)
FROM nginx:alpine

# Step 2: Website ka sara samaan Nginx ke default folder mein copy karna
# Aapka code agar kisi folder mein hai toh 'copy' command ko us hisab se badlein
COPY . /usr/share/nginx/html/

# Step 3: Nginx default port (80) ko expose karna
EXPOSE 80

# Step 4: Nginx ko background mein na chalakar foreground mein chalana 
# Taaki Docker container zinda rahe
CMD ["nginx", "-g", "daemon off;"]
