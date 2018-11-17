FROM  golang:1.11 as builder

WORKDIR /go/src/github.com/cpuguy83/docker-log-driver
COPY . /go/src/github.com/cpuguy83/docker-log-driver
RUN curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh
RUN cd /go/src/github.com/cpuguy83/docker-log-driver && go get -v 
RUN CGO_ENABLED=0 GOOS=linux go build --ldflags '-extldflags "-static"' -o /usr/bin/docker-log-driver

RUN mkdir -p /run/docker/plugins /var/log/docker /var/lib/docker/containers


FROM scratch
WORKDIR /
COPY --from=builder /usr/bin/docker-log-driver /
COPY --from=builder /run/docker/plugins /run/docker/plugins

CMD [ "/docker-log-driver" ]

