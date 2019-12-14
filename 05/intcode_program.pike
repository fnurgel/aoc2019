int resolve_position_mode(array(int) int_codes, int position) {
    return int_codes[int_codes[position]];
}

int resolve_immediate_mode(array(int) int_codes, int position) {
    return int_codes[position];
}

int resolve_param(array(int) int_codes, int position, int mode) {
    if (mode == 0) {
        return resolve_position_mode(int_codes, position);
    } else {
        return resolve_immediate_mode(int_codes, position);
    }
}

int find_param_mode(string param_modes, int position) {
    if (sizeof(param_modes) > position) {
        return (int)param_modes[position..position];
    } else {
        return 0;
    }
}

int execute(array(int) int_codes, int input) {
    int position = 0;
    int output;

    while (true) {
        string instruction = (string)int_codes[position];
        string opcode = instruction[sizeof(instruction)-2..];
        string param_modes = reverse(instruction)[2..];

        switch((int)opcode) {
            case 1:
                int int1 = resolve_param(int_codes, position + 1, find_param_mode(param_modes, 0));
                int int2 = resolve_param(int_codes, position + 2, find_param_mode(param_modes, 1));
                int_codes[int_codes[position + 3]] = int1 + int2;
                position += 4;
                break;
            case 2:
                int1 = resolve_param(int_codes, position + 1, find_param_mode(param_modes, 0));
                int2 = resolve_param(int_codes, position + 2, find_param_mode(param_modes, 1));
                int_codes[int_codes[position + 3]] = int1 * int2;
                position += 4;
                break;
            case 3:
                int_codes[int_codes[position + 1]] = input;
                position += 2;
                break;
            case 4:
                output = resolve_param(int_codes, position + 1, find_param_mode(param_modes, 0));
                position += 2;
                write(sprintf("%O - %O\n", position, output));
                break;
            case 99:
                return output;
        }
    }
}
