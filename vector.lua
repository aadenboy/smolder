-- version 1

function assertlower(cond, message)
    if not cond then
        error(message, 3)
    end
end

Vector2 = {meta = {}}

function Vector2.new(x, y)
    -- synopsis: creates a new vector2 object
    -- Vector2.new(x, y)
    -- x: number    - x coordinate
    -- y: number    - y coordinate
    -- returns: vector2

    if type(x) == "table" then x, y = x[1], x[2] end
    assertlower(x ~= nil and y ~= nil, "Vector2.new expects two arguments X and Y")
    assertlower(type(x) == "number", "argument 1 must be a number")
    assertlower(type(y) == "number", "argument 2 must be a number")
    local vec = {x = x, y = y}
    setmetatable(vec, Vector2.meta)
    return vec
end

function Vector2.fromAngle(deg)
    -- synopsis: creates a new vector2 object from a given angle, i.e 0º = Vector2.new(1, 0), 90º = Vector2.new(0, 1), etc.
    -- Vector2.fromAngle(deg)
    -- deg: number  - the angle to create the vector2 from
    -- returns: vector2

    assertlower(deg ~= nil, "Vector2.fromAngle expects an argument")
    assertlower(type(deg) == "number", "argument 1 must be a number")
    return Vector2.new(math.round(math.cos(deg * math.pi / 180), 3), math.round(math.sin(deg * math.pi / 180), 3))
end

function Vector2.middle(...)
    -- synopsis: returns the middle of multiple points
    -- Vector2.middle(v1, v2 [, v3 [, v4 [, ...]]])
    -- v1, v2, ...: vector2 - the vectors to get the middle of

    local t = Vector2.new(0, 0)
    local vecs = ({...})

    for i=1, #vecs do
        assertlower(typeof(vecs[i]) == "vector2", "argument "..i.."is not a vector2")
        t = t + vecs[i]
    end

    return t / #vecs
end

