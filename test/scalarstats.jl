using StatsBase
using Compat
using Compat.Test

##### Location

## geomean

@test geomean([1, 2, 3])    ≈ (6.0)^(1/3)
@test geomean(1:3)          ≈ (6.0)^(1/3)
@test geomean([2, 8])       ≈ 4.0
@test geomean([4, 1, 1/32]) ≈ 0.5
@test geomean([1, 0, 2]) == 0.0

## harmmean

@test harmmean([1, 2, 3]) ≈ 3 / (1 + 1/2 + 1/3)
@test harmmean(1:3)       ≈ 3 / (1 + 1/2 + 1/3)
@test harmmean([1, 2, 4]) ≈ 12 / 7

## genmean
@test genmean([1,1,2,3], 1)         ≈ 7/4
@test genmean([1,4,2], -1)          ≈ 12/7
@test genmean([1,1,2,3], 0)         ≈ (6.0)^(1/4)
@test genmean([1.2,-0.5,0], 2)      ≈ sqrt(169/300)
@test genmean([16/9,0.25,1.0], 1.5) ≈ (755/648)^(2/3)
# Test numerical stability for `p` close to 0 (genmean should be close to geometric mean).
@test isapprox(genmean([1,1,2,3], -1e-8), (6.0)^(1/4), atol=1e-8)
# Test numerical stability for large `p` (genmean should be close to max).
@test isapprox(genmean([0.98,1.02], 1e4), 1.02, atol=1e-4)

## mode & modes

@test mode([1, 2, 3, 3, 2, 2, 1], 1:3) == 2
@test modes([1, 2, 3, 3, 2, 2, 1], 1:3) == [2]
@test modes([1, 3, 2, 3, 3, 2, 2, 1], 1:3) == [2, 3]

@test mode([1, 2, 3, 3, 2, 2, 1]) == 2
@test modes([1, 2, 3, 3, 2, 2, 1]) == [2]
@test sort(modes([1, 3, 2, 3, 3, 2, 2, 1])) == [2, 3]

## zscores

@test zscore([-3:3;], 1.5, 0.5) == [-9.0:2.0:3.0;]

a = [3 4 5 6; 7 8 1 2; 6 9 3 0]
z1 = [4. 6. 8. 10.; 5. 6. -1. 0.; 1.5 3.0 0.0 -1.5]
z2 = [8. 2. 3. 1.; 24. 10. -1. -1.; 20. 12. 1. -2.]

@test zscore(a, [1, 2, 3], [0.5, 1.0, 2.0])    ≈ z1
@test zscore(a, [1 3 2 4], [0.25 0.5 1.0 2.0]) ≈ z2

@test zscore!(collect(-3.0:3.0), 1.5, 0.5) == [-9.0:2.0:3.0;]
@test zscore!(float(a), [1, 2, 3], [0.5, 1.0, 2.0])    ≈ z1
@test zscore!(float(a), [1 3 2 4], [0.25 0.5 1.0 2.0]) ≈ z2

@test zscore!(zeros(7), [-3:3;], 1.5, 0.5) == [-9.0:2.0:3.0;]
@test zscore!(zeros(size(a)), a, [1, 2, 3], [0.5, 1.0, 2.0])    ≈ z1
@test zscore!(zeros(size(a)), a, [1 3 2 4], [0.25 0.5 1.0 2.0]) ≈ z2

@test zscore(a)    ≈ zscore(a, mean(a), std(a))
@test zscore(a, 1) ≈ zscore(a, mean(a,1), std(a,1))
@test zscore(a, 2) ≈ zscore(a, mean(a,2), std(a,2))


###### quantile & friends

@test quantile(1:5)     ≈ [1:5;]
@test nquantile(1:5, 2) ≈ [1, 3, 5]
@test nquantile(1:5, 4) ≈ [1:5;]

@test percentile([1:5;], 25)           ≈  2.0
@test percentile([1:5;], [25, 50, 75]) ≈ [2.0, 3.0, 4.0]


##### Dispersion

