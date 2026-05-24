-- GitHub Visual Alerts via URL Scheme
-- This bypasses the buggy hs.httpserver

_G.github_alerts = _G.github_alerts or {}
local alerts = _G.github_alerts

function alerts.animate(emoji, text, startPos, endPos, duration)
    local screen = hs.screen.mainScreen():frame()
    local canvas = hs.canvas.new(screen)
    canvas:insert({
        type = "text",
        text = emoji .. " " .. (text or ""),
        textSize = 80,
        textColor = {red = 1, green = 1, blue = 1, alpha = 1},
        textAlignment = "center",
        frame = {x = startPos.x, y = startPos.y, w = 1200, h = 200}
    })
    canvas:show()
    canvas:level(hs.canvas.windowLevels.status)

    local startTime = hs.timer.secondsSinceEpoch()
    local timer
    timer = hs.timer.doEvery(1/60, function()
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
        canvas:elementFrame(1, {x = currentX, y = currentY, w = 1200, h = 200})
    end)
end

function alerts.flyAeroplane(message)
    local screen = hs.screen.mainScreen():frame()
    alerts.animate("✈️", message, {x = -1200, y = screen.h * 0.3}, {x = screen.w, y = screen.h * 0.3}, 5)
    hs.notify.new({title="New Commit", informativeText=message}):send()
end

function alerts.launchRocket()
    local screen = hs.screen.mainScreen():frame()
    alerts.animate("🚀", "New PR!", {x = (screen.w / 2) - 600, y = screen.h}, {x = (screen.w / 2) - 600, y = -200}, 4)
    hs.notify.new({title="GitHub", informativeText="New Pull Request!"}):send()
end

function alerts.descendParachute()
    local screen = hs.screen.mainScreen():frame()
    alerts.animate("🪂", "CI Failed!", {x = (screen.w / 2) - 600, y = -200}, {x = (screen.w / 2) - 600, y = screen.h}, 10)
    hs.notify.new({title="GitHub", informativeText="CI Check Failed!"}):send()
end

-- Register URL handler
hs.urlevent.bind("fly", function(eventName, params)
    alerts.flyAeroplane(params.msg or "New Commit")
end)
hs.urlevent.bind("rocket", function(eventName, params)
    alerts.launchRocket()
end)
hs.urlevent.bind("parachute", function(eventName, params)
    alerts.descendParachute()
end)

hs.notify.new({title="Hammerspoon", informativeText="Visual Alerts Ready (URL Mode)"}):send()
