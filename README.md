# GitHub Visual Alerts for macOS

A macOS application that brings your team's GitHub activity to life with high-performance native animations.

- ✈️ **Aeroplane**: Flies across the screen for every new commit (with the commit message).
*   🚀 **Rocket**: Launches from the bottom of the screen when a new Pull Request is opened.
*   🪂 **Parachute**: Descends from the top when a CI check fails.

## Architecture

This project uses a "Bridge" architecture for maximum reliability:
1.  **Bridge Server (Python/FastAPI)**: A lightweight local server that receives GitHub Webhooks.
2.  **Hammerspoon (Lua)**: The macOS automation engine that handles the native transparent overlay and high-performance animations.
3.  **Communication**: The Bridge Server triggers Hammerspoon via native macOS URL schemes (`hammerspoon://...`).

## Prerequisites

- **Hammerspoon**: [hammerspoon.org](https://www.hammerspoon.org/)
- **Python 3**: With `fastapi` and `uvicorn` installed.
- **ngrok**: To expose your local server to GitHub.

## Setup

1.  **Clone the Repository**:
    ```bash
    cd ~/dev/github-visual-alerts
    ```

2.  **Link Hammerspoon Config**:
    Ensure the `github-alerts.lua` script is linked to your Hammerspoon directory:
    ```bash
    ln -sf ~/dev/github-visual-alerts/github-alerts.lua ~/.hammerspoon/github-alerts.lua
    ```
    Add `require("github-alerts")` to your `~/.hammerspoon/init.lua`.

3.  **Install Dependencies**:
    ```bash
    python3 -m pip install fastapi uvicorn
    ```

## Usage

1.  **Start the Bridge Server**:
    ```bash
    ./start.sh
    ```

2.  **Expose to GitHub**:
    In a new terminal, run:
    ```bash
    ngrok http 9999
    ```

3.  **Add GitHub Webhook**:
    In your GitHub Repo Settings -> Webhooks, add your ngrok URL + `/github-webhook`.
    - Content Type: `application/json`
    - Events: `Push`, `Pull requests`, `Check runs`.

## Local Testing

Trigger animations manually using these commands:

- **Aeroplane**:
  ```bash
  curl -X POST -H "X-GitHub-Event: push" -H "Content-Type: application/json" -d '{"commits": [{"message": "Success at Last!"}]}' http://localhost:9999/github-webhook
  ```
- **Rocket**:
  ```bash
  curl -X POST -H "X-GitHub-Event: pull_request" -H "Content-Type: application/json" -d '{"action": "opened"}' http://localhost:9999/github-webhook
  ```
- **Parachute**:
  ```bash
  curl -X POST -H "X-GitHub-Event: check_run" -H "Content-Type: application/json" -d '{"check_run": {"conclusion": "failure"}}' http://localhost:9999/github-webhook
  ```

## License

MIT License
