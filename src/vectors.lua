local vec = {}


function vprint(v)
    for i = 1, #v do
        print(v[i])
    end
end


-- Row vector times row vector.
-- Outputs a row vector.
function vec.rowXrow(v1, v2)
    local out = {}

    for i = 1, #v1 do
        out[i] = v1[i] * v2[i]
    end

    return out
end


-- Row vector times column vector.
-- Outputs a scalar value.
function vec.rowXcol(v1, v2)
    local out = 0

    for i = 1, #v1 do
        out = out + v1[i] * v2[i]
    end

    return out
end


-- Column vector times row vector.
-- Outputs a 2d matrix of size length-column X length-row.
function vec.colXrow(v1, v2)
    local out = {}

    for i = 1, #v1 do
        out[i] = {}

        for j = 1, #v2 do
            out[i][j] = v1[i] * v2[j]
        end
    end

    return out
end


-- Column vector times column vector.
-- Outputs a column vector.
function vec.colXcol(v1, v2)
    local out = {}

    for i = 1, #v1 do
        out[i] = 0

        for j = 1, #v2 do
            out[i] = out[i] + v1[i] * v2[j]
        end
    end

    return out
end


-- Sum two vectors.
function vec.sum(v1, v2)
    local out = {}

    for i = 1, #v1 do
        out[i] = v1[i] + v2[i]
    end

    return out
end


-- Create a new array containing a view of the
-- original one, from the specified start to end
-- index.
function vec.sub(array, start, finish)
    if start > finish or finish > #array then
        os.exit(3)
    end

    local out = {}

    -- Copy the values in the new array
    for i = start, finish do
        out[i - start + 1] = array[i]
    end

    return out
end


return vec
