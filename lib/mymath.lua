-- Random float numbers
function rand(start, finish)
    return math.random(start * 100, finish * 100) / 100.0
end


-- Sigmoid function: compute the sigmoid value of an input
-- value x. Useful as ANNs activation function.
function sigmoid(x)
    return 1 / (1 + math.exp(-x))
end
