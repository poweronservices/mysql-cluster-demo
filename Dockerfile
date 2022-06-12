FROM mysql:8.0.29-debian

RUN apt-get update && apt-get install -y curl
RUN curl https://cdn.mysql.com//Downloads/MySQL-Shell/mysql-shell_8.0.29-1debian10_amd64.deb > mysql-shell.deb
RUN dpkg -i mysql-shell.deb
