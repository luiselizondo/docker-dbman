FROM ubuntu:14.04
MAINTAINER Luis Elizondo "lelizondo@gmail.com"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get dist-upgrade -y
RUN apt-get update --fix-missing
RUN apt-get -qy install nginx
RUN apt-get -y install git curl supervisor
RUN apt-get -y install nodejs npm

RUN apt-get update --fix-missing

## Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN apt-get autoremove -y

RUN ln -s /usr/bin/nodejs /usr/local/bin/node

# Ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN git clone https://github.com/luiselizondo/dbman.git /var/www
RUN cd /var/www ; npm install
RUN npm install -g bower
RUN cd /var/www ; bower install --allow-root
RUN npm install -g dbmancli

# Copy supervisor configuration
ADD ./config/nginx.conf /etc/nginx/nginx.conf
ADD ./config/vhost.conf /etc/nginx/sites-enabled/default
ADD ./config/supervisord.conf /etc/supervisor/conf.d/supervisord-dbman.conf

EXPOSE 80

ENV MONGODB_DATABASE dbman
ENV NODE_ENV production

VOLUME ["/var/files"]
WORKDIR /var/www

CMD ["/usr/bin/supervisord", "-n"]