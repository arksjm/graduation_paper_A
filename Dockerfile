FROM golang:1.25-alpine AS builder
WORKDIR /app

# Копируем go.mod и go.sum
COPY app/go.mod app/go.sum ./

# Устанавливаем GOTOOLCHAIN=auto для совместимости
ENV GOTOOLCHAIN=auto

# Скачиваем зависимости
RUN go mod download

# Копируем весь код
COPY app/ ./

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
