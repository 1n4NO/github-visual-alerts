import sys
import threading
import time
import asyncio
from typing import Optional
from fastapi import FastAPI, Request, Header
import uvicorn
from Cocoa import (
    NSObject, NSApplication, NSWindow, NSScreen, NSRect, NSPoint, NSSize,
    NSColor, NSTextField, NSFont, NSAnimationContext, NSApp, NSThread
)
# Constants
NSWindowStyleMaskBorderless = 0
NSStatusWindowLevel = 25
from PyObjCTools import AppHelper

app = FastAPI()

class AnimationManager(NSObject):
    def init(self):
        # In PyObjC, it's safer to just do this if you don't need to pass args to super
        self.window = None
        self.screen_frame = NSScreen.mainScreen().frame()
        return self

    def setup_window(self):
        if self.window:
            return

        # Create a window that covers the whole screen
        self.window = NSWindow.alloc().initWithContentRect_styleMask_backing_defer_(
            self.screen_frame,
            NSWindowStyleMaskBorderless,
            2, # NSBackingStoreBuffered
            False
        )
        self.window.setLevel_(NSStatusWindowLevel)
        self.window.setBackgroundColor_(NSColor.clearColor())
        self.window.setOpaque_(False)
        self.window.setIgnoresMouseEvents_(True)
        self.window.setHasShadow_(False)
        self.window.makeKeyAndOrderFront_(None)

    def animate_text(self, emoji: str, text: str, start_pos: NSPoint, end_pos: NSPoint, duration: float):
        self.setup_window()
        
        label = NSTextField.alloc().initWithFrame_(NSRect(start_pos, NSSize(800, 100)))
        label.setStringValue_(f"{emoji} {text}")
        label.setFont_(NSFont.systemFontOfSize_(60))
        label.setTextColor_(NSColor.whiteColor())
        label.setBezeled_(False)
        label.setDrawsBackground_(False)
        label.setEditable_(False)
        label.setSelectable_(False)
        
        self.window.contentView().addSubview_(label)

        def perform_animation():
            NSAnimationContext.beginGrouping()
            NSAnimationContext.currentContext().setDuration_(duration)
            label.animator().setFrameOrigin_(end_pos)
            NSAnimationContext.endGrouping()
            
            # Remove after duration
            time.sleep(duration + 0.5)
            label.removeFromSuperviewWithoutNeedingDisplay()

        threading.Thread(target=perform_animation).start()

# Global manager
manager = AnimationManager.alloc().init()

@app.post("/github-webhook")
async def webhook(request: Request, x_github_event: Optional[str] = Header(None)):
    data = await request.json()
    
    if x_github_event == "push":
        msg = data.get("commits", [{}])[0].get("message", "New Commit")
        start = NSPoint(-800, manager.screen_frame.size.height * 0.7)
        end = NSPoint(manager.screen_frame.size.width, manager.screen_frame.size.height * 0.7)
        AppHelper.callAfter(manager.animate_text, "✈️", msg, start, end, 5.0)
    
    elif x_github_event == "pull_request":
        if data.get("action") == "opened":
            start = NSPoint(manager.screen_frame.size.width / 2 - 400, -100)
            end = NSPoint(manager.screen_frame.size.width / 2 - 400, manager.screen_frame.size.height + 100)
            AppHelper.callAfter(manager.animate_text, "🚀", "New Pull Request!", start, end, 3.0)
            
    elif x_github_event in ["check_run", "status"]:
        status = data.get("check_run", {}).get("conclusion") or data.get("state")
        if status == "failure":
            start = NSPoint(manager.screen_frame.size.width / 2 - 400, manager.screen_frame.size.height)
            end = NSPoint(manager.screen_frame.size.width / 2 - 400, -100)
            AppHelper.callAfter(manager.animate_text, "🪂", "CI Failed!", start, end, 8.0)

    return {"status": "ok"}

def run_fastapi():
    uvicorn.run(app, host="0.0.0.0", port=9999)

if __name__ == "__main__":
    # Start FastAPI in a background thread
    threading.Thread(target=run_fastapi, daemon=True).start()
    
    # Run the Cocoa event loop
    print("GitHub Visual Alerts started on port 9999")
    AppHelper.runConsoleEventLoop()