Vector2.meta = {
    __metatable = "vector2",
    __tostring = function(thing)
        return "{"..thing.x..", "..thing.y.."}"
    end,
    __concat = function(thing, other)
        return (typeof(thing) == "vector2" and tostring(thing) or thing)..(typeof(other) == "vector2" and tostring(other) or other)
    end,
    __eq = function(a, b)
        return a.x == b.x and a.y == b.y
    end,
    __unm = function(a)
        return Vector2.new(-a.x, -a.y)
    end,
    __add = function(a, b)
        assertlower(typeof(a) == "vector2", "attempted to add a '"..typeof(a).."' with a 'vector2'")
        assertlower(typeof(b) == "vector2", "attempted to add a 'vector2' with a '"..typeof(b).."'")
        return Vector2.new(a.x + b.x, a.y + b.y)
    end,
    __sub = function(a, b)
        assertlower(typeof(a) == "vector2", "attempted to sub a '"..typeof(a).."' with a 'vector2'")
        assertlower(typeof(b) == "vector2", "attempted to sub a 'vector2' with a '"..typeof(b).."'")
        return Vector2.new(a.x - b.x, a.y - b.y)
    end,
    __mul = function(a, b)
        assertlower(typeof(a) == "vector2" or typeof(a) == "number", "attempted to mul a '"..typeof(a).."' with a 'vector2'")
        assertlower(typeof(b) == "vector2" or typeof(b) == "number", "attempted to mul a 'vector2' with a '"..typeof(b).."'")
        a = typeof(a) == "number" and {x = a, y = a} or a
        b = typeof(b) == "number" and {x = b, y = b} or b
        return Vector2.new(a.x * b.x, a.y * b.y)
    end,
    __div = function(a, b)
        assertlower(typeof(a) == "vector2" or typeof(a) == "number", "attempted to div a '"..typeof(a).."' with a 'vector2'")
        assertlower(typeof(b) == "vector2" or typeof(b) == "number", "attempted to div a 'vector2' with a '"..typeof(b).."'")
        a = typeof(a) == "number" and {x = a, y = a} or a
        b = typeof(b) == "number" and {x = b, y = b} or b
        return Vector2.new(a.x / b.x, a.y / b.y)
    end,
    __mod = function(a, b)
        assertlower(typeof(a) == "vector2", "attempted to mod a '"..typeof(a).."' with a 'vector2'")
        assertlower(typeof(b) == "vector2", "attempted to mod a 'vector2' with a '"..typeof(b).."'")
        return Vector2.new(a.x % b.x, a.y % b.y)
    end,
    __exp = function(a, b)
        assertlower(typeof(a) == "vector2" or typeof(a) == "number", "attempted to pow a '"..typeof(a).."' with a 'vector2'")
        assertlower(typeof(b) == "vector2" or typeof(a) == "number", "attempted to pow a 'vector2' with a '"..typeof(b).."'")
        a = typeof(a) == "number" and {x = a, y = a} or a
        b = typeof(b) == "number" and {x = b, y = b} or b
        return Vector2.new(a.x^b.x, a.y^b.y)
    end,
    __index = {
        x = 0,
        y = 0,
        deepcopy = function(self)
            -- synopsis: returns a deep copy of the self vector
            -- <vector2>:deepcopy()
            -- returns: vector2

            return Vector2.new(self.x, self.y)
        end,
        magnitude = function(self)
            -- synopsis: gives the distance from {0, 0}
            -- <vector2>:magnitude()
            -- returns: number
    
            return math.sqrt(self.x^2 + self.y^2)
        end,
        distfrom = function(self, vector)
            -- synopsis: gives the distance from self vector to another
            -- <vector2>:distfrom(vector)
            -- vector: vector2  - the vector2 to calculate distance from
    
            return math.sqrt((self.x - vector.x)^2 + (self.y - vector.y)^2)
        end,
        rotaround = function(self, vector, deg)
            -- synopsis: rotates a vector2 around another
            -- <vector2>:rotaround(vector, deg)
            -- vector: vector2  - the vector2 to rotate around
            -- deg: number      - the amount of degrees to rotate around (counter-clockwise)
            -- returns: vector2
    
            if deg % 360 == 0 then return self end
            deg = deg * math.pi / 180
            local ovec = self - vector
            local nvec = Vector2.new(ovec.x * math.cos(deg) - ovec.y * math.sin(deg), 3), math.round(ovec.x * math.sin(deg) + ovec.y * math.cos(deg))
            return nvec + vector
        end,
        unpack = function(self)
            -- synopsis: unpacks a vector2 into a tuple for functions
            -- <vector2>:unpack()
            -- returns: number, number
    
            return self.x, self.y
        end,
        round = function(self, figs)
            -- synopsis: rounds the vector2
            -- <vector2>:round([figs=0])
            -- figs: number - amount of sigfigs to preserve, e.g Vector2.new(2.8531, 9.3278):round(2) returns Vector2.new(2.85, 9.33)
            -- returns: vector2
    
            return Vector2.new(math.round(self.x, figs), math.round(self.y, figs))
        end,
        clamp = function(self, xmin, xmax, ymin, ymax)
            -- synopsis: clamps the x and y coordinates
            -- <vector2>:clamp(xmin, xmax, ymin, ymax)
            -- xmin: number - x minimum
            -- xmax: number - x maximum
            -- ymin: number - y minimum
            -- ymax: number - y maximum
    
            return Vector2.new(math.clamp(self.x, xmin, xmax), math.clamp(self.y, ymin, ymax))
        end,
        dot = function(self, other)
            -- synopsis: performs dot product on two vector2s
            -- <vector2>:dot(other)
            -- other: vector2   - the other vector2
            -- returns: number
    
            return self.x * other.x + self.y * other.y
        end,
        anglefrom = function(self, vector)
            -- synopsis: gives the angle from two vector2s
            -- <vector2>:anglefrom(thing)
            -- vector: vector2  - the other vector2
            -- returns: number
    
            local diff = vector - self
            local deg = math.atan2(diff.y, diff.x) * 180 / math.pi
            
            return deg < 0 and (deg + 360) or deg
        end,
        normal = function(self)
            -- synopsis: normalizes a vector to a unit vector
            -- <vector2>:normal()
            -- returns: vector2
    
            return self / self:magnitude()
        end,
        iscard = function(self)
            -- synopsis: checks if a vector points in a cardinal direction
            -- <vector2>:iscard()
            -- returns: boolean
    
            return ((self.x ~= 0 and self.y == 0) or (self.x == 0 and self.y ~= 0)) and (self.x ~= 0 or self.y ~= 0)
        end,
        isunit = function(self)
            -- synopsis: checks if a vector is a unit vector
            -- <vector2>:isunit()
            -- returns: boolean
    
            return self == self:normal()
        end,
        midfrom = function(self, vector)
            -- synopsis: gives the midpoint of two vectors
            -- <vector2>:midfrom(vector)
            -- vector: vector2  - the other vector2
            -- returns: vector2
    
            return (self + vector) / 2
        end,
        lerp = function(self, vector, t)
            -- synopsis: lerps two vectors
            -- <vector2>:lerp(vector, t)
            -- vector: vector2 - end vector
            -- t:      number  - lerp value, 0 to 1
            -- return: vector2

            return self + (vector - self) * t
        end
    }
}

Vector3 = {meta = {}}

