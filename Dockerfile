FROM node:20-alpine AS builder
WORKDIR /app

# install dependencies and build
COPY package.json package-lock.json* ./
RUN npm ci --silent

# copy source and build
COPY . .
RUN npm run build

FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY package.json package-lock.json* ./
RUN npm ci --production --silent
ENV NODE_ENV=production
ENV PORT=5000
EXPOSE 5000
CMD ["node", "dist/index.cjs"]
FROM node:20-alpine AS builder
WORKDIR /app

# copy only manifest first for faster installs
COPY package.json package-lock.json* tsconfig.json ./
COPY client client
COPY server server
COPY script script

RUN npm ci

# build client and bundle server
RUN npm run build

FROM node:20-alpine
WORKDIR /app

# copy built server + client output
COPY --from=builder /app/dist ./dist
COPY package.json package-lock.json* ./

RUN npm ci --production

ENV NODE_ENV=production
ENV PORT=5000
EXPOSE 5000

CMD ["node", "dist/index.cjs"]
