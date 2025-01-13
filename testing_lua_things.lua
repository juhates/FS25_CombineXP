Combine = {}
Combine.__index = Combine

function Combine.new(power, capacity)
    local instance = setmetatable({}, Combine)
    instance.power = power
    instance.capacity = capacity
    return instance
end

function Combine:getPower()
    print(self.power)
end

mf = Combine.new(250, 8000)
mf:getPower()
