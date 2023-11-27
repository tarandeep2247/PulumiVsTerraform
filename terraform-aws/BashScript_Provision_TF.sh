#!/bin/bash

# Function to display resource utilization
display_utilization() {
    local cpu_usage=$(mpstat 1 1 | awk 'END {print 100 - $NF}')
    local memory_usage=$(free -m | awk 'NR==2 {print $3}')
    local disk_io=$(sudo iotop -b -d 1 -n 2 | awk '/Total DISK/ {print $4}')

    # Format the output and append to the log file
    echo "$(date '+%Y-%m-%d %H:%M:%S'),$cpu_usage,$memory_usage,$disk_io" >> "$OUTPUT_FILE"
}

# Set Terraform CLI argument for auto-approval
export TF_CLI_ARGS="-auto-approve"

# Get Terraform command as user input
read -p "Enter the Terraform command: " TERRAFORM_COMMAND

# Output file for resource utilization results
OUTPUT_FILE="terraform_utilization.log"

# Create or truncate the output file
echo "Timestamp,CPU Usage (%),Memory Usage (MB),Disk I/O (KB/s)" > "$OUTPUT_FILE"

# Run Terraform and get the PID
(eval "$TERRAFORM_COMMAND") &
PID=$!

# Monitor resource utilization
while ps -p $PID > /dev/null; do
    display_utilization
    sleep 1
done

# Display utilization one last time after Terraform finishes
display_utilization

echo "Resource utilization results are saved in: $OUTPUT_FILE"

