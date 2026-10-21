FROM node:26-alpine AS deps
WORKDIR /app
RUN apk add --no-cache wget
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

FROM node:26-alpine AS runtime
RUN apk add --no-cache wget \
  && addgroup -g 10001 app \
  && adduser -u 10001 -G app -s /bin/sh -D app
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY package.json ./
COPY src ./src
USER app
EXPOSE 3000
ENV NODE_ENV=production
HEALTHCHECK --interval=30s --timeout=3s --start-period=15s --retries=3 \
  CMD wget -qO- http://127.0.0.1:3000/status || exit 1
CMD ["node", "src/index.js"]
