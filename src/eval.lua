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
    -- Nothing
end


-- Evaluate the capability of the robot to avoid obstacles
function evaluator.performance(robot)
    return robot.temperature
end

return evaluator
