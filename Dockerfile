FROM centos:centos7

# This image is the base image for all DeployDock language Docker images.
MAINTAINER Eric Sites <eric@meros.io>

# Location of the STI scripts inside the image
#
LABEL io.deploydock.s2i.scripts-url=image:///usr/local/sti

# DEPRECATED: This label will be kept here for backward compatibility
LABEL io.s2i.scripts-url=image:///usr/local/sti

# Deprecated. Use above LABEL instead, because this will be removed in future versions.
ENV STI_SCRIPTS_URL=image:///usr/local/sti

# The $HOME is not set by default, but some applications needs this variable
ENV HOME=/opt/app-root/src \
    PATH=/opt/app-root/src/bin:/opt/app-root/bin:/usr/local/sti:$PATH

# When bash is started non-interactively, to run a shell script, for example it
# looks for this variable and source the content of this file. This will enable
# the SCL for all scripts without need to do 'scl enable'.
ADD contrib/scl_enable /opt/app-root/etc/scl_enable
ENV BASH_ENV=/opt/app-root/etc/scl_enable \
    ENV=/opt/app-root/etc/scl_enable \
    PROMPT_COMMAND=". /opt/app-root/etc/scl_enable"

# This is the list of basic dependencies that all language Docker image can
# consume.
# Also setup the 'deploydock' user that is used for the build execution and for the
# application runtime execution.
# TODO: Use better UID and GID values
RUN rpmkeys --import file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 && \
  yum install -y --setopt=tsflags=nodocs \
  autoconf \
  automake \
  bsdtar \
  epel-release \
  findutils \
  gcc-c++ \
  gdb \
  gettext \
  git \
  libcurl-devel \
  libxml2-devel \
  libxslt-devel \
  lsof \
  make \
  mariadb-devel \
  mariadb-libs \
  openssl-devel \
  patch \
  postgresql-devel \
  procps-ng \
  scl-utils \
  sqlite-devel \
  tar \
  unzip \
  wget \
  which \
  yum-utils \
  zlib-devel && \
  yum clean all -y && \
  mkdir -p ${HOME} && \
  useradd -u 1001 -r -g 0 -d ${HOME} -s /sbin/nologin \
      -c "Default Application User" default && \
  chown -R 1001:0 /opt/app-root

# Create directory where the image STI scripts will be located
# Install the base-usage script with base image usage informations
ADD bin/base-usage /usr/local/sti/base-usage

# Use entrypoint so path is correctly adjusted already at the time the command
# is searching, so something like docker run IMG python runs binary from SCL
ADD bin/container-entrypoint /usr/bin/container-entrypoint

# Directory with the sources is set as the working directory so all STI scripts
# can execute relative to this path
WORKDIR ${HOME}

ENTRYPOINT ["container-entrypoint"]
CMD ["base-usage"]
