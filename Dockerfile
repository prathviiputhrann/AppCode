# Step 1: Use Node.js for installing dependencies and building the app
FROM node:18-alpine AS installer

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json (if available)
COPY package*.json ./

# If using private npm packages, pass NPM authentication token
ARG NPM_TOKEN
RUN echo "//registry.npmjs.org/:_authToken=${NPM_TOKEN}" > ~/.npmrc

# Install dependencies
RUN npm install 

# Copy the rest of the application code
COPY . .

# Build the React application
RUN npm run build

# Step 2: Use Nginx to serve the built app
FROM nginx:latest AS deployer

# Remove default Nginx static files
RUN rm -rf /usr/share/nginx/html/*

# Copy the built app from the previous stage
COPY --from=installer /app/build /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
