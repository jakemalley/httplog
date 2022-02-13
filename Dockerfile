ARG BASE_IMAGE=docker.io/golang:1.17-alpine
FROM $BASE_IMAGE AS go-builder

RUN echo 'nobody:x:65534:65534:nobody:/:/sbin/nologin' > /etc/passwd.nobody
RUN mkdir -p /build /go/src/github.com/jakemalley/httplog
WORKDIR /go/src/github.com/jakemalley/httplog
COPY go.mod *.go .

RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux go build -a -o /build/httplog *.go

FROM scratch AS go-runner

COPY --from=go-builder /etc/passwd.nobody /etc/passwd
COPY --from=go-builder /build/httplog /httplog
USER nobody

EXPOSE 8888
CMD [ "/httplog" ]
