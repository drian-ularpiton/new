FROM node:20-alpine AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --include=optional --no-audit --no-fund
COPY . .
ARG SITE_URL=http://localhost:8080
ARG WHATSAPP_NUMBER="[ISI: nomor WA]"
ENV SITE_URL=${SITE_URL} WHATSAPP_NUMBER=${WHATSAPP_NUMBER}
RUN npm run build && npm test

FROM nginx:alpine AS production
COPY nginx.conf /etc/nginx/nginx.conf
COPY --from=build --chown=nginx:nginx /app/dist /usr/share/nginx/html
USER nginx
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -q -O /dev/null http://127.0.0.1:80/ || exit 1
ENTRYPOINT ["nginx", "-g", "daemon off;"]
