__precompile__()

module Halton

using Distributions
using Primes

export HaltonSeq!, HaltonDraws!

"""
    `HaltonSeq!{T<:AbstractFloat}(H::Vector{T}, B::Int; skip::Int=500)`

Replaces `H` with entries from Halton low discrepancy sequence with base `B`.
Elements in `H` take values in the interval (0, 1).
Keyword argument `skip` is the number initial "burn-in" elements to drop.
"""
function HaltonSeq!(H::AbstractArray{<:AbstractFloat}, B::Integer; skip::Integer=500)
  isprime(B) || error("base number not prime")
  H!(H, B, skip)
end

"""
    `HaltonDraws!{T<:AbstractFloat}(H::Vector{T}, B::Int, [skip::Int=500, distr=Normal()])`

Replaces `H` with draws from a distribution `Distributions.dist()`.
Draws are generated by using Halton sequence with base `B` as the quantiles drawn.
Keyword argument `skip` is the number initial "burn-in" elements to drop.
"""
function HaltonDraws!(H::AbstractArray, B::Integer; skip::Integer=500, distr = Normal())
  HaltonSeq!(H, B, skip=skip)
  H .= Distributions.quantile.(distr, H)
end

####

## Algorithm for generating Halton sequences
function H!(H::AbstractArray{T}, b::IT, skip::Integer) where {T<:AbstractFloat, IT<:Integer}
  # Fill H with Halton Sequence based on b
  S = skip + length(H)
  # set D to get generated seq >= S
  D = ceil(IT, log(S) / log(b))
  # placeholders
  d = zeros(T, D+1)
  r = zeros(T, D+1)

  # based on algorithm found in https://www.researchgate.net/publication/229173824_Fast_portable_and_reliable_algorithm_for_the_calculation_of_Halton_numbers
  for nn in 1:S
    ii = 1
    while d[ii] == b-1
      d[ii] = zero(T)
      ii += 1
    end
    d[ii] += 1
    if ii>=2
      r[ii - 1] = (d[ii] + r[ii]) / b
    end
    if ii >= 3
      for jj in (ii-1) : -1 : 2
        r[jj-1] = r[jj] / b
      end
    end
    if nn>skip
      H[nn-skip] = (d[1] + r[1]) / b
    end
  end
  return H
end

end
