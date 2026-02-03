# Use the official HashiCorp Terraform image as the base image
FROM hashicorp/terraform:light

# Set working directory
WORKDIR /app

# Copy shell script into the image
COPY loop-apply.sh /app

# Make script executable
RUN chmod +x /app/loop-apply.sh

# Run the shell script directly (override base image ENTRYPOINT)
ENTRYPOINT ["/app/loop-apply.sh"]
