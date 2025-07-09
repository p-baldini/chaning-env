local evaluator = {}

-- The performance accumulator of the current epoch
local performance = nil



-- Initialize a new evaluation period
function evaluator.new_epoch(robot)
    performance = 0
    print('^ position [x,y,z]: ' ..
        robot.positioning.position.x .. ',' ..
        robot.positioning.position.y .. ',' ..
        robot.positioning.position.z
    )
end



-- Evaluates the performance of the controller as the proximity from obstacles,
-- direction, speed, and temperature.
function evaluator.update(robot)
    -- Find the maximum proximity value in [0, 1]
    max_proximity = 0

    for i = 1,24,3 do
        local value = robot.proximity[i].value
        if max_proximity < value then
            max_proximity = value
        end
    end

    -- Get the wheels speed in [0, 1]
    bvl = robot.wheels.velocity_left / 10
    bvr = robot.wheels.velocity_right / 10

    -- The robot performance considers the max proximity, speed and direction
    -- of the robot, and on the perceived temperature
    ef = 1 - math.sqrt(math.abs(bvl - bvr))
    ef = ef * (bvl + bvr) / 2
    ef = ef * (1 - max_proximity)
    ef = ef * 1 / (1 + math.exp(-10 * robot.temperature))

    -- Accumulate the step-performance to the epoch one
    performance = performance + ef
end



-- Evaluate the capability of the robot to avoid obstacles
function evaluator.performance(robot)
    return performance
end

return evaluator
