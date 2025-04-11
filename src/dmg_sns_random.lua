local damage = {}

-- Create a map saying for each light sensor if it is broken or not.
local broken = {}
for i = 1, 24 do
    broken[i] = false
end

-- Set the damage to the sensor and actuators. Select at random a healthy
-- sensor and start damaging its following ones.
-- 
-- @param[in] number_of_faults: the number of damaged sensors.
function damage.set_damage(number_of_faults)
    if number_of_faults > 0 then
        sample = math.random(1, 24)
        for i = 1, number_of_faults do
            broken[sample] = true
            sample = sample + 1
            if sample > 24 then
                sample = 1
            end
        end
    end
end

-- A random input force a random value on the BN node. Cycle the sensory inputs
-- and, if not broken, force their reading values in the BN state.
-- 
-- @param[in] inputs: the sensory analog inputs.
-- @param[in] mapping: the mapping between sensor index and BN node.
-- @param[in, out] state: the BN state.
-- @param[in] light_threshold: discriminate if a light is perceived or not.
-- 
-- TODO check it pass the state reference and not a copy.
function damage.perturb_network(inputs, mapping, state, light_threshold)
    for i = 1, 24 do
        if not broken[i] then
            if inputs[i] > light_threshold then
                state[mapping[i]] = 1
            else
                state[mapping[i]] = 0
            end
        else
            state[in_mapping[i]] = math.random(0, 1)
        end
    end
end

-- The control value for the wheels is simply the output node value times the
-- maximum speed.
-- 
-- @param[in] state: the BN state.
-- @param[in] mapping: the mapping between actuator index and BN node.
-- @param[in, out] outputs: the actuator control values to be set.
-- @param[in] max_speed: the maximum wheels speed.
function damage.extract_output(state, mapping, outputs, max_speed)
    outputs[1] = state[mapping[1]] * max_speed
    outputs[2] = state[mapping[2]] * max_speed
end

return damage