@test span([3, 4, 5, 6, 2]) == (2:6)

@test variation([1:5;]) ≈ 0.527046276694730

@test sem([1:5;]) ≈ 0.707106781186548

@test StatsBase.mad(1:5; center=3, normalize=true) ≈ 1.4826022185056018
@test StatsBase.mad!([1:5;]; center=3, normalize=true) ≈ 1.4826022185056018
@test mad(1:5, normalize=true) ≈ 1.4826022185056018
@test StatsBase.mad(1:5, normalize=false) ≈ 1.0
@test StatsBase.mad!([1:5;], normalize=false) ≈ 1.0
@test StatsBase.mad(1:5, center=3, normalize=false) ≈ 1.0
@test StatsBase.mad!([1:5;], center=3, normalize=false) ≈ 1.0
@test_throws ArgumentError mad(Int[])

# Issue 197
@test mad(1:2, normalize=true) ≈ 0.7413011092528009

@test iqr(1:5) ≈ 2.0


##### entropy

@test entropy([0.5, 0.5])      ≈ 0.6931471805599453
@test entropy([0.2, 0.3, 0.5]) ≈ 1.0296530140645737

@test entropy([0.5, 0.5],2)       ≈ 1.0
@test entropy([0.2, 0.3, 0.5], 2) ≈ 1.4854752972273344

##### Renyi entropies
# Generate a random probability distribution
nindiv = 50
dist = rand(nindiv)
dist /= sum(dist)

# Check Shannon entropy against Renyi entropy of order 1
@test entropy(dist)         ≈ renyientropy(dist, 1)
@test renyientropy(dist, 1) ≈ renyientropy(dist, 1.0)

# Check Renyi entropy of order 0 is the natural log of the count of non-zeros
@test renyientropy(dist, 0) ≈ log(mapreduce(x -> x > 0 ? 1 : 0, +, dist))

# And is therefore not affected by the addition of non-zeros
zdist = dist
zdist = append!(dist, zeros(rand(50)))
@test renyientropy(dist, 0) ≈ renyientropy(zdist, 0)

# Indeed no Renyi entropy should be
loworder = rand() # Between 0 and 1
@test renyientropy(dist, loworder) ≈ renyientropy(zdist, loworder)
order = rand() * 49 + 1 # And over 1
@test renyientropy(dist, order) ≈ renyientropy(zdist, order)

# Renyi entropy of order infinity is -log(maximum(dist))
@test renyientropy(dist, Inf) ≈ -log(maximum(dist))

# And all Renyi entropies of uniform probabilities should be log n, where n is the length
udist = ones(nindiv) / nindiv
@test renyientropy(udist, order) ≈ log(nindiv)

# And test generalised probability distributions (sum(p) != 1)
scale = rand()
@test renyientropy(udist * scale, 0)     ≈ renyientropy(udist, 0) - log(scale)
@test renyientropy(udist * scale, 1)     ≈ renyientropy(udist, 1) - log(scale)
@test renyientropy(udist * scale, Inf)   ≈ renyientropy(udist, Inf) - log(scale)
@test renyientropy(udist * scale, order) ≈ renyientropy(udist, order) - log(scale)

##### Cross entropy
@test crossentropy([0.2, 0.3, 0.5], [0.3, 0.4, 0.3])    ≈ 1.1176681825904018
@test crossentropy([0.2, 0.3, 0.5], [0.3, 0.4, 0.3], 2) ≈ 1.6124543443825532

##### KL divergence
@test kldivergence([0.2, 0.3, 0.5], [0.3, 0.4, 0.3])    ≈ 0.08801516852582819
@test kldivergence([0.2, 0.3, 0.5], [0.3, 0.4, 0.3], 2) ≈ 0.12697904715521868

##### summarystats

s = summarystats(1:5)
@test isa(s, StatsBase.SummaryStats)
@test s.min == 1.0
@test s.max == 5.0
@test s.mean   ≈ 3.0
@test s.median ≈ 3.0
@test s.q25    ≈ 2.0
@test s.q75    ≈ 4.0
