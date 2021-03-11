FROM golang:1.16 AS builder
LABEL maintainer="Ming Chen"

ENV PACKAGE github.com/mingcheng/ssr-subscriber
ENV GOPROXY https://goproxy.cn,direct
ENV BUILD_DIR ${GOPATH}/src/${PACKAGE}
ENV TARGET_DIR ${BUILD_DIR}

COPY . ${BUILD_DIR}
WORKDIR ${BUILD_DIR}
RUN make clean build && \
  	mv ${TARGET_DIR}/ssr-subscriber /usr/bin/ssr-subscriber

# Stage2
FROM debian:buster

ENV TZ "Asia/Shanghai"

RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list \
	&& sed -i 's/security.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list \
	&& echo "Asia/Shanghai" > /etc/timezone \
	&& apt -y update \
	&& apt -y upgrade \
	&& apt -y install ca-certificates openssl tzdata curl \
	&& apt -y autoremove

COPY --from=builder /usr/bin/ssr-subscriber /bin/ssr-subscriber

HEALTHCHECK --interval=60s --timeout=10s \
	CMD curl -fs http://localhost/last-check || exit 1

EXPOSE 80
ENTRYPOINT ["/bin/ssr-subscriber", "--http"]