function Vector3.new(x, y, z)
    -- synopsis: creates a new vector3 object
    -- Vector3.new(x, y)
    -- x: number    - x coordinate
    -- y: number    - y coordinate
    -- z: number    - z coordinate
    -- returns: vector3

    if type(x) == "table" then x, y, z = x[1], x[2], x[3] end
    assertlower(x ~= nil and y ~= nil and z ~= nil, "Vector3.new expects three arguments")
    assertlower(type(x) == "number", "argument 1 must be a number")
    assertlower(type(y) == "number", "argument 2 must be a number")
    assertlower(type(z) == "number", "argument 3 must be a number")
    local vec = {x = x, y = y, z = z}
    setmetatable(vec, Vector3.meta)
    return vec
end

function Vector3.middle(...)
    -- synopsis: returns the middle of multiple points
    -- Vector3.middle(v1, v2 [, v3 [, v4 [, ...]]])
    -- v1, v2, ...: vector3 - the vectors to get the middle of

    local t = Vector3.new(0, 0, 0)

    for i=1, #({...}) do
        t = t + ({...})[i]
    end

    return t / #({...})
end

Vector3.meta = {
    __metatable = "vector3",
    __tostring = function(thing)
        return "{"..thing.x..", "..thing.y..", "..thing.z.."}"
    end,
    __concat = function(thing, other)
        return (typeof(thing) == "vector3" and tostring(thing) or thing)..(typeof(other) == "vector3" and tostring(other) or other)
    end,
    __eq = function(a, b)
        return a.x == b.x and a.y == b.y and a.z == b.z
    end,
    __unm = function(a)
        return Vector3.new(-a.x, -a.y, -a.z)
    end,
    __add = function(a, b)
        assertlower(typeof(a) == "vector3", "attempted to add a '"..typeof(a).."' with a 'vector3'")
        assertlower(typeof(b) == "vector3", "attempted to add a 'vector3' with a '"..typeof(b).."'")
        return Vector3.new(a.x + b.x, a.y + b.y, a.z + b.z)
    end,
    __sub = function(a, b)
        assertlower(typeof(a) == "vector3", "attempted to sub a '"..typeof(a).."' with a 'vector3'")
        assertlower(typeof(b) == "vector3", "attempted to sub a 'vector3' with a '"..typeof(b).."'")
        return Vector3.new(a.x - b.x, a.y - b.y, a.z - b.z)
    end,
    __mul = function(a, b)
        assertlower(typeof(a) == "vector3" or typeof(a) == "number", "attempted to mul a '"..typeof(a).."' with a 'vector3'")
        assertlower(typeof(b) == "vector3" or typeof(b) == "number", "attempted to mul a 'vector3' with a '"..typeof(b).."'")
        a = typeof(a) == "number" and {x = a, y = a, z = a} or a
        b = typeof(b) == "number" and {x = b, y = b, z = b} or b
        return Vector3.new(a.x * b.x, a.y * b.y, a.z * b.z)
    end,
    __div = function(a, b)
        assertlower(typeof(a) == "vector3" or typeof(a) == "number", "attempted to div a '"..typeof(a).."' with a 'vector3'")
        assertlower(typeof(b) == "vector3" or typeof(b) == "number", "attempted to div a 'vector3' with a '"..typeof(b).."'")
        a = typeof(a) == "number" and {x = a, y = a, z = a} or a
        b = typeof(b) == "number" and {x = b, y = b, z = b} or b
        return Vector3.new(a.x / b.x, a.y / b.y, a.z / b.z)
    end,
    __mod = function(a, b)
        assertlower(typeof(a) == "vector3", "attempted to mod a '"..typeof(a).."' with a 'vector3'")
        assertlower(typeof(b) == "vector3", "attempted to mod a 'vector3' with a '"..typeof(b).."'")
        return Vector3.new(a.x % b.x, a.y % b.y, a.z % b.z)
    end,
    __exp = function(a, b)
        assertlower(typeof(a) == "vector3" or typeof(a) == "number", "attempted to pow a '"..typeof(a).."' with a 'vector3'")
        assertlower(typeof(b) == "vector3" or typeof(a) == "number", "attempted to pow a 'vector3' with a '"..typeof(b).."'")
        a = typeof(a) == "number" and {x = a, y = a, z = a} or a
        b = typeof(b) == "number" and {x = b, y = b, z = b} or b
        return Vector3.new(a.x^b.x, a.y^b.y, a.z^b.z)
    end,
    __index = {
        x = 0,
        y = 0,
        z = 0,
        deepcopy = function(self)
            -- synopsis: returns a deep copy of the self vector
            -- <vector3>:deepcopy()
            -- returns: vector3

            return Vector3.new(self.x, self.y)
        end,
        magnitude = function(self)
            -- synopsis: gives the distance from {0, 0, 0}
            -- <vector3>:magnitude()
            -- returns: number
    
            return math.sqrt(self.x^2 + self.y^2 + self.z^2)
        end,
        distfrom = function(self, vector)
            -- synopsis: gives the distance from self vector to another
            -- <vector3>:distfrom(vector)
            -- vector: vector3 - the vector3 to calculate distance from
    
            return math.sqrt((self.x - vector.x)^2 + (self.y - vector.y)^2 + (self.z - vector.z)^2)
        end,
    --[[rotaround = function(self, vector, deg)
            -- synopsis: rotates a vector2 around another
            -- <vector2>:rotaround(vector, deg)
            -- vector: vector2  - the vector2 to rotate around
            -- deg: number      - the amount of degrees to rotate around (counter-clockwise)
            -- returns: vector2
    
            if deg % 360 == 0 then return self end
            deg = deg * math.pi / 180
            local ovec = self - vector
            local nvec = Vector2.new(math.round(ovec.x * math.cos(deg) - ovec.y * math.sin(deg), 3), math.round(ovec.x * math.sin(deg) + ovec.y * math.cos(deg), 3))
            return nvec + vector
        end,]]
        unpack = function(self)
            -- synopsis: unpacks a vector3 into a tuple for functions
            -- <vector3>:unpack()
            -- returns: number, number, number
    
            return self.x, self.y, self.z
        end,
        round = function(self, figs)
            -- synopsis: rounds the vector3
            -- <vector3>:round([figs=0])
            -- figs: number - amount of sigfigs to preserve, e.g Vector3.new(2.8531, 9.3278, -5.4459):round(2) returns Vector3.new(2.85, 9.33, -5.5)
            -- returns: vector3
    
            return Vector3.new(math.round(self.x, figs), math.round(self.y, figs), math.round(self.z, figs))
        end,
        clamp = function(self, min, max)
            -- synopsis: clamps the values to be between min and max
            -- <vector3>:clamp(xmin, xmax, ymin, ymax)
            -- min: vector3 - minimum value
            -- max: vector3 - maximum value
    
            return Vector3.new(math.clamp(self.x, min.x, max.x), math.clamp(self.y, min.y, max.y), math.clamp(self.z, min.z, max.z))
        end,
        dot = function(self, other)
            -- synopsis: performs dot product on two vector3s
            -- <vector3>:dot(other)
            -- other: vector3 - the other vector3
            -- returns: number
    
            return self.x * other.x + self.y * other.y + self.z * other.z
        end,
    --[[anglefrom = function(self, vector)
            -- synopsis: gives the angle from two vector2s
            -- <vector2>:anglefrom(thing)
            -- vector: vector2  - the other vector2
            -- returns: number
    
            local diff = vector - self
            local deg = math.atan2(diff.y, diff.x) * 180 / math.pi
            
            return deg < 0 and (deg + 360) or deg
        end,]]
        normal = function(self)
            -- synopsis: normalizes a vector to a unit vector
            -- <vector3>:normal()
            -- returns: vector3
    
            return self / self:magnitude()
        end,
        iscard = function(self)
            -- synopsis: checks if a vector points in a cardinal direction
            -- <vector3>:iscard()
            -- returns: boolean
    
            return (self.x ~= 0 or  self.y ~= 0 or  self.z ~= 0) and
                   (
                    (self.x ~= 0 and self.y == 0 and self.z == 0) or
                    (self.x == 0 and self.y ~= 0 and self.z == 0) or
                    (self.x == 0 and self.y == 0 and self.z ~= 0)
                   )
        end,
        isunit = function(self)
            -- synopsis: checks if a vector is a unit vector
            -- <vector3>:isunit()
            -- returns: boolean
    
            return self == self:normal()
        end,
        midfrom = function(self, vector)
            -- synopsis: gives the midpoint of two vectors
            -- <vector3>:midfrom(vector)
            -- vector: vector3  - the other vector3
            -- returns: vector3
    
            return (self + vector) / 2
        end,
        lerp = function(self, vector, t)
            -- synopsis: lerps two vectors
            -- <vector3>:lerp(vector, t)
            -- vector: vector3 - end vector
            -- t:      number  - lerp value, 0 to 1
            -- return: vector3

            return self + (vector - self) * t
        end,
        cross = function(a, b)
            -- synopsis: performs cross product on two vector3s
            -- <vector3>:cross(a, b)
            -- a: vector3 - first vector
            -- b: vector3 - second vector
            -- returns: vector3

            return Vector3.new(
                a.y * b.z - a.z * b.y,
                a.z * b.x - a.x * b.z,
                a.x * b.y - a.y * b.x
            )
        end
    }
}