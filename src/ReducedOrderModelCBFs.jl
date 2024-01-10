module ReducedOrderModelCBFs

# Required modules
using LinearAlgebra
using ForwardDiff
using DifferentialEquations
using Distributions
using Colors
using PGFPlotsX
using JuMP
using OSQP

# Export types
export ControlAffineSystem
export RoboticSystem
export ControlBarrierFunction

# Export functions
export simulate
export dynamics
export smooth_conjunction

# Export systems
export CustomControlAffineSystem
export SingleIntegrator
export DoubleIntegrator
export Unicycle
export InvertedPendulum
export PlanarSegway
export DoublePendulum
export CartPole
export Pendubot

# Export controllers
export FeedbackController
export ReluSafetyFilter
export SmoothSafetyFilter
export CBFQP
export TunableCBFQP
export CLFMinNorm

# Export barrier templates
export CircularObstacle
export SquareObstacle

# Export smooth universal formulas
export λRelu
export λSontag
export λHalfSontag
export λSoftplus
export λGaussian

# Export plotting util functions
export meshgrid
export mesh_vector_field
export vector_field_colors
export get_colors
export get_color_palette
export get_ax_theme
export get_plt_theme
export plot_defaults


# Include source code
include("systems.jl")
include("barriers.jl")
include("controllers.jl")
include("simulate.jl")
include("smooth_combinations.jl")

# Include various systems of interest
include("system_library/single_integrator.jl")
include("system_library/double_integrator.jl")
include("system_library/unicycle.jl")
include("system_library/inverted_pendulum.jl")
include("system_library/planar_segway.jl")
include("system_library/double_pendulum.jl")
include("system_library/cartpole.jl")
include("system_library/pendubot.jl")

# Include barrier templates
include("cbf_library/circular_obstacle.jl")
include("cbf_library/square_obstacle.jl")

# Inlcude various controllers
include("controller_library/relu_safety_filter.jl")
include("controller_library/smooth_safety_filter.jl")
include("controller_library/cbf_qp.jl")
include("controller_library/tunable_cbf_qp.jl")
include("controller_library/clf_min_norm.jl")

# Include plot utils
include("plot_utils.jl")

end # module ReducedOrderModelCBFs
