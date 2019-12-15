inherit "intcode_program";

int is_all_uniq(string value, multiset containing_only) {
    array numbers = value / "";
    multiset uniq_check = (<>);
    foreach(numbers, string str) {
        if (containing_only[(int)str] == 0) {
            return 0;
        }
        if (uniq_check[str] != 0) {
            return 0;
        }
        uniq_check[str] = 1;
    }
    return 1;
}

multiset find_all_unique_combinations(int from, int to, multiset containing_only) {
    multiset sequences = (<>);
    for (int current = from; current <= to; current++) {
        if (sequences[current] == 0 && is_all_uniq(sprintf("%05d",current), containing_only)) {
            sequences += (< current >);
        }
    }
    return sequences;
}

int calculate_output(array(int) phases, memory mem) {
    array fifos = ({});
    object(Thread.Fifo) first_fifo = Thread.Fifo();
    object(Thread.Fifo) last_fifo = Thread.Fifo();
    object(Thread.Fifo) input_fifo = first_fifo;
    int amplifier = 0;

    do {
        int phase_setting = phases[amplifier];
        object(Thread.Fifo) output_fifo = Thread.Fifo();
        input_fifo.write(phase_setting);
        thread_create(execute, mem->copy(), input_fifo, output_fifo);
        input_fifo = output_fifo;
        amplifier++;
    } while (amplifier < sizeof(phases) - 1);

    first_fifo.write(0);
    input_fifo.write(phases[amplifier]);
    execute(mem->copy(), input_fifo, last_fifo);
    return last_fifo.read();
}

int main() {
    Stdio.File file = Stdio.FILE();
    file->open("input", "r");

    foreach(file->line_iterator(true); int idx; string line) {
        array(int) int_codes = map(line / ",", lambda(string v) { return (int)v; });
        memory mem = memory(int_codes, 0);
        int highest_output = 0;
        foreach(indices(find_all_unique_combinations(1234, 43210, (<0,1,2,3,4>))), int phases) {
            array phase_str = (sprintf("%05d", phases) / "");
            phase_str = map(phase_str, lambda(string v) { return (int)v; });
            int output = calculate_output(phase_str, mem);
            if (output > highest_output) {
                highest_output = output;
            }
        }

        write(sprintf("%O\n", highest_output));
    }

    return 0;
}
