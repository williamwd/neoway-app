FROM golang:1.13-stretch AS go-docker
WORKDIR /src/
COPY *.go /src/

RUN CGO_ENABLED=0 go build -o /bin/players-app

FROM alpine:3.7
COPY --from=go-docker /bin/players-app /bin/players-app
ENTRYPOINT ["/bin/players-app"]
