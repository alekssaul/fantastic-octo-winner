FROM golang:latest as builder
WORKDIR /go/src/github.com/alekssaul/fantastic-octo-winner/src/backend
COPY . .
RUN mkdir -p /app 
RUN CGO_ENABLED=0 GOOS=linux go build -buildvcs=false -o /app/backend ./


FROM alpine:latest
RUN apk update ;  apk add --no-cache ca-certificates ; update-ca-certificates ; mkdir /app
WORKDIR /app
COPY --from=builder /app/backend /app/backend
ENTRYPOINT [ "/app/backend" ] 
EXPOSE 8080