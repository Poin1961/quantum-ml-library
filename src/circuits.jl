using Yao

"""
    build_ansatz(n_qubits::Int, depth::Int)

Builds a parameterized quantum circuit ansatz for QML applications.
"""
function build_ansatz(n_qubits::Int, depth::Int)
    circuit = chain(n_qubits)
    for _ in 1:depth
        # Apply a layer of Hadamard gates to all qubits
        circuit = chain(circuit, repeat(H, 1:n_qubits))
        # Apply a layer of CNOT gates (entangling layer)
        for i in 1:n_qubits-1
            circuit = chain(circuit, cnot(i, i+1))
        end
        # Apply a layer of parameterized Rz gates
        circuit = chain(circuit, variational_layer(n_qubits))
    end
    return circuit
end

function variational_layer(n_qubits::Int)
    layer = chain(n_qubits)
    for i in 1:n_qubits
        layer = chain(layer, Rz(i, :θ => 0.0))
    end
    return layer
end
