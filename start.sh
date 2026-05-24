#!/bin/bash
# Start the GitHub Visual Alerts application
echo "Starting GitHub Visual Alerts..."
python3 /Users/ps/dev/github-visual-alerts/visual_alerts.py &
APP_PID=$!
echo "Application started with PID $APP_PID on port 9999"

echo "To expose this to GitHub, run:"
echo "ngrok http 9999"
echo ""
echo "Then add the ngrok URL + /github-webhook to your GitHub repository webhooks."
echo "Wait for the application to initialize (takes a few seconds)..."
wait $APP_PID
