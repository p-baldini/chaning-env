--
-- Elman Recurrent Neural Network.
--
require "matrix"
require "mymath"

local enn = {}

local seed = os.time()

math.randomseed(seed)


-- Set seed used to create and update the RNN
function enn.set_seed(s)
    seed = s
    math.randomseed(seed)
end


-- Get seed used to create and update the RNN
function enn.get_seed()
    return seed
end


-- Create RNN based on the Elman Network. All the weights
-- are in [-1, 1], except the output one, that will be
-- adapted runtime.
-- The starting context nodes value is 1.
function enn.create(incount, hidcount, outcount)
    -- Initialize context units state with 1s
    local cs = matrix:new(hidcount, 1, 1)

    -- Create the weights matrix from input to hidden nodes
    -- and randomly set the weights in [-1, 1]; consider
    -- also the bias weights
    local l1 = matrix:new(hidcount, incount + 1, 0)
    local l1 = matrix.random(l1, -100, 100)
    local l1 = matrix.divnum(l1, 100)

    -- Create the weights matrix from context to hidden
    -- nodes and randomly set the weights in [-1, 1]
    local lc = matrix:new(hidcount, 1, 0)
    local lc = matrix.random(lc, -100, 100)
    local lc = matrix.divnum(lc, 100)

    -- Create the weights matrix from hidden to output
    -- nodes and set the weights to zero; consider also the
    -- bias weights
    local l2 = matrix:new(outcount, hidcount + 1, 0)
    local l2 = matrix.random(l2, -0, 0)
    local l2 = matrix.divnum(l2, 100)

    return { l1 = l1, lc = lc, cs = cs, l2 = l2 }
end


-- Compute the output according to the input
function enn.compute(enn, inputs)
    -- Check that the number of inputs match with the
    -- number of input nodes, otherwise exit
    if #inputs + 1 ~= #enn.l1[1] then
        os.exit(2)
    end

    -- Set the input and bias values in a column matrix
    local is = { inputs }
    is[1][#inputs + 1] = 1
    is = matrix.transpose(is)

    -- Compute the value of the hidden nodes according to
    -- the inputs and bias, and then add the value of
    -- context nodes
    local hs = matrix.add(
        matrix.mul(enn.l1, is),
        matrix.mul(enn.lc, enn.cs)
    )

    -- Apply the activation function on the hidden nodes
    for i = 1, #hs[1] do
        hs[1][i] = sigmoid(hs[1][i])
    end

    -- Copy the value of the hidden nodes to the context
    enn.cs = hs

    -- Compute the value of the output nodes according to
    -- the hidden nodes and bias
    hs[#hs + 1] = { 1 }
    local os = matrix.mul(enn.l2, hs)

    -- Apply the activation function on the hidden nodes
    for i = 1, #os[1] do
        os[1][i] = sigmoid(os[1][i])
    end

    return enn, { os[1][1], os[2][1] }
end


-- Random change the weights of the RNN, but keep them in
-- [-1, 1]
function enn.change(enn, p, perf)
    -- Multiplier to increase intensity of perturbation
    -- with decrease of performance
    mult = math.exp(-5 * perf)
    dev = 0.75

    for i = 1, #enn.l1 do
        for j = 1, #enn.l1[1] do
            if math.random() <= p then
                enn.l1[i][j] = enn.l1[i][j] + mult * rand(-dev, dev)
                enn.l1[i][j] = math.max(-1, enn.l1[i][j])
                enn.l1[i][j] = math.min( 1, enn.l1[i][j])
            end
        end
    end

    for i = 1, #enn.lc do
        for j = 1, #enn.lc[1] do
            if math.random() <= p then
                enn.lc[i][j] = enn.lc[i][j] + mult * rand(-dev, dev)
                enn.lc[i][j] = math.max(-1, enn.lc[i][j])
                enn.lc[i][j] = math.min( 1, enn.lc[i][j])
            end
        end
    end

    for i = 1, #enn.l2 do
        for j = 1, #enn.l2[1] do
            if math.random() <= p then
                enn.l2[i][j] = enn.l2[i][j] + mult * rand(-dev, dev)
                enn.l2[i][j] = math.max(-1, enn.l2[i][j])
                enn.l2[i][j] = math.min( 1, enn.l2[i][j])
            end
        end
    end
end


-- Copy the RNN weights
function enn.copy(enn)
    return {
        l1 = matrix.copy(enn.l1),
        lc = matrix.copy(enn.lc),
        cs = matrix.copy(enn.cs),
        l2 = matrix.copy(enn.l2)
    }
end


-- Print RNN
function enn.print(enn)
    print("Network:")
    print("l1")
    matrix.print(enn.l1)
    print("lc")
    matrix.print(matrix.transpose(enn.lc))
    print("cs")
    matrix.print(matrix.transpose(enn.cs))
    print("l2")
    matrix.print(enn.l2)
end


return enn
