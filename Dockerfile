# Use a Node.js base image
FROM node:18-alpine

# Install bash (required for setup script) and other necessary tools
RUN apk add --no-cache bash

# Set the working directory inside the container
WORKDIR /app

# Copy the entire project into the container
COPY . .

# Install pnpm globally
RUN npm install -g pnpm@9

# Install project dependencies
RUN pnpm install

# Ensure ts-node is installed globally for TypeScript execution
RUN pnpm add -D ts-node

# Make the setup script executable
RUN chmod +x ./ottehr-setup.sh

# Command to run the interactive setup
CMD ["bash", "./ottehr-setup.sh"]
