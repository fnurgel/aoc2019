class instruction {
    int opcode;
    int param_modes_ptr = 0;
    array(int) param_modes;
    Thread.Fifo input;
    Thread.Fifo output;

    void create(int instr, Thread.Fifo in, Thread.Fifo out) {
        string instr_str = (string)instr;
        opcode = (int)instr_str[<1..];
        string param_modes_str = reverse(instr_str)[2..];
        param_modes = map(param_modes_str / "", lambda(string v) { return (int)v; });
        input = in;
        output = out;
    }

    int read_next_param(memory mem) {
        int param_mode = 0;
        if (param_modes_ptr < sizeof(param_modes)) {
            param_mode = param_modes[param_modes_ptr++];
        }
        return mem->read(param_mode);
    }

    array(int) params(memory mem, int number_of_params) {
        array(int) data = ({});
        for (int i=0; i<number_of_params; i++) {
            data += ({ read_next_param(mem) });
        }
        return data;
    }
}

class memory {
    array(int) _memory;
    int instruction_ptr;
    int relative_base = 0;

    void create(array(int) data, int extend_to_size) {
        instruction_ptr = 0;
        if (extend_to_size > sizeof(data)) {
            _memory = data + allocate(extend_to_size - sizeof(data)) - ({});
        } else {
            _memory = data - ({});
        }
    }

    void add_base(int rel_base_to_add) {
        relative_base += rel_base_to_add;
    }

    void write(int data) {
        _memory[_memory[instruction_ptr]] = data;
        instruction_ptr++;
    }

    void jmp(int ptr) {
        instruction_ptr = ptr;
    }

    int read(int mode) {
        int data;
        if (mode == 0) {  // position mode
            data = _memory[_memory[instruction_ptr]];
        } else if (mode == 1) {  // immediate_mode
            data = _memory[instruction_ptr];
        } else if (mode == 2) {  // relative_mode
            data = _memory[_memory[instruction_ptr + relative_base]];
        }
        instruction_ptr++;
        return data;
    }

    memory copy() {
        return memory(_memory, 0);
    }
}

void instr_add(memory mem, instruction instr) {
    mem->write(instr->read_next_param(mem) + instr->read_next_param(mem));
}

void instr_mult(memory mem, instruction instr) {
    mem->write(instr->read_next_param(mem) * instr->read_next_param(mem));
}

void instr_input(memory mem, instruction instr) {
    mem->write(instr->input.read());
}

void instr_output(memory mem, instruction instr) {
    instr->output.write(instr->read_next_param(mem));
}

void instr_jmpz(memory mem, instruction instr) {
    array(int) params = instr->params(mem, 2);
    if (params[0] == 0) {
        mem->jmp(params[1]);
    }
}

void instr_jmpnz(memory mem, instruction instr) {
    array(int) params = instr->params(mem, 2);
    if (params[0] != 0) {
        mem->jmp(params[1]);
    }
}

void instr_eq(memory mem, instruction instr) {
    array(int) params = instr->params(mem, 2);
    int value = 0;
    if (params[0] == params[1]) {
        value = 1;
    }
    mem->write(value);
}

void instr_lt(memory mem, instruction instr) {
    array(int) params = instr->params(mem, 2);
    int value = 0;
    if (params[0] < params[1]) {
        value = 1;
    }
    mem->write(value);
}

void instr_rel_base(memory mem, instruction instr) {
    array(int) params = instr->params(mem, 1);
    mem->add_base(params[0]);
}

void execute(memory mem, Thread.Fifo input, Thread.Fifo output) {
    mapping ops = ([
        1: instr_add,
        2: instr_mult,
        3: instr_input,
        4: instr_output,
        5: instr_jmpnz,
        6: instr_jmpz,
        7: instr_lt,
        8: instr_eq
    ]);
    while (true) {
        instruction instr = instruction(mem->read(1), input, output);

        if (instr->opcode == 99) {
            return;
        }

        ops[instr->opcode](mem, instr);
    }
}
