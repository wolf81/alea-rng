--[[
This number generator is an adaptation from the random number generator that is 
part of rotLove.

The rotLove number generator is based on the Alea algorithm from Johannes Baagøe 
<baagoe@baagoe.com>
--]]

local mmin, mmax, mfloor, msqrt, mlog = math.min, math.max, math.floor, math.sqrt, math.log

local MULTIPLIER_F = 2.3283064365386963e-10 -- 2^-32
local MULTIPLIER_I = 0x100000000 -- 2^32

-- internal state
local s0 = 0
local s1 = 0
local s2 = 0
local c = 1
local seed = nil

-- a hashing function factory for internal use.
local function Mash()
  local n = 0xefc8249d

  return function(data)
    local data = tostring(data)

    for i = 1, data:len() do
      n = n + data:byte(i)
      local h = 0.02519603282416938 * n
      n = mfloor(h)
      h = h - n
      h = h * n
      n = mfloor(h)
      h = h - n
      n = n + h * MULTIPLIER_I
    end

    return mfloor(n) * MULTIPLIER_F
  end
end

local function setSeed(seed)
    c = 1
    seed = seed or os.time()

    local mash = Mash()
    s0 = mash(' ')
    s1 = mash(' ')
    s2 = mash(' ')

    s0 = s0 - mash(seed)
    if s0 < 0 then s0 = s0 + 1 end

    s1 = s1 - mash(seed)
    if s1 < 0 then s1 = s1 + 1 end

    s2 = s2 - mash(seed)
    if s2 < 0 then s2 = s2 + 1 end

    mash = nil
end

local function getSeed()
    return seed
end

local function getUniform()
    local t = 2091639 * s0 + c * MULTIPLIER_F
    s0 = s1
    s1 = s2
    c = mfloor(t)
    s2 = t - c
    return s2
end

function getUniformInt(lowerBound, upperBound)
    local max = mmax(lowerBound, upperBound)
    local min = mmin(lowerBound, upperBound)
    return mfloor(getUniform() * (max - min + 1)) + min
end

local function getState()
    return { s0, s1, s2, c, seed }
end

local function setState(t)
    s0, s1, s2, c, seed = t[1], t[2], t[3], t[4], t[5]
end

local function random(a, b)
    if not a then
        return getUniform()
    elseif not b then
        return getUniformInt(1, tonumber(a))
    else
        return getUniformInt(tonumber(a), tonumber(b))
    end
end

-- initialize the random number generator with a random seed
setSeed()

return {
    -- retrieving and setting state
    getState = getState,
    setState = setState,
    -- seeding functions
    getSeed = getSeed,
    setSeed = setSeed,
    -- same interface as Lua's math library
    random = random,
    randomseed = setSeed,
}
