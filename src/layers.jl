using Yao

export QNNLayer

struct QNNLayer <: CompositeBlock{2}
    circuit::ChainBlock{2}
    param_symbol::Symbol
end

function QNNLayer(circuit::ChainBlock{2}, param_symbol::Symbol)
    QNNLayer(circuit, param_symbol)
end

function Yao.apply!(reg::AbstractRegister, l::QNNLayer)
    # Extract parameter from the register (or external source)
    # For simplicity, we'll assume a single parameter for now
    param_val = 0.0 # Placeholder: In a real QNN, this would come from classical optimization
    # Set the parameter in the circuit
    for block in l.circuit.blocks
        if haskey(block, l.param_symbol)
            block[l.param_symbol] = param_val
        end
    end
    apply!(reg, l.circuit)
end
