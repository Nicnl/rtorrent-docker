FROM alpine:3.7 AS builder

ENV \
  SHA256_LIBTORRENT=34317d6783b7f8d0805274c9467475b5432a246c0de8e28fc16e3b0b43f35677 \
  SHA256_RTORRENT=9e93ca41beb1afe74ad7ad8013e0d53ae3586c9b0e97263d722f721535cc7310 \
  URL_LIBTORRENT=http://rtorrent.net/downloads/libtorrent-0.13.3.tar.gz \
  URL_RTORRENT=http://rtorrent.net/downloads/rtorrent-0.9.3.tar.gz \
  TAR_LIBTORRENT=libtorrent-0.13.3.tar.gz \
  TAR_RTORRENT=rtorrent-0.9.3.tar.gz \
  DIR_LIBTORRENT=libtorrent-0.13.3 \
  DIR_RTORRENT=rtorrent-0.9.3

RUN apk add --update --no-cache -X http://dl-cdn.alpinelinux.org/alpine/v3.6/main \
    g++ \
    curl \
    curl-dev \
    libcurl \
    ncurses-libs \
    ncurses-dev \
    zlib \
    zlib-dev \
    openssl \
    openssl-dev \
    make \
    automake \
    autoconf \
    libtool \
    linux-headers \
    ca-certificates \
    libssh2 \
    libcurl \
    libgcc \
    ncurses-terminfo-base \
    ncurses-terminfo \
    ncurses-libs \
    libstdc++ \
    libxml2 \
    libxml2-dev \
    xmlrpc-c-abyss \
    xmlrpc-c-client \
    xmlrpc-c-client++ \
    xmlrpc-c \
    xmlrpc-c++ \
    xmlrpc-c-dev \
    cppunit==1.13.2-r1 \
    cppunit-dev==1.13.2-r1 \
    libsigc++ \
    libsigc++-dev

#RUN apk --no-cache --update add --virtual build-dependencies rtorrent

WORKDIR /root

ADD $URL_LIBTORRENT /root/
ADD $URL_RTORRENT /root/

RUN echo "$SHA256_LIBTORRENT  $TAR_LIBTORRENT" | sha256sum -c
RUN echo "$SHA256_RTORRENT  $TAR_RTORRENT" | sha256sum -c

RUN tar xvf $TAR_LIBTORRENT
RUN tar xvf $TAR_RTORRENT

RUN mkdir /output
RUN cd $DIR_LIBTORRENT && \
  ./autogen.sh && \
  ./configure && \
  make -j 8 && \
  make install && \
  ./configure --prefix=/output && \
  make install

RUN cd $DIR_RTORRENT && \
  ./autogen.sh && \
  ./configure --prefix=/output --with-xmlrpc-c && \
  make -j 8 && \
  make install

####################################################################################################

FROM alpine:3.7

# Commented out build dependencies
RUN apk add --update --no-cache -X http://dl-cdn.alpinelinux.org/alpine/v3.6/main \
#    g++ \
    curl \
#    curl-dev \
    libcurl \
    ncurses-libs \
#    ncurses-dev \
    zlib \
#    zlib-dev \
    openssl \
#    openssl-dev \
#    make \
#    automake \
#    autoconf \
#    libtool \
#    linux-headers \
    ca-certificates \
    libssh2 \
    libcurl \
    libgcc \
    ncurses-terminfo-base \
    ncurses-terminfo \
    ncurses-libs \
    libstdc++ \
    libxml2 \
#    libxml2-dev \
#    xmlrpc-c-dev \
    xmlrpc-c-abyss \
    xmlrpc-c-client \
    xmlrpc-c-client++ \
    xmlrpc-c \
    xmlrpc-c++ \
    cppunit==1.13.2-r1 \
#    cppunit-dev==1.13.2-r1 \
#    libsigc++-dev \
    libsigc++


COPY --from=builder /output /

CMD ["/bin/rtorrent"]
