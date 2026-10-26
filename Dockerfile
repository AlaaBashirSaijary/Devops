FROM node:20-alpine
WORKDIR /app
COPY package.json ./
COPY app ./app
EXPOSE 3000
USER node
CMD ["node", "app/server.js"]
