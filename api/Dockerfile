# syntax=docker/dockerfile:1
FROM golang:alpine

# Set Working Directory
WORKDIR /app

# Initialize go modules
COPY go.mod ./
COPY go.sum ./
RUN go mod download

# Copy source code
COPY *.go ./

# Build the Go app
RUN go build -o cloud-api 

# Expose required ports
EXPOSE 8080

# Configure the binary run as nonroot user
RUN addgroup -S nonroot \
    && adduser -S nonroot -G nonroot

USER nonroot

# Run the binary
CMD ["./cloud-api"]
