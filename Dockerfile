# Base image on the floating `latest` tag with no digest pin. ISSUE-706 (medium).
FROM node:latest

WORKDIR /app
COPY . .
RUN npm install

# Runs as root (no USER directive).
ENTRYPOINT ["node", "dist/cli.js"]
