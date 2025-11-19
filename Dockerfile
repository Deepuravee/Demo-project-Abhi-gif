# ===========================
# Stage 1 — Build React App
# ===========================
FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build


# ===========================
# Stage 2 — Nginx (unprivileged)
# ===========================
FROM nginxinc/nginx-unprivileged:1.27.0

USER root

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Create required directory for PID
RUN mkdir -p /var/run/nginx && chown -R nginx:nginx /var/run/nginx

# Copy React build output
COPY --chown=nginx:nginx --from=builder /app/build /usr/share/nginx/html

USER nginx

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]

