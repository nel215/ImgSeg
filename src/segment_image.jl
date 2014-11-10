using Images, Color
include("union_find.jl")

type Edge
    u::Int64
    v::Int64
    weight::Number

    function Edge(_u::Int64, _v::Int64, w::Number)
        new(_u, _v, w)
    end
end

function get_dist(x1::Int64, y1::Int64, c1::RGB, x2::Int64, y2::Int64, c2::RGB)
    (x1-x2)^2 + (y1-y2)^2 + ((c1.r-c2.r)*255)^2 + ((c1.g-c2.g)*255)^2 + ((c1.b-c2.b)*255)^2
end

function get_edges(img::Image, W=2)
    width = size(img, 1)
    height = size(img, 2)
    edges = Edge[]

    for x = 1:width, y = 1:height
        u = (y-1)*width+x
        for w = 0:W
            if x+w > width continue end
            for h = 0:W-w
                if w==0 && h==0 continue end
                if y+h > height continue end
                v = (y+h-1)*width+x+w
                d = get_dist(x,y,img[x,y],x+w,y+h,img[x+w,y+h])
                push!(edges, Edge(u, v, d^(0.5)))
            end
        end
    end
    edges
end

function segment(img::Image, K::Float64=500.0, MIN_SIZE::Int64=50, W::Int64=2)
    width = size(img, 1)
    height = size(img, 2)

    # enumerate and sort edges
    edges = get_edges(img, W)
    sort!(edges, by= e -> e.weight)

    # merge similar region
    unionFind = UnionFind(width*height)
    threshold = fill(1.0*K, width*height)
    for e = edges
        u = get_root(unionFind, e.u)
        v = get_root(unionFind, e.v)
        if u != v && e.weight <= min(threshold[u], threshold[v])
            union!(unionFind,u,v)
            r = get_root(unionFind, u)
            threshold[r] = e.weight + 1.0*K/get_size(unionFind, r)
        end
    end

    # merge small region
    for e = edges
        u = get_root(unionFind, e.u)
        v = get_root(unionFind, e.v)
        if u != v && min(get_size(unionFind, u), get_size(unionFind, v)) < MIN_SIZE
            union!(unionFind,u,v)
        end
    end

    # coloring
    colors = RGB[]
    for i = 1:width*height
        push!(colors, RGB(rand(),rand(),rand()))
    end
    res = copy(img)
    for x = 1:width, y = 1:height
        u = (y-1)*width+x
        r = get_root(unionFind, u)
        res[x,y] = colors[r]
    end

    res
end
