FROM alpine:3.14 as base
LABEL maintainer="David Chidell (dchidell@cisco.com)"
ENV VERSION=202109260929
ENV TAC_PLUS_BIN=/tacacs/sbin/tac_plus

FROM base as webproc
ENV WEBPROCVERSION 0.4.0
ENV WEBPROCURL https://github.com/jpillora/webproc/releases/download/v$WEBPROCVERSION/webproc_"$WEBPROCVERSION"_linux_amd64.gz
RUN apk add --no-cache curl
RUN curl -sL $WEBPROCURL | gzip -d - > /usr/local/bin/webproc
RUN chmod +x /usr/local/bin/webproc

FROM base as build
RUN apk add --no-cache \
    build-base bzip2 perl perl-digest-md5 perl-ldap
ADD http://www.pro-bono-publico.de/projects/src/DEVEL.$VERSION.tar.bz2 /tac_plus.tar.bz2
RUN tar -xjf /tac_plus.tar.bz2 && \
    cd /PROJECTS && \
    ./configure --prefix=/tacacs && \
    make && \
    make install

FROM base as tacacs
RUN apk add --no-cache perl-digest-md5 perl-ldap
COPY --from=build /tacacs /tacacs
COPY --from=webproc /usr/local/bin/webproc /usr/local/bin/webproc
COPY tac_base.cfg /etc/tac_plus/tac_base.cfg
COPY tac_user.cfg /etc/tac_plus/tac_user.cfg
#COPY entrypoint.sh /entrypoint.sh 
ENTRYPOINT ["webproc","-o","restart","-s","continue","-c","/etc/tac_plus/tac_user.cfg","-c","/etc/tac_plus/tac_base.cfg","--","/tacacs/sbin/tac_plus","-f","/etc/tac_plus/tac_base.cfg"]
EXPOSE 49 8080
