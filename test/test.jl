include("../src/ImgSeg.jl")

using Images
img = imread("assets/cat.jpg")
res = ImgSeg.segment(img)
show(res)
