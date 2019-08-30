FROM nginx

WORKDIR /etc/nginx/

RUN mv nginx.conf nginx.conf.copy

RUN mkdir certs
COPY server.crt certs
COPY server.csr certs
COPY server.key certs

COPY /simple_web /www/data/simple_web/
COPY nginx.conf .

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
