# Estágio de construção
FROM node:18-alpine AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm install --verbose
COPY . .
RUN mkdir -p /app/logs && \
    npm run build > /app/logs/build.log 2>&1 || \
    (echo "Build failed, showing logs:"; \
     npm cache clean --force; \
     npm install --verbose > /app/logs/install.log 2>&1; \
     npm run build > /app/logs/build_retry.log 2>&1 || \
     (echo "Retry failed, showing environment:"; \
      echo "Node version:"; node -v; \
      echo "NPM version:"; npm -v; \
      echo "Build logs:"; cat /app/logs/build.log; \
      echo "Install logs:"; cat /app/logs/install.log; \
      echo "Retry logs:"; cat /app/logs/build_retry.log; \
      exit 1))

# Estágio de produção
FROM node:18-alpine
WORKDIR /app
COPY --from=build /app/dist ./dist
COPY --from=build /app/node_modules ./node_modules
COPY package.json .

EXPOSE 5173
CMD ["npm", "run", "preview"]
