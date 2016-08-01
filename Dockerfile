FROM ubuntu:14.04
MAINTAINER Bizruntime


#installing dependice for odoo  python
RUN apt-get -y update && apt-get -y install python  python-pip python-dev libevent-dev gcc libxml2-dev libxslt-dev libldap2-dev  && \
                 apt-get -y install  libssl-dev libsasl2-dev  libpq-dev  node-less openssh-server  nano && \
         apt-get -y install wget git && apt-get -y install curl  node-clean-css  python-pyinotify  python-renderpm  python-support 

RUN apt-get -y install postgresql-client

RUN cd /tmp && wget https://raw.githubusercontent.com/odoo/odoo/9.0/requirements.txt && pip install -r requirements.txt

# Copy over private key, and set permissions
ADD id_rsa  /root/.ssh/id_rsa
ADD id_rsa.pub /root/.ssh/id_rsa.pub

# Create known_hosts
RUN touch /root/.ssh/known_hosts
RUN chmod 600 root/.ssh/*
RUN echo "Host bitbucket.org\n\tStrictHostKeyChecking no\n" >> /root/.ssh/*

# Add bitbuckets key
RUN ssh-keyscan bitbucket.org >> /root/.ssh/known_hosts

RUN mkdir  /opt/odoo
RUN useradd --create-home --password odoo odoo

RUN git clone  git@bitbucket.org:pramod08/odoofilesystem-9.0.git  /opt/odoo

USER root

RUN chown --recursive odoo:odoo /opt/odoo/*


ADD odoo-server.conf /etc/odoo/odoo-server.conf

RUN chown odoo: /etc/odoo/odoo-server.conf && chmod 640 /etc/odoo/odoo-server.conf


#ADD odoo-server /etc/init.d/odoo-server
#RUN chmod 755 /etc/init.d/odoo-server && chown root: /etc/init.d/odoo-server
#RUN mkdir /var/log/odoo 
#RUN /var/log/odoo/cat > odoo-server.log

#RUN chmod 755 /var/log/odoo/odoo-server.log && chown odoo:root -R /var/log/odoo/

# Expose Odoo services
EXPOSE 8069 8071


WORKDIR /opt/odoo


RUN python setup.py install 


COPY  run.sh /opt/run.sh 
RUN chmod 777 /opt/run.sh
#USER odoo
#CMD ["openerp-server -c /etc/odoo/odoo-server.conf "]
USER odoo
CMD ["/opt/run.sh"]


