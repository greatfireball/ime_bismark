ARG osversion=xenial
FROM ubuntu:${osversion}

ARG VERSION=master
ARG VCS_REF
ARG BUILD_DATE

RUN echo "VCS_REF: "${VCS_REF}", BUILD_DATE: "${BUILD_DATE}", VERSION: "${VERSION}

LABEL maintainer="frank.foerster@ime.fraunhofer.de" \
      description="Dockerfile providing the bismark methylseq software" \
      version=${VERSION} \
      org.label-schema.vcs-ref=${VCS_REF} \
      org.label-schema.build-date=${BUILD_DATE} \
      org.label-schema.vcs-url="https://github.com/greatfireball/ime_bismark.git"

RUN apt update && \
    apt --yes install \
       wget \
       unzip \
       git \
       python \
       parallel \
       bzip2 && \
    apt --yes autoremove \
    && apt autoclean \
    && rm -rf /var/lib/apt/lists/* /var/log/dpkg.log

# Installation of bowtie2
WORKDIR /opt
RUN wget -O /tmp/bowtie.zip https://github.com/BenLangmead/bowtie2/releases/download/v2.3.4.1/bowtie2-2.3.4.1-linux-x86_64.zip && \
    unzip /tmp/bowtie.zip && \
    rm /tmp/bowtie.zip && \
    ln -s $PWD/bowtie2* bowtie2
ENV PATH=/opt/bowtie2/:${PATH}

# Installation of samtools
WORKDIR /opt
RUN wget -O /tmp/samtools.tar.bz2 https://github.com/samtools/samtools/releases/download/1.8/samtools-1.8.tar.bz2 && \
    cd /tmp/ && \
    tar xjf /tmp/samtools.tar.bz2 && \
    rm /tmp/samtools.tar.bz2 && \
    ln -s $PWD/samtools* samtools && \
    apt update && apt install --yes \
	build-essential \
	libncurses5-dev \
	zlib1g-dev \
	libbz2-dev \
	liblzma-dev && \
    cd samtools && \
    ./configure --prefix=/opt/samtools/ && \
    make && \
    make install && \
    rm -rf samtools* && \
    apt --yes purge \
	build-essential && \
    apt --yes autoremove \
    && apt autoclean \
    && rm -rf /var/lib/apt/lists/* /var/log/dpkg.log
ENV PATH=/opt/samtools/bin/:${PATH}

# Installation of bismark
WORKDIR /opt
RUN wget -O /tmp/bismark.zip https://github.com/FelixKrueger/Bismark/archive/v0.15.0.zip && \
    unzip /tmp/bismark.zip && \
    rm /tmp/bismark.zip && \
    ln -s $PWD/Bismark* bismark
ENV PATH=/opt/bismark/:${PATH}

# Setup of /data volume and set it as working directory
VOLUME /data
WORKDIR /data
