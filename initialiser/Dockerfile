FROM alpine:3.14
RUN apk add --no-cache curl netcat-openbsd
COPY . /.
ENTRYPOINT ["sh", "provision.sh"]