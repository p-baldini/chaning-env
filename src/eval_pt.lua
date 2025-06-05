local evaluator = {}

-- The distance of the robot from the light at the start of the epoch
local start_epoch_distance = nil



-- Output the Euclidean distance from the light.
function distance_from_light()
    dx = robot.positioning.position.x - 450
    dy = robot.positioning.position.y - 450
    return math.sqrt(dx^2 + dy^2)
end



-- Initialize a new evaluation period
function evaluator.new_epoch(robot)
    start_epoch_distance = distance_from_light(robot)
    print('^ position [x,y,z]: ' ..
        robot.positioning.position.x .. ',' ..
        robot.positioning.position.y .. ',' ..
        robot.positioning.position.z
    )
    print('^ distance: ' .. start_epoch_distance)
end



-- Update the robot performance according to the current step
function evaluator.update(robot)
    -- Nothing
end



-- Evaluates the performance of the controller as the progress towards the
-- light (i.e., how nearer the robot got to the light).
function evaluator.performance(robot)
    return start_epoch_distance - distance_from_light(robot)
end

return evaluator
