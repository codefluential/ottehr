FROM node:18-alpine

# Install bash, dos2unix, and build tools
RUN apk add --no-cache bash dos2unix build-base python3

# Install pnpm globally
RUN npm install -g pnpm@9 && pnpm --version

# Create a non-root user and group
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set the working directory and copy files
WORKDIR /app
COPY --chown=appuser:appgroup . .
COPY --chown=appuser:appgroup ./scripts/* /app/scripts/

# Ensure correct ownership and writable permissions
RUN chown -R appuser:appgroup /app && chmod -R u+w /app

# Switch to the non-root user
USER appuser

# Install project dependencies
RUN pnpm install --unsafe-perm

# Add ts-node as a development dependency
RUN pnpm add -D ts-node -w

# Convert line endings and make scripts executable
RUN dos2unix /app/scripts/ottehr-setup.sh && find /app/scripts -name "*.sh" -exec chmod +x {} \;

# Run the setup script
CMD ["bash", "/app/scripts/ottehr-setup.sh"]
