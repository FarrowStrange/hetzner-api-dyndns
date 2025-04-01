FROM alpine:latest

# Install required dependencies
RUN apk add --no-cache \
    curl \
    jq

# Copy the scripts
COPY dyndns.sh /usr/local/bin/
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/dyndns.sh /usr/local/bin/entrypoint.sh

# Set environment variables with defaults
ENV HETZNER_AUTH_API_TOKEN=""
ENV HETZNER_ZONE_NAME=""
ENV HETZNER_ZONE_ID=""
ENV HETZNER_RECORD_NAME=""
ENV HETZNER_RECORD_TTL="60"
ENV HETZNER_RECORD_TYPE="A"
ENV UPDATE_INTERVAL="300"

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
