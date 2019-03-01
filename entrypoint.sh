
22 lines (17 sloc) 443 Bytes
#!/bin/sh

# Check configuration file exists
if [ ! -f /etc/tac_plus/tac_plus.cfg ]; then
    echo "No configuration file at /etc/tac_plus/tac_base.cfg"
    exit 1
fi

# Check configuration file for syntax errors
${TAC_PLUS_BIN} -P /etc/tac_plus/tac_base.cfg
if [ $? -ne 0 ]; then
    echo "Invalid configuration file"
    exit 1
fi

# Make the log directories
mkdir -p /var/log/tac_plus

echo "Starting server..."

# Start the server
exec ${TAC_PLUS_BIN} -f /etc/tac_plus/tac_base.cfg