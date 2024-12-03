local damage = {}

-- Create a map saying for each actuator if it is broken or not.
local broken = { false, false }

-- Set the damage to the sensor and actuators. Select at random an actuator to
-- damage, setting its speed to half the ordinary one.
function damage.set_damage(_)
    index = math.random(0, 1) + 1
    broken[index] = true
end

-- Cycle the sensory inputs and force their values in the BN state.
-- 
-- @param[in] inputs: the sensory analog inputs.
-- @param[in] mapping: the mapping between sensor index and BN node.
-- @param[in, out] state: the BN state.
-- @param[in] light_threshold: discriminate if a light is perceived or not.
-- 
-- TODO check it pass the state reference and not a copy.
function damage.perturb_network(inputs, mapping, state, light_threshold)
    for i = 1, 24 do
        if inputs[i] > light_threshold then
            state[mapping[i]] = 1
        else
            state[mapping[i]] = 0
        end
    end
end

-- If the actuator is damaged, its maximum speed is halved.
-- 
-- @param[in] state: the BN state.
-- @param[in] mapping: the mapping between actuator index and BN node.
-- @param[in, out] outputs: the actuator control values to be set.
-- @param[in] max_speed: the maximum wheels speed.
function damage.extract_output(state, mapping, outputs, max_speed)
    outputs[1] = state[mapping[1]] * max_speed / (broken[1] and 2 or 1)
    outputs[2] = state[mapping[2]] * max_speed / (broken[2] and 2 or 1)
end

return damage
