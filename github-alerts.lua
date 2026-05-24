-- GitHub Visual Alerts for Hammerspoon
-- Aeroplane (✈️) for Commits
-- Rocket (🚀) for Pull Requests
-- Parachute (🪂) for CI Failures

alerts = {} -- Make global to prevent GC
hs.ipc.cliInstall() -- Ensure CLI is available

-- --- Configuration ---
local PORT = 9999
local ANIMATION_DURATION = 5 -- seconds
local FPS = 60

-- --- Animation Engine ---

function alerts.animate(emoji, text, startPos, endPos, duration)
    local canvas = hs.canvas.new({x = 0, y = 0, w = 0, h = 0})
    local screen = hs.screen.mainScreen():frame()
    
    canvas:frame(screen)
    
    local element = {
        type = "text",
        text = emoji .. (text and (" " .. text) or ""),
        textSize = 60,
        textColor = {white = 1},
        textAlignment = "center",
        frame = {x = startPos.x, y = startPos.y, w = 600, h = 100}
    }
    
    canvas:insert(element)
    canvas:show()

    local startTime = hs.timer.secondsSinceEpoch()
    local timer
    
    timer = hs.timer.doEvery(1/FPS, function()
        local now = hs.timer.secondsSinceEpoch()
        local elapsed = now - startTime
        local progress = elapsed / duration
        
        if progress >= 1 then
            timer:stop()
            canvas:delete()
            return
        end
        
        local currentX = startPos.x + (endPos.x - startPos.x) * progress
        local currentY = startPos.y + (endPos.y - startPos.y) * progress
        
        canvas:elementFrame(1, {x = currentX, y = currentY, w = 600, h = 100})
    end)
end

-- --- Event Handlers ---

function alerts.flyAeroplane(message)
    local screen = hs.screen.mainScreen():frame()
    local startPos = {x = -600, y = screen.h / 3}
    local endPos = {x = screen.w, y = screen.h / 3}
    alerts.animate("✈️", message, startPos, endPos, 4)
end

function alerts.launchRocket()
    local screen = hs.screen.mainScreen():frame()
    local startPos = {x = screen.w / 2 - 300, y = screen.h}
    local endPos = {x = screen.w / 2 - 300, y = -100}
    alerts.animate("🚀", "New Pull Request!", startPos, endPos, 3)
end

function alerts.descendParachute()
    local screen = hs.screen.mainScreen():frame()
    local startPos = {x = screen.w / 2 - 300, y = -100}
    local endPos = {x = screen.w / 2 - 300, y = screen.h}
    alerts.animate("🪂", "CI Failed!", startPos, endPos, 8)
end

-- --- HTTP Server ---

local function handleRequest(method, path, headers, body)
    print("Received " .. method .. " request to " .. path)
    return "OK", 200
end

alerts.server = hs.httpserver.new(false, "0.0.0.0")
alerts.server:setPort(PORT)
alerts.server:setCallback(function(method, path, headers, body)
    return "OK", 200
end)


alerts.server:start()

print("GitHub Visual Alerts server started on port " .. PORT)
hs.notify.new({title="GitHub Visual Alerts", informativeText="Server started on port " .. PORT}):send()

return alerts
