# base image for building the app
FROM --platform=${BUILDPLATFORM} node:20 AS build
# set working directory
WORKDIR /opt/node_app

# install dependencies first for better caching
COPY package*.json ./

# do not ignore optional dependencies:
# Error: Cannot find module @rollup/rollup-linux-x64-gnu
RUN --mount=type=cache,target=/root/.cache/npm \
    npm_config_target_arch=${TARGETARCH} npm ci --network-timeout=600000

# copy source files
COPY . .

# build the app
ENV NODE_ENV=production

RUN npm_config_target_arch=${TARGETARCH} npm run build

# production nginx server
FROM --platform=${TARGETPLATFORM} nginx:1.27-alpine

# copy built assets from build stage
COPY --from=build /opt/node_app/excalidraw-app/build /usr/share/nginx/html

# expose port 80
EXPOSE 80
# start nginx server
CMD ["nginx", "-g", "daemon off;"]
