# Estágio de construção
FROM node:18-alpine AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm install --verbose
COPY . .
RUN npm run build || (echo "Build failed, showing logs:" && cat /app/logs/*.log && exit 1)

# Estágio de produção
FROM node:18-alpine
WORKDIR /app
COPY --from=build /app/dist ./dist
COPY --from=build /app/node_modules ./node_modules
COPY package.json .

EXPOSE 5173
CMD ["npm", "run", "preview"]
