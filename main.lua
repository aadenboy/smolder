require "boiler"
require "keys"
require "vector"
require "camera"

local board = {}
local dirs = {
    Vector2.new(-1, 0),
    Vector2.new(1, 0),
    Vector2.new(0, -1),
    Vector2.new(0, 1),
}
local t = 0
local playing = false

function get(b, pos, def)
    if def then b[tostring(pos)] = b[tostring(pos)] or {def, pos} end
    return b[tostring(pos)]
end
function set(b, pos, new)
    b[tostring(pos)] = {new, pos}
    if not new then b[tostring(pos)] = nil end
end
local bdata = "0"--[[
00 00 01 00 00 00
10 11 01 01 01 11
03 20 11 00 00 11
00 00 11 11 11 11
00 00 00 00 00 11
10 10 10 10 10 11
00 00 10 00 00 12
00 02 11 00 00 11
11 11 11 11 11 11
00 00 30 00 00 21
00 00 01 01 01 01
]]
local size = Vector2.new(100, 100)
local maxwidth = 0
local rows = bdata:gsplit("([%d ]+)")
function reset()
    for ridx, row in ipairs(rows) do
        local cells = row:gsplit("(%d+)")
        maxwidth = math.max(maxwidth, #cells)
        for cidx, cell in ipairs(cells) do
            local b, g, r = tonumber(cell:match("(.)")), tonumber(cell:match(".(.)")), tonumber(cell:match("..(.)"))
            for x=0, size.x-1 do for y=0, size.y-1 do
                set(board, Vector2.new(cidx-1+x*#cells, 0-(ridx-1+y*#rows)), {b = b, g = g, r = r})
            end end
        end
    end
end
reset()

-- 113 -> 220 => 111
-- 223 -> 110 => 221

local current = ""

local cm = Vector2.new(0, 0)
local cp = Vector2.new(0, 0)
local dm = false
function toWorld(x, y)
    return Vector2.new(
        math.floor((x-window.width/2)/camera.z+camera.position.x),
        math.floor(-(y-window.height/2)/camera.z+camera.position.y)
    )
end

local changed = {}
local initial = true
local save = {board = {}, changed = {}}
function love.update()
    window:refresh()
    mouse:refresh()
    keyboard:refresh()

    if keyboard.i.clicked then board = {}; reset(); changed = {}; t = 0; initial = true; playing = false; end
    if keyboard.space.clicked or keyboard.tab.clicked then
        if initial and not playing then
            save.board = table.copy(board)
            save.changed = table.copy(changed)
            initial = false
        end
        if keyboard.space.clicked then playing = not playing end
    end
    if keyboard.r.clicked and not initial then
        board = table.copy(save.board)
        changed = table.copy(save.changed)
        initial = true
        playing = false
    end

    if playing or keyboard.tab.threshold then
        local actualcomp = {}
        for _,thing in pairs(changed) do
            local pos = thing[2]
            local cell = get(board, pos)
            if (cell[1].r or 0) > 0 then
                for _,dir in ipairs(dirs) do
                    local ncell = get(board, pos + dir)
                    if ncell then if ncell[1].r == nil and ((ncell[1].b or 0) > 0 or (ncell[1].g or 0) > 0) then
                        set(actualcomp, pos + dir, ncell)
                    end end
                end
            end
        end
        local nchanged = {}
        for _,a in pairs(actualcomp) do
            local cell = a[1]
            local pos = cell[2]
            set(nchanged, pos, true)
            local total = {b = 0, g = 0, r = 0}
            for _,dir in ipairs(dirs) do
                local ncell = get(board, pos + dir)
                if ncell and get(changed, pos + dir) and (ncell[1].r or 0) > 0 then
                    total.b = (total.b + ncell[1].b) % 4
                    total.g = (total.g + ncell[1].g) % 4
                    total.r = (total.r + ncell[1].r) % 4
                end
            end
            local diffb = cell[1].b - total.b
            local diffg = cell[1].g - total.g
            cell[1] = {b = (total.b + diffb - diffg) % 4, g = (total.g + diffg - diffb) % 4, r = (total.r - diffb - diffg) % 4}
        end
        changed = nchanged
    end

    if mouse.rmb.clicked then
        cm = Vector2.new(mouse.x, -mouse.y)
        cp = camera.position:deepcopy()
    end
    if mouse.rmb.pressed then
        camera.position = cp - (Vector2.new(mouse.x, -mouse.y) - cm) / camera.z
    end

    if mouse.lmb.pressed then
        local pos = toWorld(mouse.x, mouse.y)
        dm = get(board, pos)
        if dm then
            local b, g, r = tonumber(current:match("(.)")), tonumber(current:match(".(.)")), tonumber(current:match("..(.)"))
            set(changed, pos, true)
            set(board, pos, {b = b, g = g, r = r})
        end
    end

    for i=0, 3 do
        if keyboard[tostring(i)].threshold then
            current = (current..i):sub(1, 3)
        end
    end
    if keyboard.backspace.threshold then current = current:sub(1, -2) end
end
camera.z = 30

function love.wheelmoved(x, y)
    camera.z = math.clamp(camera.z + y, 1, 100)
end

-- https://stackoverflow.com/a/1855903
function contrast(r, g, b, a)
    if not g and r then
        a = r
        r, g, b = love.graphics.getColor()
    end
    local d = 0
    local luminance = (0.299 * r + 0.587 * g + 0.114 * b)
    local shade = 1 - math.round(luminance)
    return shade, shade, shade, a
end

local noto = love.graphics.newFont("notosansmono.ttf", 16, "light", 4)
local text = love.graphics.newText(noto)
function love.draw()
    for i,v in pairs(board) do
        local ax, ay = CamPoint(v[2].x, v[2].y)
        local bx, by = CamPoint(v[2].x+1, v[2].y+1)
        if bx < 0 or ax > window.width or ay < 0 or by > window.height then goto skip end
        local m = v[1] and 1 or 0.3
        love.graphics.setColor((v[1].r or 0)/3, (v[1].g or 0)/3, (v[1].b or 0)/3)
        love.graphics.polygon("fill", CamPoly({0,0;0,1;1,1;1,0;}, v[2]))
        local x, y, _, s = CamPoint(v[2].x+0.5, v[2].y+0.5, 0, 1, 1)
        love.graphics.setColor(contrast(0.5))
        text:set((v[1].b or "")..(v[1].g or "")..(v[1].r or ""))
        love.graphics.draw(text, x, y, 0, s/text:getWidth(), s/text:getHeight(), text:getWidth()/2, text:getHeight()/2)
        ::skip::
    end
    local b, g, r = current:match("(.?)(.?)(.?)")
    love.graphics.setColor((tonumber(r) or 0)/3, (tonumber(g) or 0)/3, (tonumber(b) or 0)/3)
    love.graphics.rectangle("fill", 15, 15, 100, 100)
    love.graphics.setColor(contrast(0.5))
    text:set(current)
    love.graphics.draw(text, 65, 65, 0, 100/text:getWidth(), 100/text:getHeight(), text:getWidth()/2, text:getHeight()/2)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(toWorld(mouse.x, mouse.y).."")
end