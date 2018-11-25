# Dockerfile for ShadowsocksR
# https://raw.githubusercontent.com/teddysun/shadowsocks_install/master/shadowsocksR.sh

FROM debian:stretch

LABEL maintainer="Wang Jie <tiantian.china.2@gmail.com>"

# prepare
RUN apt-get update \
  && apt-get install -y procps \
  && apt-get install -y wget \
  && rm -rf /var/lib/apt/lists/* \
  && export PATH=$PATH:/usr/local/bin:/usr/bin:/bin:/sbin:/usr/local/games:/usr/games

# install ssr
RUN cd /usr/local \
  && mkdir ssr \
  && cd ssr \
  && wget --no-check-certificate https://raw.githubusercontent.com/teddysun/shadowsocks_install/master/shadowsocksR.sh \
  && chmod +x shadowsocksR.sh \
  && \n | ./shadowsocksR.sh 2>&1 | tee shadowsocksR.log \
  && \n; exit 0

# ssr configuration
COPY shadowsocks.json /etc/

# ssr script
RUN cd /usr/local/ssr \
  # fake log
  && touch fake_log.log \
  # start.sh
  && touch start.sh \
  && echo 'python /usr/local/shadowsocks/server.py -c /etc/shadowsocks.json -d start && tail -f /usr/local/ssr/fake_log.log' > start.sh \
  && chmod 775 start.sh \
  # stop.sh
  && touch stop.sh \
  && echo 'python /usr/local/shadowsocks/server.py -c /etc/shadowsocks.json -d stop' > stop.sh \
  && chmod 775 stop.sh \
  # restart.sh
  && touch restart.sh \
  && echo './stop.sh && ./start.sh' > restart.sh \
  && chmod 775 restart.sh

ENTRYPOINT ["sh", "/usr/local/ssr/start.sh"]