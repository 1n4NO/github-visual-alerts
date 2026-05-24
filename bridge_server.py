import subprocess
import urllib.parse
from typing import Optional
from fastapi import FastAPI, Request, Header
import uvicorn

app = FastAPI()

def trigger_hammerspoon(event: str, msg: str = ""):
    url = f"hammerspoon://{event}"
    if msg:
        url += f"?msg={urllib.parse.quote(msg)}"
    print(f"Triggering: {url}")
    subprocess.run(["open", "-g", url])

@app.post("/github-webhook")
async def webhook(request: Request, x_github_event: Optional[str] = Header(None)):
    data = await request.json()
    
    if x_github_event == "push":
        msg = data.get("commits", [{}])[0].get("message", "New Commit")
        trigger_hammerspoon("fly", msg)
    
    elif x_github_event == "pull_request":
        if data.get("action") == "opened":
            trigger_hammerspoon("rocket")
            
    elif x_github_event in ["check_run", "status"]:
        status = data.get("check_run", {}).get("conclusion") or data.get("state")
        if status == "failure":
            trigger_hammerspoon("parachute")

    return {"status": "ok"}

if __name__ == "__main__":
    print("Bridge Server started on port 9999")
    uvicorn.run(app, host="0.0.0.0", port=9999)
