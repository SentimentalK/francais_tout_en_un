FROM node:20-slim AS builder
WORKDIR /app

COPY package.json yarn.lock ./
# Accelerate repeated builds by leveraging BuildKit to cache the Yarn cache.
RUN --mount=type=cache,target=/root/.cache/yarn \
    yarn install --frozen-lockfile --network-concurrency 1

COPY . .
RUN yarn build

FROM nginx:alpine
COPY nginx.conf /etc/nginx/nginx.conf
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80