# Use a Node.js base image
FROM node:18-alpine

# Install bash (required for setup script) and other necessary tools
RUN apk add --no-cache bash dos2unix

# Create a non-root user and group
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set the working directory inside the container
WORKDIR /app

# Copy files into the container and adjust ownership to the non-root user
COPY --chown=appuser:appgroup . .
COPY --chown=appuser:appgroup ./scripts/* /app/scripts/

# Switch to the non-root user
USER appuser

# Install pnpm globally
RUN npm install -g pnpm@9

# Install project dependencies
RUN pnpm install --unsafe-perm

# Add ts-node as a development dependency to the workspace root
RUN pnpm add -D ts-node -w

# Convert the script to Unix-style line endings
RUN dos2unix /app/scripts/ottehr-setup.sh

# Make the setup script executable
RUN chmod +x /app/scripts/*.sh

# Ensure all files have compatible permissions
RUN chmod -R 755 /app

# Command to run the interactive setup
CMD ["bash", "/app/scripts/ottehr-setup.sh"]
