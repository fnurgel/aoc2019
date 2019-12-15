class instruction {
    int opcode;
    int param_modes_ptr = 0;
    array(int) param_modes;
    Thread.Fifo input;
    Thread.Fifo output;

    void create(int instr, Thread.Fifo in, Thread.Fifo out) {
        string instr_str = (string)instr;
        opcode = (int)instr_str[sizeof(instr_str)-2..];
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

    void create(array(int) data, int extend_to_size) {
        instruction_ptr = 0;
        if (extend_to_size > sizeof(data)) {
            _memory = data + allocate(extend_to_size - sizeof(data)) - ({});
        } else {
            _memory = data - ({});
        }
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
        if (mode == 0) {
            data = _memory[_memory[instruction_ptr]];
        } else {
            data = _memory[instruction_ptr];
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

void instr_equals(memory mem, instruction instr) {
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

void execute(memory mem, Thread.Fifo input, Thread.Fifo output) {

    while (true) {
        instruction instr = instruction(mem->read(1), input, output);

        function op;

        switch(instr->opcode) {
            case 1:
                op = instr_add;
                break;
            case 2:
                op = instr_mult;
                break;
            case 3:
                op = instr_input;
                break;
            case 4:
                op = instr_output;
                break;
            case 5:
                op = instr_jmpnz;
                break;
            case 6:
                op = instr_jmpz;
                break;
            case 7:
                op = instr_lt;
                break;
            case 8:
                op = instr_equals;
                break;
            case 99:
                return;
        }
        op(mem, instr);
    }
}
