class instruction {
    int size;

    void parse_instruction(array(int) data) {

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

int find_param_mode(string param_modes, int position) {
    if (sizeof(param_modes) > position) {
        return (int)param_modes[position..position];
    } else {
        return 0;
    }
}

void execute(memory mem, Thread.Fifo input, Thread.Fifo output) {

    while (true) {
        string instruction = (string)mem->read(1);
        string opcode = instruction[sizeof(instruction)-2..];
        string param_modes = reverse(instruction)[2..];

        switch((int)opcode) {
            case 1:
                int param1 = mem->read(find_param_mode(param_modes, 0));
                int param2 = mem->read(find_param_mode(param_modes, 1));
                mem->write(param1 + param2);
                break;
            case 2:
                param1 = mem->read(find_param_mode(param_modes, 0));
                param2 = mem->read(find_param_mode(param_modes, 1));
                mem->write(param1 * param2);
                break;
            case 3:
                mem->write(input.read());
                break;
            case 4:
                param1 = mem->read(find_param_mode(param_modes, 0));
                output.write(param1);
                break;
            case 5:
                param1 = mem->read(find_param_mode(param_modes, 0));
                param2 = mem->read(find_param_mode(param_modes, 1));
                if (param1 != 0) {
                    mem->jmp(param2);
                }
                break;
            case 6:
                param1 = mem->read(find_param_mode(param_modes, 0));
                param2 = mem->read(find_param_mode(param_modes, 1));
                if (param1 == 0) {
                    mem->jump(param2);
                }
                break;
            case 7:
                param1 = mem->read(find_param_mode(param_modes, 0));
                param2 = mem->read(find_param_mode(param_modes, 1));
                int value;
                if (param1 < param2) {
                    value = 1;
                } else {
                    value = 0;
                }
                mem->write(value);
                break;
            case 8:
                param1 = mem->read(find_param_mode(param_modes, 0));
                param2 = mem->read(find_param_mode(param_modes, 1));
                value;
                if (param1 == param2) {
                    value = 1;
                } else {
                    value = 0;
                }
                mem->write(value);
                break;
            case 99:
                return;
        }
    }
}
