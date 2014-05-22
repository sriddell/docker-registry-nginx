FROM registry

# Install Nginx.
RUN apt-get update
RUN apt-get install -y nginx
RUN apt-get install -y nginx-extras
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf
RUN chown -R www-data:www-data /var/lib/nginx

ADD nginx.conf /etc/nginx/
ADD htpasswd /etc/nginx/
ADD ssl/server.crt /etc/nginx/ssl/
ADD ssl/server.key /etc/nginx/ssl/

expose 8000
expose 5000

#cmd exec docker-registry && nginx
cmd nginx && exec docker-registry