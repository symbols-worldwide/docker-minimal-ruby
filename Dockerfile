FROM alpine:3.4

MAINTAINER Simon Detheridge <simon@widgit.com>

ARG ruby=2.3.0

ENV RUBY_VERSION $ruby
ENV RVM_USER root
ENV RVM_GROUP rvm

ENV PACKAGES gnupg curl bash procps musl zlib openssl libssl1.0 patch make
ENV DEV_PACKAGES gcc gnupg musl-dev linux-headers zlib-dev openssl-dev

# Grab RVM, install, compile Ruby and nuke the build tools

RUN apk update && \
    apk upgrade && \
    apk add $PACKAGES $DEV_PACKAGES && \
    addgroup $RVM_GROUP && \
    gpg --keyserver hkp://keys.gnupg.net --recv-keys \
      409B6B1796C275462A1703113804BB82D39DC0E3 && \
    cd && \
    curl -L -o stable.tar.gz \
      https://github.com/rvm/rvm/archive/stable.tar.gz && \
    gunzip -c stable.tar.gz | tar xf - && \
    cd rvm-stable && ./scripts/install && \
    bash -c "source /etc/profile.d/rvm.sh && rvm install $RUBY_VERSION --disable-binary --autolibs=0 --movable" && \
    cd && \
    apk del $DEV_PACKAGES && \
    rm -rf stable.tar.gz rvm-stable /var/cache/apk* && \
    rm -rf /usr/local/rvm/src/* /usr/local/rvm/archives/* /usr/local/rvm/log/*

ENTRYPOINT ["/bin/bash","-lc"]
CMD ["/bin/bash"]

RUN echo 'source /etc/profile > /dev/null 2>&1' >> ~/.bashrc

