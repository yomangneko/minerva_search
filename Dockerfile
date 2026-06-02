FROM node:20-alpine

WORKDIR /app/backend

ENV NODE_ENV=production
ENV PORT=3000

COPY backend/package.json backend/package-lock.json ./
RUN npm ci --omit=dev

COPY backend/server.js backend/library_data.xml ./

EXPOSE 3000

CMD ["npm", "start"]
