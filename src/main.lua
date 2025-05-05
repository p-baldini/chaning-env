-- Main experiment logic.
-- 
-- The user should provide:
-- @param[in] DAMAGE_MODULE the type of damage to use
-- @param[in] EVALUATOR the evaluator of the robot behavior
-- @param[in] SEED the seed of the experiment
-- @param[in] NUMBER_OF_FAULTS the number of damaged transducers of the robot
-- @param[in] BIAS the BN bias
-- @param[in] EPOCH_STEPS the length of an epoch in steps
-- @param[in] SAFE_EPOCHS the number of epochs before a fault occurs
-- @param[in] SENSORS_TYPE the type of sensors used in the experiment
-- 
-- @author Paolo Baldini
local bn = require "bn"
local damage = require ££ DAMAGE_MODULE ££
local evaluator = require ££ EVALUATOR ££

-- Seed of the experiment for reproducibility
SEED = ££ SEED ££

-- The number of faults the robot undergoes
FAULTS_COUNT = ££ NUMBER_OF_FAULTS ££

-- Maximum motor speed
MAXIMUM_SPEED = 2

-- Number of nodes and bias of the BN
BN_BIAS = ££ BIAS ££
BN_NODES_COUNT = 500
BN_INPUT_NODES_COUNT = 24
BN_OUTPUT_NODES_COUNT = 2

-- Threshold to convert from real to binary values 
SENSORY_THRESHOLD = 0.2

EPOCH_STEPS = ££ EPOCH_STEPS ££
FAULT_INSTANT = ££ SAFE_EPOCHS ££ * EPOCH_STEPS
steps_count = 0

F = {}
I = {}
best_F = {}
best_I = {}
state = {}

in_mapping = {}
out_mapping = {}
best_in_mapping = {}
best_out_mapping = {}

best_performance = 0



-- Check whether a sensor or an actuator is connected to the BN node with the
-- given index.
function connected_node(index)
    for i = 1, BN_OUTPUT_NODES_COUNT do
        if out_mapping[i] == index then
            return true
        end
    end
    for i = 1, BN_INPUT_NODES_COUNT do
        if in_mapping[i] == index then
            return true
        end
    end
    return false
end



-- Change the coupling of up to 6 inputs to un-coupled nodes.
function change_mapping()
    zmax = math.random(1, BN_INPUT_NODES_COUNT / 4)
    for z = 1, zmax do
        i = math.random(1, #in_mapping)

        repeat
            n = math.random(1, BN_NODES_COUNT)
        until not connected_node(n)

        in_mapping[i] = n
    end
end



-- Set up the experiment.
function init()
    print('# seed: \t\t\t' .. SEED)
    print('# PHASE 1')

    io.write('# position ')
    print(robot.positioning.position)

    io.write('# orientation ')
    print(robot.positioning.orientation)

    bn.set_seed_bn(SEED)

    F, I = bn.create_3RBN_bias_nosl(BN_NODES_COUNT, BN_BIAS)

    -- Overimpose functions with BIAS 0.5 on output nodes to mitigate biassed
    -- behaviors
    for j = 1, 8 do
        F[BN_NODES_COUNT][j] = math.random(0,1)
        F[BN_NODES_COUNT-1][j] = math.random(0,1)
    end

    -- Initialize the BN state to 0s
    for i = 1, BN_NODES_COUNT do
        state[i] = 0
    end

    --   print('BN SEED: ' .. SEED)
    --   bn.print_table(F)
    --   bn.print_table(I)

    -- Set the initial mapping from the sensors to the BN nodes
    for i = 1, BN_INPUT_NODES_COUNT do
        in_mapping[i] = i
    end
    -- Set the initial mapping from the BN nodes to the actuators
    for i = 1, BN_OUTPUT_NODES_COUNT do
        out_mapping[i] = BN_NODES_COUNT - i + 1
    end

    -- Initialize the best mapping and state of the BN
    best_in_mapping = bn.table_copy(in_mapping)
    best_out_mapping = bn.table_copy(out_mapping)
    best_F = bn.table_copy(F)
    best_I = bn.table_copy(I)

    steps_count = 0
    best_performance = 0

    -- Start the first evaluation epoch
    evaluator.new_epoch(robot)
end



function step()
    -- 
    -- Damage set up
    -- 

    -- At half experiment enable the damages of the robot
    if steps_count == FAULT_INSTANT then
        print('\n# PHASE 2')

        io.write('# position ')
        print(robot.positioning.position)

        io.write('# orientation ')
        print(robot.positioning.orientation)

        damage.set_damage(FAULTS_COUNT)
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
        performance = evaluator.performance(robot)

        io.write("- mapping: \t\t\t")
        bn.print_vector(in_mapping)
        print('* performance: \t\t' .. performance)

        -- Every odd epoch we starts a re-evaluation of the best configuration;
        -- Every even epoch we search for better configuration
        exploratory_epoch = math.fmod(steps_count / EPOCH_STEPS, 2) == 0

        -- If we are starting an exploration, it means we just re-evaluated
        -- the best configuration: update its performance;
        -- Alternatively, if we found a better configuration during the 
        -- exploration, set it as the new best.
        if exploratory_epoch
        then
            best_performance = 0.5 * best_performance + 0.5 * performance
        elseif performance > best_performance then
            best_in_mapping = bn.table_copy(in_mapping)
            best_out_mapping = bn.table_copy(out_mapping)
            best_performance = performance
            -- best_F = bn.table_copy(F)
            -- best_I = bn.table_copy(I)
        end

        -- Set the best coupling as the starting one
        in_mapping = bn.table_copy(best_in_mapping)
        out_mapping = bn.table_copy(best_out_mapping)

        -- If we are starting an exploratory epoch, modify the best coupling
        if exploratory_epoch then
            change_mapping()
        end

        -- Start a new evaluation epoch
        evaluator.new_epoch(robot)
    end

    --
    -- INPUT OUTPUT CONTROL
    --

    -- Set up the output and input vectors to pass to the damage function
    outputs = {}
    inputs = {}
    for i = 1, 24 do
        inputs[i] = robot.££ SENSORS_TYPE ££[i].value
    end

    -- Perturb the network by overriding some nodes with the sensory inputs
    damage.perturb_network(inputs, in_mapping, state, SENSORY_THRESHOLD)

    -- Update BN state: make an update step
    state = bn.update_3RBN(state, F, I)

    -- Get the output of the network and set the motors accordingly
    damage.extract_output(state, out_mapping, outputs, MAXIMUM_SPEED)
    robot.wheels.set_velocity(outputs[1], outputs[2])
end



function reset()
    -- Nothing
end



function destroy()
    -- Nothing
end
