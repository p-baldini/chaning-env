-- Main experiment logic.
-- 
-- The user should provide:
-- @param[in] SEED the seed of the experiment
-- @param[in] EPOCH_STEPS the length of an epoch in steps
-- @param[in] PHASE_1_EPOCHS the number of epochs before a fault occurs
-- 
-- @author Paolo Baldini
local enn = require "enn"
local evaluator = require "eval"

-- Seed of the experiment for reproducibility
SEED = ££ SEED ££
MUTATION_PROBABILITY = 0.2

-- Maximum motor speed
MAXIMUM_SPEED = 10

EPOCH_STEPS = ££ EPOCH_STEPS ££
PHASE_THRESHOLD = ££ PHASE_1_EPOCHS ££ * EPOCH_STEPS

steps_count = 0

season = ££ SEASON ££

curr_ann = {}
best_ann = {}
best_prf = 0


-- Calculate the temperature perceived by the robot according to its position in the arena, in [0, 1]
function update_temperature(robot)
    if math.abs(robot.positioning.position.x) > 50 or math.abs(robot.positioning.position.y) > 50 then
        io.write("Experiment " .. SEED .. " failed: robot out of the arena")
        os.exit(-1)
    end

    local temp = (robot.positioning.position.x + 50) / 100

    robot.temperature = math.abs(temp - season)
end


-- Set up the experiment.
function init()
    enn.set_seed(SEED)

    -- Create ANN with 3 inputs (2 light + 1 temperature) and 2 outputs
    curr_ann = enn.create(2 + 1, 6, 2)

    -- Initialize the best mapping and state of the ann
    best_ann = enn.copy(curr_ann)
    best_prf = 0

    steps_count = 0

    -- Initialize the temperature "sensor"
    update_temperature(robot)

    -- Start the first evaluation epoch
    evaluator.new_epoch(robot)
end


function step()
    -- 
    -- Phase-logs and damage set up
    -- 

    -- Log the experiment seed and start phase one
    if steps_count == 0 then
        print('# seed: \t\t\t' .. SEED)
        print('# PHASE 1')
    end

    -- At half experiment switch the season
    if steps_count == PHASE_THRESHOLD then
        print('\n# PHASE 2')
        season = 1 - season
    end

    -- 
    -- Evaluation and adaptation
    -- 

    -- Increment the step counter
    steps_count = steps_count + 1

    -- Update the robot performance according to the latter step
    evaluator.update(robot)

    -- End of epoch: log results and check if current evaluation is equal to or
    -- better than previous one
    if math.fmod(steps_count, EPOCH_STEPS) == 0 then
        -- Get the robot performance since the start of the epoch
        prf = evaluator.performance(robot)

        io.write("- current-ann: \t\t")
        enn.print(curr_ann)
        print('* performance: \t\t' .. prf)

        -- Every odd epoch we starts a re-evaluation of the best configuration;
        -- Every even epoch we search for better configuration
        exploratory_epoch = math.fmod(steps_count / EPOCH_STEPS, 2) == 0

        -- If we are starting an exploration, it means we just re-evaluated
        -- the best configuration: update its performance;
        -- Alternatively, if we found a better configuration during the 
        -- exploration, set it as the new best.
        if exploratory_epoch
        then
            best_prf = 0.5 * best_prf + 0.5 * prf
        elseif prf > best_prf then
            best_ann = enn.copy(curr_ann)
            best_prf = prf
        end

        -- Set the best coupling as the starting one
        curr_ann = enn.copy(best_ann)

        -- If we are starting an exploratory epoch, modify the best coupling
        if exploratory_epoch then
            enn.change(curr_ann, MUTATION_PROBABILITY, best_prf)
        end

        -- Start a new evaluation epoch
        evaluator.new_epoch(robot)
    end

    --
    -- INPUT OUTPUT CONTROL
    --

    -- Update the temperature sensor
    update_temperature(robot)

    -- Set up the output and input vectors to pass to the damage function
    inputs = {
        robot.light[1].value,
        robot.light[12].value,
        robot.temperature
    }

    -- Get the output of the ANN and set the motors accordingly
    curr_ann, outputs = enn.compute(curr_ann, inputs)
    robot.wheels.set_velocity(
        outputs[1] * MAXIMUM_SPEED,
        outputs[2] * MAXIMUM_SPEED
    )
end


function reset()
    -- Nothing
end


function destroy()
    -- Nothing
end
