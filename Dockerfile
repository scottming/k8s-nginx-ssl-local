FROM ccr.ccs.tencentyun.com/ai-hub/nginx:1.13.9-alpine
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

ARG SSL_KEY=ssl-key
ARG SSL_CRT=ssl-crt
ARG SERVER_NAME=mynginx.com
ENV SSL_KEY ${SSL_KEY}
ENV SSL_CRT ${SSL_CRT}
ENV SERVER_NAME ${SERVER_NAME}

RUN mkdir -p /etc/nginx/ssl/
ADD ${SSL_KEY} /etc/nginx/ssl/ssl.key
ADD ${SSL_CRT} /etc/nginx/ssl/ssl.crt

COPY default.conf.template /etc/nginx/conf.d/
RUN export DOLLAR='$' && envsubst < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf

EXPOSE 80 443
CMD ["nginx", "-g", "daemon off;"]
