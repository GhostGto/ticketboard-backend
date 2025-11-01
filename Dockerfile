# Stage 1 - build minimal Node.js image
FROM node:20-bullseye-slim AS base
WORKDIR /app

# update OS packages to pick up security fixes and install ca-certificates
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends ca-certificates && rm -rf /var/lib/apt/lists/*

COPY package*.json ./
RUN npm ci --only=production
COPY . .

EXPOSE 3000
CMD ["node", "index.js"]

