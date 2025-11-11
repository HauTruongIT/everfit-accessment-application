# Multi-stage Dockerfile for Next.js app
FROM node:20-alpine AS builder
WORKDIR /app

# copy package files and install dependencies (using Yarn)
COPY package.json yarn.lock* ./
RUN yarn install --frozen-lockfile --silent

# copy source and build
COPY . .
RUN yarn build

FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production

# copy built app and dependencies from builder
COPY --from=builder /app/ .

EXPOSE 3000
CMD ["yarn", "start"]
