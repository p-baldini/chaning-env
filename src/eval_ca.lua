local evaluator = {}

-- The performance accumulator of the current epoch
local performance = nil



-- Round to 1 values greater or similar to 1.
function sigma(x)
    if x > 0.9 then -- TODO no else?
        x = 1
    end
    return x
end



-- Initialize a new evaluation period
function evaluator.new_epoch(robot)
    performance = 0
end



-- Evaluates the performance of the controller as the proximity from obstacles,
-- direction and speed.
function evaluator.update(robot)
    max_proximity = 0
    for i = 1, 24 do
        value = sigma(robot.proximity[i].value)
        if max_proximity < value then
            max_proximity = value
        end
    end

    bvl = 0
    bvr = 0
    if robot.wheels.velocity_left > 0 then
        bvl = 1
    end
    if robot.wheels.velocity_right > 0 then
        bvr = 1
    end

    -- The robot performance considers the max proximity, speed and direction
    -- of the robot.
    ef = (1 - math.sqrt(math.abs(bvl - bvr)))
    ef = ef * (bvl + bvr) / 2
    ef = ef * (1 - max_proximity)

    -- Accumulate the step-performance to the epoch one
    performance = performance + ef
end



-- Evaluate the capability of the robot to avoid obstacles
function evaluator.performance(robot)
    return performance
end

return evaluator
