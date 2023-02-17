# syntax=docker/dockerfile:1
FROM golang:1.19

WORKDIR /app

COPY go.mod ./
COPY go.sum ./
RUN go mod download

COPY *.go ./

RUN go build -o cloud-api 

EXPOSE 8080

CMD ["./cloud-api"]
