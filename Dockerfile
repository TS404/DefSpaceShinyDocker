# "ported" by Adam Miller <maxamillion@fedoraproject.org> from
#   https://github.com/fedora-cloud/Fedora-Dockerfiles
#
# Originally written for Fedora-Dockerfiles by
#   "Scott Collier" <scollier@redhat.com>
#   
# Taken from https://github.com/CentOS/CentOS-Dockerfiles/tree/master/httpd/centos7
# by Benji Wakely <b.wakely@latrobe.edu.au>, 20150116
# Adapted from https://github.com/iracooke/AlignStatShinyDocker/blob/master/Dockerfile
# by Thomas Shafee <t.shafee@latrobe.edu.au>, 20171121

# "supervisor"-ness taken from http://tiborsimko.org/docker-running-multiple-processes.html

# After build / for first-run setup, see /data/docker/shiny/READTHIS for steps
# relating to mounting host-directories for persistence,
# changing permissions on those directories etc.

# Use for standalone builds
FROM centos:latest

#FROM docker-io-centos-with-ssh:latest
LABEL maintainer Benji Wakely <b.wakely@latrobe.edu.au>

RUN yum install -y epel-release

RUN yum update -y

RUN yum install -y cmake \
					make \
					gcc \
					g++ \
					git \
					hostname \
					openssh-server \
					supervisor \
                    wget \
                    openssl-devel libcurl-devel

RUN yum install -y R && \
	yum clean all

RUN groupadd -g 600 shiny && useradd -u 600 -g 600 -r -m shiny

# Note: /var/log/shiny-server needs to be mounted from the host at run-time, so creating it here
# won't actually do anything.  But just in case the build process needs it...
RUN mkdir -p /var/log/shiny-server /srv/shiny-server /var/lib/shiny-server /etc/shiny-server && \
	chown -R shiny /var/log/shiny-server

RUN R -e "install.packages('shiny', repos='https://cran.rstudio.com/')"

RUN wget https://download3.rstudio.org/centos5.9/x86_64/shiny-server-1.5.3.838-rh5-x86_64.rpm
RUN yum install -y --nogpgcheck shiny-server-1.5.3.838-rh5-x86_64.rpm

RUN mkdir -p /usr/share/doc/R-3.4.0/html/ 

RUN R -e "install.packages(c('rmarkdown'), repos='https://cran.rstudio.com/')"

RUN R -e "install.packages(c('devtools'), repos='https://cran.rstudio.com/')"

RUN R -e "install.packages(c('rglwidget'), repos='https://cran.rstudio.com/')"
RUN R -e "install.packages(c('rgl'), repos='https://cran.rstudio.com/')"
RUN R -e "install.packages(c('ggplot2'), repos='https://cran.rstudio.com/')"
RUN R -e "install.packages(c('Biostrings'), repos='https://cran.rstudio.com/')"
RUN R -e "install.packages(c('DECIPHER'), repos='https://cran.rstudio.com/')"
RUN R -e "install.packages(c('mclust'), repos='https://cran.rstudio.com/')"
RUN R -e "install.packages(c('tidyr'), repos='https://cran.rstudio.com/')"
RUN R -e "install.packages(c('rJava'), repos='https://cran.rstudio.com/')"

# RUN R -e 'devtools::install_github("TS404/DefSpaceShiny")'

RUN wget https://github.com/TS404/DefSpaceShiny/archive/v1.0.1.zip && \
    unzip v1.0.1.zip && \
    mkdir -p /srv/shiny-server/defspace && \
    cp DefSpaceShiny-1.0.1/*.R /srv/shiny-server/defspace/

# Make empty favicon
RUN mkdir -p /www &&\
    touch /www/favicon.ico

# This is the port that the docker container expects to recieve communications on.
# 
EXPOSE 3838

COPY shiny-server.conf /etc/shiny-server/

CMD ["/usr/bin/shiny-server"]
