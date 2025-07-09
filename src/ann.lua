local ann = {}

local seed = os.time()

math.randomseed(seed)


-- Set seed used to create and update the ANN
function ann.set_seed(s)
    seed = s
    math.randomseed(seed)
end


-- Get seed used to create and update the ANN
function ann.get_seed()
    return seed
end


-- Random change the weights of the ANN, but keep them in -1, 1
function ann.change(net, p)
    for i = 1,#net do
        for j = 1,#net[i] do
            if math.random() <= p then
                net[i][j] = math.random(-5, 5) / 100.0
                net[i][j] = math.max(-1, net[i][j])
                net[i][j] = math.min( 1, net[i][j])
            end
        end
    end
end


-- Copy the ANN weights
function ann.copy(old)
    local new = {}

    for i = 1,#old do
        new[i] = {}

        for j = 1,#old[i] do
            new[i][j] = old[i][j]
        end
    end

    return new
end


-- Print ANN
function ann.print(net)
    for i = 1,#net do
        for j = 1,#net[i] do
            io.write(net[i][j]," ")
        end
    end
    print()
end


-- Create ANN
function ann.create(inc, outc)
    local res = {}

    for i = 1,outc do
        res[i] = {}

        for j = 1,inc do
            res[i][j] = math.random(0, 0) / 100.0
        end
    end

    return res
end


-- Compute the output according to the input
function ann.compute(net, is)
    local outputs = {}

    for i = 1,#net do
        local ws = net[i]
        local sum = 0

        for j = 1,#ws do
            sum = is[j] * ws[j]
        end

        -- Sigmoid activation function [-1, 1]
        outputs[i] = 1 / (1 + math.exp(-4 * sum))
    end

    return outputs
end


return ann
