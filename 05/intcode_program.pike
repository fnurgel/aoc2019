
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

array(int) resolve_params(int nr, array int_codes, int position, string param_modes) {
    array result = ({});
    for (int i = 0; i < nr; i++) {
        result += ({ resolve_param(int_codes, position + 1 + i, find_param_mode(param_modes, i)) });
    }
    return result;
}

int execute(array(int) int_codes, int input) {
    int position = 0;
    int output;

    while (true) {
        string instruction = (string)int_codes[position];
        string opcode = instruction[sizeof(instruction)-2..];
        string param_modes = reverse(instruction)[2..];
        array(int) params;

        switch((int)opcode) {
            case 1:
                params = resolve_params(2, int_codes, position, param_modes);
                int_codes[int_codes[position + 3]] = params[0] + params[1];
                position += 4;
                break;
            case 2:
                params = resolve_params(2, int_codes, position, param_modes);
                int_codes[int_codes[position + 3]] = params[0] * params[1];
                position += 4;
                break;
            case 3:
                int_codes[int_codes[position + 1]] = input;
                position += 2;
                break;
            case 4:
                params = resolve_params(1, int_codes, position, param_modes);
                output = params[0];
                position += 2;
                write(sprintf("%O > %O\n", position, output));
                break;
            case 5:
                params = resolve_params(2, int_codes, position, param_modes);
                if (params[0] != 0) {
                    position = params[1];
                } else {
                    position += 3;
                }
                break;
            case 6:
                params = resolve_params(2, int_codes, position, param_modes);
                if (params[0] == 0) {
                    position = params[1];
                } else {
                    position += 3;
                }
                break;
            case 7:
                params = resolve_params(2, int_codes, position, param_modes);
                int value;
                if (params[0] < params[1]) {
                    value = 1;
                } else {
                    value = 0;
                }
                int_codes[int_codes[position + 3]] = value;
                position += 4;
                break;
            case 8:
                params = resolve_params(2, int_codes, position, param_modes);
                value;
                if (params[0] == params[1]) {
                    value = 1;
                } else {
                    value = 0;
                }
                int_codes[int_codes[position + 3]] = value;
                position += 4;
                break;
            case 99:
                return output;
        }
    }
}
