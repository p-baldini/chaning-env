local damage = require ££ DAMAGE_MODULE ££
local bn = require "bn"

-- Seed of the experiment for reproducibility
SEED = ££ SEED ££

-- The number of faults the robot undergoes
FAULTS_COUNT = ££ NUMBER_OF_FAULTS ££

-- Maximum motor speed
MAXIMUM_SPEED = 2

-- Number of nodes and bias of the BN
BN_BIAS = ££ BIAS ££
BN_NODES_COUNT = 100
BN_INPUT_NODES_COUNT = 24
BN_OUTPUT_NODES_COUNT = 2

-- Threshold to convert from real to binary values 
LIGHT_THRESHOLD = 0.2

-- Variables to store the robot distance from light
start_epoch_distance = 0
start_experiment_distance = 0

F = {}
I = {}
best_F = {}
best_I = {}
state = {}

steps_count = 0
EPOCH_STEPS = 250
SAFE_STEPS = 100000

in_mapping = {}
out_mapping = {}
best_in_mapping = {}
best_out_mapping = {}

performance = 0
best_performance = 0



-- Output the Euclidean distance from the light.
function distance_from_light()
    x = robot.positioning.position.x
    y = robot.positioning.position.y
    return math.sqrt(x^2 + y^2)
end



-- Evaluates the performance of the controller as the progress towards the
-- light (i.e., how nearer the robot got to the light).
function eval_function(d0)
    return d0 - distance_from_light()
end



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
    bn.set_seed_bn(SEED)

    F, I = bn.create_3RBN_bias_nosl(BN_NODES_COUNT, BN_BIAS)

    -- Overimpose functions with BIAS 0.5 on output nodes                       -- TODO perchè?
    for j = 1, 8 do
        F[BN_NODES_COUNT][j] = math.random(0,1)
        F[BN_NODES_COUNT-1][j] = math.random(0,1)
    end

    -- Initialize the BN state to 0s
    for i = 1, BN_NODES_COUNT do
    --     state[i] = math.random(0,1)
        state[i] = 0                                                            -- TODO inizializiamo tutto a 0?
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
    performance = 0
    best_performance = 0

    start_epoch_distance = distance_from_light()
    start_experiment_distance = start_epoch_distance
end



function step()
    -- 
    -- Damage set up
    -- 

    -- At half experiment enable the damages of the robot
    if steps_count == SAFE_STEPS then
        print('Damage!' .. ' distance: ' .. distance_from_light())
        bn.print_vector(best_in_mapping)
        damage.set_damage(FAULTS_COUNT)
    end

    -- 
    -- Evaluation and adaptation
    -- 

    -- Increment the step counter
    steps_count = steps_count + 1

    -- Update the traveled distance from the position at the start of the epoch
    performance = performance + eval_function(start_epoch_distance)

    -- End of epoch: check if current evaluation is equal to or better than
    -- previous one
    if math.fmod(steps_count, EPOCH_STEPS) == 0 then
        -- If the new coupling performs better than the best, set it as the new
        -- best
        if (performance > best_performance) then
            best_in_mapping = bn.table_copy(in_mapping)
            best_out_mapping = bn.table_copy(out_mapping)
            best_performance = performance
            -- best_F = bn.table_copy(F)
            -- best_I = bn.table_copy(I)
            log(steps_count .. ' ' .. best_performance)
            bn.print_vector(best_in_mapping)
        -- If the new mapping performs worse than the best, discard it and
        -- create a new one by modifying the best
        else
            in_mapping = bn.table_copy(best_in_mapping)
            out_mapping = bn.table_copy(best_out_mapping)
            change_mapping()
        end

        -- Calculate the current distance from the light
        start_epoch_distance = distance_from_light()

        print('epoch: ' .. steps_count // EPOCH_STEPS .. ' performance: ' .. performance .. ' distance: ' .. start_epoch_distance)

        -- Reset the performance during the epoch
        performance = 0
    end

    --
    -- INPUT OUTPUT CONTROL
    --

    -- Set up the output and input vectors to pass to the damage function
    outputs = {}
    inputs = {}
    for i = 1, 24 do
        inputs[i] = robot.light[i].value
    end

    -- Perturb the network by overriding some nodes with the sensory inputs
    damage.perturb_network(inputs, in_mapping, state, LIGHT_THRESHOLD)

    -- Update BN state: make an update step
    state = bn.update_3RBN(state, F, I)

    -- Get the output of the network and set the motors accordingly
    damage.extract_output(state, out_mapping, outputs, MAXIMUM_SPEED)
    robot.wheels.set_velocity(outputs[1], outputs[2])
end



function reset()
    -- put your code here
end



function destroy()
    print('SEED ' .. SEED)
    bn.print_vector(best_in_mapping)
    print('')
    print('best ' .. best_performance)
    print('distance at the start of the experiment: ' .. start_experiment_distance)
    print('distance at the end of the experiment: ' .. distance_from_light())
end
