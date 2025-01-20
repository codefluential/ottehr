# Use a Node.js base image
FROM node:18-alpine

# Install bash (required for setup script) and other necessary tools
RUN apk add --no-cache bash

# Set the working directory inside the container
WORKDIR /app

# Copy the entire project into the container
COPY . .
COPY ./scripts/* /app/scripts/

# Install pnpm globally
RUN npm install -g pnpm@9

# Install project dependencies
RUN pnpm install

# Add ts-node as a development dependency to the workspace root
RUN pnpm add -D ts-node -w

# Make the setup script executable
RUN chmod +x /app/scripts/*.sh

# Command to run the interactive setup
CMD ["bash", "/app/scripts/ottehr-setup.sh"]
