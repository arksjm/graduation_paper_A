FROM golang:1.25-alpine AS builder
WORKDIR /app

# Копируем go.mod и go.sum
COPY go.mod go.sum ./

# Устанавливаем GOTOOLCHAIN=auto
ENV GOTOOLCHAIN=auto

# Скачиваем зависимости
RUN go mod download

# Копируем весь код
COPY . .

# Собираем приложение
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o main .

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/main .
COPY --from=builder /app/templates ./templates
COPY --from=builder /app/migrations ./migrations
EXPOSE 8080
CMD ["./main"]
