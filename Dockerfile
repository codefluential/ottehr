# Use a Node.js base image
FROM node:18-alpine

# Install bash, dos2unix, and build tools
RUN apk add --no-cache bash dos2unix build-base python3

# Install pnpm globally as root
RUN npm install -g pnpm@9 && pnpm --version

# Create a non-root user and group
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set the working directory
WORKDIR /app

# Copy files into the container
COPY --chown=appuser:appgroup . .
COPY --chown=appuser:appgroup ./scripts/* /app/scripts/

# Ensure proper permissions for /app and node_modules
RUN mkdir -p /app/node_modules && chown -R appuser:appgroup /app && chmod -R u+w /app

# Ensure proper permissions for pnpm cache directory
RUN mkdir -p /home/appuser/.pnpm-store && chown -R appuser:appgroup /home/appuser/.pnpm-store

# Switch to the non-root user
USER appuser

# Install project dependencies using pnpm with --unsafe-perm
RUN pnpm install --unsafe-perm

# Add ts-node as a development dependency
RUN pnpm add -D ts-node -w

# Convert line endings and make scripts executable
RUN dos2unix /app/scripts/ottehr-setup.sh && chmod +x /app/scripts/*.sh

# Run the setup script
CMD ["bash", "/app/scripts/ottehr-setup.sh"]
