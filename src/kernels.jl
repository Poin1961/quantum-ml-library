using Yao

export quantum_kernel

"""
    quantum_kernel(x1::Vector, x2::Vector)

Computes the quantum kernel between two data points x1 and x2.
"""
function quantum_kernel(x1::Vector{Float64}, x2::Vector{Float64})
    # Encode data into quantum states
    # For simplicity, using a basic encoding here
    q1 = product_state(length(x1), x1)
    q2 = product_state(length(x2), x2)

    # Compute overlap (fidelity) as the kernel value
    return abs2(expect(put(1=>Z), q1 |> apply(q2'))) # Simplified overlap
end

# Helper to create a product state from a classical vector
function product_state(n_qubits::Int, data::Vector{Float64})
    if length(data) != n_qubits
        error("Data vector length must match number of qubits")
    end
    reg = zero_state(n_qubits)
    for i in 1:n_qubits
        # Simple encoding: map data point to rotation angle
        apply!(reg, Rz(i, data[i]))
    end
    return reg
end
