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

# Copy files into the container with proper ownership
COPY --chown=appuser:appgroup . .
COPY --chown=appuser:appgroup ./scripts/* /app/scripts/

# Ensure proper permissions for /app, node_modules, and pnpm cache
RUN mkdir -p /app/node_modules \
    && mkdir -p /home/appuser/.pnpm-store \
    && chown -R appuser:appgroup /app /home/appuser/.pnpm-store \
    && chmod -R u+w /app /home/appuser/.pnpm-store

# Switch to the non-root user
USER appuser

# Set the environment variable for pnpm store location to avoid permission issues
ENV PNPM_HOME="/home/appuser/.pnpm-store"
ENV PATH="$PNPM_HOME:$PATH"

# Install project dependencies using pnpm with --unsafe-perm
RUN pnpm install --unsafe-perm

# Add ts-node as a development dependency
RUN pnpm add -D ts-node -w

# Convert line endings and make scripts executable
RUN dos2unix /app/scripts/ottehr-setup.sh && chmod +x /app/scripts/*.sh

# Run the setup script
CMD ["bash", "/app/scripts/ottehr-setup.sh"]
