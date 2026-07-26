FROM nginx:alpine
COPY site/ /usr/share/nginx/html/
RUN echo 'server { \
    listen 80; \
    server_name localhost; \
    root /usr/share/nginx/html; \
    index index.html; \
    charset utf-8; \
    location / { try_files $uri $uri/ $uri.html =404; } \
}' > /etc/nginx/conf.d/default.conf
EXPOSE 80
