-- GitHub Visual Alerts v3.0
require("hs.canvas")

_G.github_alerts = _G.github_alerts or {}
local alerts = _G.github_alerts

function alerts.animate(emoji, text, startPos, endPos, duration)
    local screen = hs.screen.mainScreen():frame()
    local canvas = hs.canvas.new(screen)
    if not canvas then return end

    canvas[1] = {
        type = "text",
        text = emoji .. " " .. (text or ""),
        textSize = 40,
        textColor = {white = 1},
        textAlignment = "center",
        frame = {x = 0, y = 0, w = 1200, h = 150}
    }
    
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
        canvas:topLeft({x = currentX, y = currentY})
    end)
end

function alerts.flyAeroplane(message)
    local screen = hs.screen.mainScreen():frame()
    local duration = 20 -- Slower as requested
    local bannerWidth = 600
    local planeWidth = 80
    local gap = 20
    local totalWidth = bannerWidth + gap + planeWidth
    
    -- Right to Left: Start at screen width, end at -totalWidth
    local startX = screen.w
    local endX = -totalWidth
    
    local canvas = hs.canvas.new(screen)
    if not canvas then return end

    -- Element 1: The Plane (✈️) - LEADING (Lowest X in the group for R-to-L)
    canvas[1] = {
        type = "text",
        text = "✈️",
        textSize = 60,
        frame = {x = 0, y = 0, w = planeWidth, h = 80}
    }

    -- Element 2: The Cloth (Solid Yellow) - TRAILING (Plane + Gap)
    canvas[2] = {
        type = "rectangle",
        action = "fill",
        fillColor = {red = 1, green = 1, blue = 0, alpha = 1},
        frame = {x = planeWidth + gap, y = 10, w = bannerWidth, h = 60}
    }

    -- Element 3: The Text (10pt)
    canvas[3] = {
        type = "text",
        text = message,
        textSize = 10,
        textColor = {red = 0, green = 0, blue = 0, alpha = 1},
        textAlignment = "center",
        frame = {x = planeWidth + gap + 10, y = 30, w = bannerWidth - 20, h = 20}
    }
    
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
        
        -- Movement: Right to Left
        local currentX = startX + (endX - startX) * progress
        local currentY = screen.h * 0.3
        
        local flutter = math.sin(elapsed * 10) * 8
        
        -- Update the internal elements: Plane leading at currentX
        canvas:elementFrame(1, {x = currentX, y = currentY, w = planeWidth, h = 80})
        canvas:elementFrame(2, {x = currentX + planeWidth + gap, y = currentY + 10 + flutter, w = bannerWidth, h = 60})
        canvas:elementFrame(3, {x = currentX + planeWidth + gap + 10, y = currentY + 30 + flutter, w = bannerWidth - 20, h = 20})
    end)
    
    hs.notify.new({title="New Commit", informativeText=message}):send()
end

function alerts.launchRocket()
    local screen = hs.screen.mainScreen():frame()
    alerts.animate("🚀", "New PR!", {x = (screen.w / 2) - 600, y = screen.h}, {x = (screen.w / 2) - 600, y = -200}, 8)
    hs.notify.new({title="GitHub", informativeText="New Pull Request!"}):send()
end

function alerts.descendParachute()
    local screen = hs.screen.mainScreen():frame()
    alerts.animate("🪂", "CI Failed!", {x = (screen.w / 2) - 600, y = -200}, {x = (screen.w / 2) - 600, y = screen.h}, 20)
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

hs.notify.new({title="Hammerspoon", informativeText="Visual Alerts v3.0 Ready"}):send()
