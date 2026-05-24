#!/bin/bash
# Start the GitHub Visual Alerts Bridge Server
echo "Starting Bridge Server..."
python3 /Users/ps/dev/github-visual-alerts/bridge_server.py &
APP_PID=$!
echo "Bridge Server started with PID $APP_PID on port 9999"

echo "To expose this to GitHub, run:"
echo "ngrok http 9999"
echo ""
echo "Then add the ngrok URL + /github-webhook to your GitHub repository webhooks."
wait $APP_PID
