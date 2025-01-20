# Use a Node.js base image
FROM node:18-alpine

# Install necessary packages
RUN apk add --no-cache bash dos2unix build-base python3

# Install pnpm globally
RUN npm install -g pnpm@9 && pnpm --version

# Create a non-root user and group
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set the working directory
WORKDIR /app

# Copy application files into the container with proper ownership
COPY --chown=appuser:appgroup . . 
COPY --chown=appuser:appgroup ./scripts/* /app/scripts/

# Ensure correct permissions for directories
RUN mkdir -p /app/node_modules \
    && mkdir -p /home/appuser/.pnpm-store \
    && chown -R appuser:appgroup /app /home/appuser/.pnpm-store \
    && chmod -R u+w /app /home/appuser/.pnpm-store

# Convert line endings for compatibility and make scripts executable
RUN find /app -type f -exec dos2unix {} \; \
    && chmod +x /app/scripts/*.sh

# Switch to the non-root user
USER appuser

# Set the environment variable for pnpm store location
ENV PNPM_HOME="/home/appuser/.pnpm-store"
ENV PATH="$PNPM_HOME:$PATH"

# Install project dependencies using pnpm
RUN pnpm install --unsafe-perm

# Add ts-node as a development dependency
RUN pnpm add -D ts-node -w

# Define the default command
CMD ["bash", "/app/scripts/ottehr-setup.sh"]
