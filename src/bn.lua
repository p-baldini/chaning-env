local bn = {}

local seed = os.time()

math.randomseed(seed)
-- math.randomseed(1555319823)


function bn.set_seed_bn(s)
    seed = s
    math.randomseed(seed)
end

function bn.get_seed()
    return seed
end


-- Random permutation
function bn.shuffle(tbl)
    for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end


-- copying tables the right way
function bn.table_copy(t)
    local t2 = {}
    for key,value in pairs(t) do
        t2[key] = value
    end
    return t2
end



-- Print table (tailored to functions and inputs)
function bn.print_table(tbl)
    for i = 1,#tbl do
        l = tbl[i]
        for j = 1,#l do
        io.write(l[j]," ")
        end
        io.write("\n")
    end
    print()
end


-- Print vector
function bn.print_vector(v)
    for i = 1,#v do
        io.write(v[i]," ")
    end
    print()
end


-- Create RBN with k=2 and p=0.5
function bn.create_RBN(n)
    local F = {}          -- create matrix of Boolean functions
    for i=1,n do
        F[i] = {}
        for j=1,4 do
        F[i][j] = math.random(0,1)
        end
    end
    local IN = {}          -- create matrix of inputs (self-loops allowed)
    indexes = {}
    for i = 1,n do
        indexes[i] = i
    end
    for i = 1,n do
        IN[i] = {}
        perm = bn.shuffle(indexes)
        IN[i][1] = perm[1]
        IN[i][2] = perm[2]
    end  
    return F,IN
end



-- Create RBN with k=2 and bias p
function bn.create_RBN_bias(n,p)
    local F = {}          -- create matrix of Boolean functions
    for i=1,n do
        F[i] = {}
        for j=1,4 do
        if math.random() <= p then
    F[i][j] = 1
        else
    F[i][j] = 0
        end
        end
    end
    local IN = {}          -- create matrix of inputs (self-loops allowed)
    indexes = {}
    for i = 1,n do
        indexes[i] = i
    end
    for i = 1,n do
        IN[i] = {}
        perm = bn.shuffle(indexes)
        IN[i][1] = perm[1]
        IN[i][2] = perm[2]
    end  
    return F,IN
end



-- Create RBN with k=3 and bias p, self-loops allowed
function bn.create_3RBN_bias(n,p)
    local F = {}          -- create matrix of Boolean functions
    for i=1,n do
        F[i] = {}
        for j=1,8 do
        if math.random() <= p then
    F[i][j] = 1
        else
    F[i][j] = 0
        end
        end
    end
    local IN = {}          -- create matrix of inputs (self-loops allowed)
    indexes = {}
    for i = 1,n do
        indexes[i] = i
    end
    for i = 1,n do
        IN[i] = {}
        perm = bn.shuffle(indexes)
        for j = 1,3 do
        IN[i][j] = perm[j]
        end
    end  
    return F,IN
end






-- Create RBN with k=3 and bias p, self-loops NOT allowed
function bn.create_3RBN_bias_nosl(n,p)
    local F = {}          -- create matrix of Boolean functions
    for i=1,n do
        F[i] = {}
        for j=1,8 do
        if math.random() <= p then
    F[i][j] = 1
        else
    F[i][j] = 0
        end
        end
    end
    local IN = {}          -- create matrix of inputs (self-loops not allowed)
    for i = 1,n do
        IN[i] = {}
        indexes = {}
        j = 1
        for h = 1,n do
        if h ~= i then
    indexes[j] = h
    j = j + 1
        end
        end
        perm = bn.shuffle(indexes)
        for j = 1,3 do
        IN[i][j] = perm[j]
        end
    end  
    return F,IN
end





-- Update node, given the index of the node and the global state of the network. Returns node updated value.
function bn.update_node(i,state,F,I)
    in_1 = state[I[i][1]]
    in_2 = state[I[i][2]]

    u = 0
    if in_1 == 0 and in_2 == 0 then
        u = F[i][1]
    elseif in_1 == 0 and in_2 == 1 then
        u = F[i][2]
    elseif in_1 == 1 and in_2 == 0 then
        u = F[i][3]
    else
        u = F[i][4]
    end

    return u
end



-- Update node for 3RBN, given the index of the node and the global state of the network. Returns node updated value.
function bn.update_node_3RBN(i,state,F,I)
    x = {}
    for j = 1,3 do
        x[j] = state[I[i][j]]
    end

    y = (x[1] + 2*x[2] + 4*x[3]) + 1
    u = F[i][y]

    return u
end



-- Update state. Returns new state.
function bn.update(state,F,I)
    new_state = bn.table_copy(state)
    for i = 1,#state do
        new_state[i] = bn.update_node(i,state,F,I)
    end
    
    return new_state
end



-- Update state. Returns new state.
function bn.update_3RBN(state,F,I)
    new_state = bn.table_copy(state)
    for i = 1,#state do
        new_state[i] = bn.update_node_3RBN(i,state,F,I)
    end
    
    return new_state
end




return bn
