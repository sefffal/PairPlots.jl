using GLMakie, PairPlots, Distributions


# Generate some data to visualize
N = 100_000
a = [2randn(N÷2) .+ 6; randn(N÷2)]
b = [3randn(N÷2); 2randn(N÷2)]
c = randn(N)
d = c .+ 0.6randn(N)

# Pass data in a format compatible with Tables.jl
# Here, simply a named tuple of vectors.
table = (;a, b, c, d)

##

pairplot(table)
