# Stage 1: Install Dependencies and Build
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files first for better caching
COPY package*.json ./

# If you need authentication, set an environment variable
ARG NPM_TOKEN
ENV NPM_TOKEN=${NPM_TOKEN}

# Avoid interactive login, use token instead
RUN echo "//registry.npmjs.org/:_authToken=${NPM_TOKEN}" > ~/.npmrc

# Install dependencies
RUN npm install --legacy-peer-deps 

# Copy the rest of the files and build
COPY . .
RUN npm run build

# Stage 2: Serve with Nginx
FROM nginx:latest AS deployer

# Copy the built React/Node project to Nginx
COPY --from=builder /app/build /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
