module QuantumML

using LinearAlgebra
using Random

include("circuits.jl")
include("layers.jl")
include("kernels.jl")

export QuantumCircuit, apply_gate!, measure, 
       QuantumLayer, variational_layer, 
       QuantumKernel, fidelity_kernel

# Main entry point or utility functions
function run_quantum_ml_experiment(circuit::QuantumCircuit, data::Vector{Vector{Float64}})
    println("Running Quantum ML Experiment...")
    # Simulate running the circuit for each data point
    results = []
    for x in data
        # Apply data encoding (example: simple rotation)
        temp_circuit = deepcopy(circuit)
        apply_gate!(temp_circuit, RyGate(x[1] * π), 1)
        apply_gate!(temp_circuit, RzGate(x[2] * π), 2)
        
        # Apply variational layer
        # Assuming variational_layer modifies the circuit in place or returns a new one
        # For simplicity, let's assume it's already part of the circuit definition or applied externally

        push!(results, measure(temp_circuit))
    end
    return results
end

end # module
