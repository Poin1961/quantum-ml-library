using LinearAlgebra

export QuantumCircuit, Gate, HGate, XGate, YGate, ZGate, RxGate, RyGate, RzGate, CNOTGate, apply_gate!, measure

# Abstract type for quantum gates
abstract type Gate end

# Concrete gate types
struct HGate <: Gate end
struct XGate <: Gate end
struct YGate <: Gate end
struct ZGate <: Gate end
struct RxGate <: Gate
    theta::Float64
end
struct RyGate <: Gate
    theta::Float64
end
struct RzGate <: Gate
    theta::Float64
end
struct CNOTGate <: Gate end

# QuantumCircuit structure
mutable struct QuantumCircuit
    num_qubits::Int
    state::Vector{ComplexF64}

    function QuantumCircuit(num_qubits::Int)
        state = zeros(ComplexF64, 2^num_qubits)
        state[1] = 1.0 + 0.0im # Initialize to |0...0>
        new(num_qubits, state)
    end
end

# Get matrix representation of gates
function get_gate_matrix(gate::HGate)
    return (1/sqrt(2)) * [1 1; 1 -1]
end

function get_gate_matrix(gate::XGate)
    return [0 1; 1 0]
end

function get_gate_matrix(gate::YGate)
    return [0 -1im; 1im 0]
end

function get_gate_matrix(gate::ZGate)
    return [1 0; 0 -1]
end

function get_gate_matrix(gate::RxGate)
    return [cos(gate.theta/2) -1im*sin(gate.theta/2); -1im*sin(gate.theta/2) cos(gate.theta/2)]
end

function get_gate_matrix(gate::RyGate)
    return [cos(gate.theta/2) -sin(gate.theta/2); sin(gate.theta/2) cos(gate.theta/2)]
end

function get_gate_matrix(gate::RzGate)
    return [exp(-1im*gate.theta/2) 0; 0 exp(1im*gate.theta/2)]
end

# Apply a single-qubit gate
function apply_gate!(circuit::QuantumCircuit, gate::Gate, target_qubit::Int)
    if !(1 <= target_qubit <= circuit.num_qubits)
        error("Target qubit out of bounds.")
    end

    gate_matrix = get_gate_matrix(gate)
    num_states = 2^circuit.num_qubits
    new_state = zeros(ComplexF64, num_states)

    for i in 0:num_states-1
        # Check if the target qubit is 0 or 1 in the current basis state i
        target_qubit_value = (i >> (target_qubit - 1)) & 1

        # Calculate the index for the other basis state (where target qubit is flipped)
        flipped_i = i ⊻ (1 << (target_qubit - 1))

        if target_qubit_value == 0
            # Apply first column of gate_matrix
            new_state[i+1] += gate_matrix[1,1] * circuit.state[i+1]
            new_state[flipped_i+1] += gate_matrix[2,1] * circuit.state[i+1]
        else # target_qubit_value == 1
            # Apply second column of gate_matrix
            new_state[i+1] += gate_matrix[2,2] * circuit.state[i+1]
            new_state[flipped_i+1] += gate_matrix[1,2] * circuit.state[i+1]
        end
    end
    circuit.state = new_state
end

# Apply CNOT gate (control_qubit, target_qubit)
function apply_gate!(circuit::QuantumCircuit, gate::CNOTGate, control_qubit::Int, target_qubit::Int)
    if !(1 <= control_qubit <= circuit.num_qubits && 1 <= target_qubit <= circuit.num_qubits && control_qubit != target_qubit)
        error("Invalid control/target qubits for CNOT.")
    end

    num_states = 2^circuit.num_qubits
    new_state = deepcopy(circuit.state)

    for i in 0:num_states-1
        # If control qubit is 1, flip target qubit
        if ((i >> (control_qubit - 1)) & 1) == 1
            flipped_i = i ⊻ (1 << (target_qubit - 1))
            new_state[i+1] = circuit.state[flipped_i+1]
            new_state[flipped_i+1] = circuit.state[i+1]
        end
    end
    circuit.state = new_state
end

# Measure the quantum circuit (returns a classical bit string)
function measure(circuit::QuantumCircuit)
    probabilities = abs2.(circuit.state)
    # Normalize probabilities to ensure sum is 1 (due to potential floating point inaccuracies)
    probabilities ./= sum(probabilities)

    # Choose a state based on probabilities
    chosen_index = findfirst(x -> x > rand(), cumsum(probabilities))
    if chosen_index === nothing
        chosen_index = length(probabilities) # Fallback to last state if rand() is 1.0
    end
    
    # Convert index to binary string (classical outcome)
    return bitstring(chosen_index - 1)[(end - circuit.num_qubits + 1):end]
end
