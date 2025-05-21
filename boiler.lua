-- boiler!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! version 1
local utf8 = require "utf8"

function math.round(n, figs)
    figs = figs or 0
    n = n * 10^figs
    return n - math.floor(n) >= 0.5 and math.ceil(n) / 10^figs or math.floor(n) / 10^figs
end

function math.snap(n, to, method)
    return math[method or "floor"](n / to) * to
end

function math.clamp(n, min, max)
    return math.min(math.max(n, math.min(min, max)), math.max(min, max))
end

function math.inside(n, from, to, set)
    set = set or "[]"
    return n == math.clamp(n, from, to) and ((n ~= from and set:sub(1, 1) == "(") or set:sub(1, 1) == "[") and ((n ~= to and set:sub(2, 2) == ")") or set:sub(2, 2) == "]")
end

function math.sign(n, zero)
    return n == 0 and (zero or 1) or (n / math.abs(n))
end

function string.split(str, pattern, strict)
    local got = {}
    for m in string.gmatch(str..pattern, "(.-)"..pattern) do
        if not strict or #m > 0 then got[#got+1] = m end
    end
    return got
end

function string.gsplit(str, pattern)
    local got = {}
    for m in str:gmatch(pattern) do table.insert(got, m) end
    return got
end

function string.trim(s)
    return s:match("^%s*(.-)%s*$")
end

function fromRGB(r, g, b, a)
    return r / 255, g / 255, b / 255, (a or 255) / 255
end

function fromHEX(h)
    h = h:sub(1, 1) == "#" and h:sub(2, -1) or h
    h = h:lower()
    assert(#h == 3 or #h == 4 or #h == 6 or #h == 8, "malformed hex code")
    assert(h:find("[^abcdef1234567890]") == nil, "malformed hex code")
    local vals = {}

    for i=1, #h, #h < 6 and 1 or 2 do
        vals[#vals+1] = tonumber(string.rep(string.sub(h, i, #h < 6 and i or i + 1), #h < 6 and 2 or 1), 16)
    end

    return vals[1] / 255, vals[2] / 255, vals[3] / 255, (vals[4] or 255) / 255
end

function fromHSV(h, s, v, a)
    h = h / 360
    s = s / 100
    v = v / 100

    local r, g, b;

    if s == 0 then
        r, g, b = v, v, v; -- achromatic
    else
        local function hue2rgb(p, q, t)
            if t < 0 then t = t + 1 end
            if t > 1 then t = t - 1 end
            if t < 1 / 6 then return p + (q - p) * 6 * t end
            if t < 1 / 2 then return q end
            if t < 2 / 3 then return p + (q - p) * (2 / 3 - t) * 6 end
            return p;
        end

        local q = v < 0.5 and v * (1 + s) or v + s - v * s;
        local p = 2 * v - q;
        r = hue2rgb(p, q, h + 1 / 3);
        g = hue2rgb(p, q, h);
        b = hue2rgb(p, q, h - 1 / 3);
    end

    return r, g, b, a or 1
end

function validUTF8(text)
    text = tostring(text)
    local success, pos = utf8.len(text)

    if not success then
        text = text:sub(0, pos-1).."�"..text:sub(pos+1, -1)
        return validUTF8(text)
    end

    return text
end

function typeof(thing)
    return type(getmetatable(thing)) == "string" and getmetatable(thing) or type(thing)
end

function dump(thing, depth, seen)
    if type(thing) ~= "table" then return type(thing) == "string" and "\""..thing.."\"" or tostring(thing) end
    seen = seen or {}
    if seen[thing] then return "{...}" end
    seen[thing] = true
    depth = depth or 1
    local build = "{"
    local prefix = ("  "):rep(depth)
    local any = false
    for i,v in pairs(thing) do
        any = true
        build = build.."\n"..prefix
              .."["..(type(i) == "string" and "\""..i.."\"" or tostring(i)).."]"
              .." = "..dump(v, depth + 1, seen)..","
    end
    return any and build:sub(1, -2).."\n"..prefix:sub(1, -2).."}" or "{}"
end

function table.copy(t)
    if type(t) ~= "table" then return t end

    local n = {}
    if getmetatable(t) then setmetatable(n, getmetatable(t)) end
    for i,v in pairs(t) do
        if typeof(v) == "table" then
            n[i] = table.copy(v)
        else
            n[i] = v
        end
    end
    return n
end