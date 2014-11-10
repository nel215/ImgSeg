type UnionFind
    data::Array{Int64,1}

    function UnionFind(n::Int64)
        new(-ones(n))
    end
end

function union!(unionFind::UnionFind, x::Int64, y::Int64)
    x = get_root(unionFind, x)
    y = get_root(unionFind, y)
    data = unionFind.data
    if x != y
        if data[y] < data[x] x, y = y, x end
        data[x] += data[y]
        data[y] = x
    end
    x != y
end

function get_root(unionFind::UnionFind, x::Int64)
    data = unionFind.data
    data[x] < 0 ? x : data[x] = get_root(unionFind, data[x])
end

function get_size(unionFind::UnionFind, x::Int64)
    return -unionFind.data[get_root(unionFind, x)]
end

