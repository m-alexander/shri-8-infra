FROM nginx
COPY dist/* /usr/share/nginx/html

# docker run -p 8080:80 infra:latest
