--
-- Elman Recurrent Neural Network.
--
local vcts = require "vectors"

local enn = {}

local seed = os.time()

math.randomseed(seed)


-- Sigmoid activation function: compute the
-- sigmoid value of an input value x.
function sigmoid(x)
    return 1 / (1 + math.exp(-x))
end


-- Set seed used to create and update the RNN Reservoir
function enn.set_seed(s)
    seed = s
    math.randomseed(seed)
end


-- Get seed used to create and update the RNN
function enn.get_seed()
    return seed
end


-- Create RNN based on the Elman Network.
-- All the weights are in [0, 1].
-- The starting delay nodes value is 1.
function enn.create(incount, hidcount, outcount)
    local states = {}
    local weights = {}

    -- Initialize delay units state with 1s
    for i = 1, hidcount do
        states[i] = 1
    end

    -- Calculate total number of weights:
    -- ° input X hidden nodes
    -- ° delayed nodes (one per hidden)
    -- ° bias (one per hidden)
    -- ° hidden nodes (one per delayed)
    -- ° hidden X output nodes
    -- ° bias (one per output)
    weightend =             hidcount * incount
    weightend = weightend + hidcount
    weightend = weightend + hidcount
    weightend = weightend + hidcount
    weightend = weightend + hidcount * outcount
    weightend = weightend + outcount

    -- Initialize input-to-hidden weights
    for i = 1, weightend do
        weights[i] = math.random(0, 100) / 100.0
    end

    -- Set context units in-weights to 1 (standard Elman model)
    -- start_idx = (incount + 2) * hidcount + 1
    -- finish_idx = start_idx + hidcount
    -- for i = start_idx, finish_idx do
    --     weights[i] = 1
    -- end
    -- -- Set context units out-weights to 1 NON-STANDARD
    -- for i = 1, hidcount do
    --     weights[i * (incount + 2)] = 1
    -- end

    return {
        incount = incount,
        hidcount = hidcount,
        outcount = outcount,
        states = states,
        weights = weights
    }
end


-- Compute the output according to the input
function enn.compute(enn, inputs)
    local outputs = {}
    local hiddens = {}

    incount = enn[1]
    hidcount = enn[2]
    outcount = enn[3]
    states = enn[4]
    weights = enn[5]

    -- Check that the number of inputs match with
    -- the number of input nodes, otherwise exit
    if #inputs ~= incount then
        os.exit(2)
    end

    -- Compute the state of the hidden nodes
    for i = 1, hidcount do
        -- Get the slice of the weight array
        -- belonging to the hidden node,
        -- including inputs, delay, and bias
        start_idx = (i - 1) * (incount + 2) + 1
        finish_idx = start_idx + incount + 2 - 1

        -- Set the delay and the bias values of
        -- the hidden node after the inputs
        inputs[incount + 1] = states[i]
        inputs[incount + 2] = 0 -- % TODO 0 sembra meglio...

        -- Compute the state according to the inputs, delay, and bias
        node_weights = vcts.sub(weights, start_idx, finish_idx)
        hiddens[i] = vcts.rowXcol(node_weights, inputs)

        -- Apply the sigmoid activation function
        hiddens[i] = sigmoid(hiddens[i])

        -- Update the delay nodes state
        delay_weight_idx = (incount + 2) * hidcount + i
        states[i] = hiddens[i] * weights[delay_weight_idx]
    end

    -- Compute the state of output nodes
    for i = 1, outcount do
        -- Get the slice of the weight array
        -- belonging to the output node,
        -- including inputs, and bias.
        -- The output weights start after the
        -- hidden and delay weights.
        start_idx = (incount + 2) * hidcount + hidcount
        start_idx = start_idx + (i - 1) * (hidcount + 1) + 1
        finish_idx = start_idx + hidcount

        -- Set the bias values of the output node
        -- after the inputs
        hiddens[hidcount + 1] = 0 -- % TODO 0 sembra meglio...

        -- Compute the state according to the inputs, and bias
        node_weights = vcts.sub(weights, start_idx, finish_idx)
        outputs[i] = vcts.rowXcol(node_weights, hiddens)

        -- Apply the sigmoid activation function
        outputs[i] = sigmoid(outputs[i])
    end

    enn = {
        incount,
        hidcount,
        outcount,
        states,
        weights
    }
    return enn, outputs
end


-- Random change the weights of the RNN, but keep them in -1, 1
function enn.change(enn, p, perf)
    hidcount, outcount = enn[2], enn[3]

    start_idx = #enn[5] - (hidcount + 1) * outcount

    -- Multiplier to increase intensity of perturbation with decrease of performance
    mult = math.exp(-5 * perf)

    for i = start_idx, #enn[5] do
        if math.random() <= p then
            enn[5][i] = enn[5][i] + mult * math.random(-50, 50) / 100.0
            enn[5][i] = math.max(0, enn[5][i])
            enn[5][i] = math.min(1, enn[5][i])
        end
    end
end


-- Copy the RNN weights
function enn.copy(old)
    local new = {
        incount = old.incount,
        hidcount = old.hidcount,
        outcount = old.outcount,
        states = {}, weights = {}
    }

    for i = 1, #old.states do
        new.states[i] = old.states[i]
    end
    for i = 1, #old.weights do
        new.weights[i] = old.weights[i]
    end

    return new
end


-- Print RNN
function enn.print(net)
    io.write(
        "Elman network shape: ",
        net.incount, "x", net.hidcount, "x", net.outcount, " ",
        "-- Weights: "
    )
    for i = 1,#net.weights do
        io.write(net.weights[i], " ")
    end
    print()
end


return enn
