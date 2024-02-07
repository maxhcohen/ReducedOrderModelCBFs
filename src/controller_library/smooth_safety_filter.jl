struct SmoothSafetyFilter <: SafetyFilter
    get_input::Function
end

(k::SmoothSafetyFilter)(x) = k.get_input(x)

function SmoothSafetyFilter(
    Σ::ControlAffineSystem, h::Function, α::Function, kd::Function;
    formula="half-sontag", σ=0.1, ε=0.0
)
    # Pull out dynamics and CBF
    n = Σ.n
    f = Σ.f
    g = Σ.g

    # Get Lie derivatives
    ∇h(x) = n == 1 ? ForwardDiff.derivative(h, x) : ForwardDiff.gradient(h, x)
    Lfh(x) = ∇h(x)'f(x)
    Lgh(x) = ∇h(x)'g(x)
    a(x) = ε == 0.0 ? Lfh(x) + Lgh(x)*kd(x) + α(h(x)) : Lfh(x) + Lgh(x)*kd(x) + α(h(x)) - (1/ε)*norm(Lgh(x))^2
    b(x) = norm(Lgh(x))^2

    # Select smooth universal formula
    if formula == "sontag"
        λ = λSontag
    elseif formula == "half-sontag"
        λ = λHalfSontag
    elseif formula == "softplus"
        λ = λSoftplus
    elseif formula == "gaussian"
        λ = λGaussian
    else
        λ = λHalfSontag # Default to half-sontag
    end

    # Smooth safety filter
    k(x) = kd(x) + λ(a(x), b(x), σ)*Lgh(x)'

    return SmoothSafetyFilter(k)
end

function SmoothSafetyFilter(
    Σ::ControlAffineSystem, cbf::ControlBarrierFunction, kd::Function;
    formula="half-sontag", σ=0.1
)
    # Pull out dynamics and CBF
    n = Σ.n
    f = Σ.f
    g = Σ.g
    h = cbf.h
    α = cbf.α

    # Get Lie derivatives
    ∇h(x) = n == 1 ? ForwardDiff.derivative(h, x) : ForwardDiff.gradient(h, x)
    Lfh(x) = ∇h(x)'f(x)
    Lgh(x) = ∇h(x)'g(x)
    a(x) = Lfh(x) + Lgh(x)*kd(x) + α(h(x))
    b(x) = norm(Lgh(x))^2

    # Select smooth universal formula
    if formula == "sontag"
        λ = λSontag
    elseif formula == "half-sontag"
        λ = λHalfSontag
    elseif formula == "softplus"
        λ = λSoftplus
    elseif formula == "gaussian"
        λ = λGaussian
    else
        λ = λHalfSontag # Default to half-sontag
    end

    # Smooth safety filter
    k(x) = kd(x) + λ(a(x), b(x), σ)*Lgh(x)'

    return SmoothSafetyFilter(k)
end

# Smooth universal formulas
λSontag(a, b, σ) = b == 0.0 ? 0.0 : (-a + sqrt(a^2 + σ*b^2))/b
λHalfSontag(a, b, σ) = 0.5*λSontag(a, b, σ)
# λSoftplus(a,b, σ) = b == 0.0 ? 0.0 : σ*log(1.0 + exp(-a/(b*σ)))
λSoftplus(a,b, σ) = b ≤ 0.0 ? 0.0 : σ*log(1.0 + exp(-a/(b*σ)))
# λGaussian(a, b, σ) = b == 0.0 ? 0.0 : σ*norm_pdf(a/(b*σ))/norm_cdf(a/(b*σ))
λGaussian(a, b, σ) = b ≤ 0.0 ? 0.0 : σ*norm_pdf(a/(b*σ))/norm_cdf(a/(b*σ))

# function λSoftplus(a,b, σ)
#     if b == 0.0
#         return 0.0
#     elseif b > 0.0
#         return σ*log(1.0 + exp(-a/(b*σ)))
#     elseif b < 0.0
#         return -σ*log(1.0 + exp(a/(b*σ)))
#     end
# end

# function λGaussian(a, b, σ)
#     if b == 0.0
#         return 0.0
#     elseif b < 0.0
#         return -σ*norm_pdf(a/(b*σ))/(1.0 - norm_cdf(a/(b*σ)))
#     elseif b > 0.0 
#         return σ*norm_pdf(a/(b*σ))/(norm_cdf(a/(b*σ)) -1.0)
#     end
# end

# Some helper functions
norm_dist = Normal()
norm_dist_σ(σ) = Normal(0.0, σ)
norm_pdf(x) = pdf(norm_dist, x)
norm_cdf(x) = cdf(norm_dist, x)
function norm_pdf(x, σ)
    dist = Normal(0.0, σ)
    pdf(dist, x)
end
function norm_cdf(x, σ)
    dist = Normal(0.0, σ)
    cdf(dist, x)
end