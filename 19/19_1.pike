inherit "intcode_program";

int size = 50;

array(array(string)) grid = allocate(size);

int is_beam(memory mem, int x, int y) {
    object(Thread.Fifo) input_fifo = Thread.Fifo();
    object(Thread.Fifo) output_fifo = Thread.Fifo();

    input_fifo.write(x);
    input_fifo.write(y);

    execute(mem->copy(), input_fifo, output_fifo);

    return output_fifo.read();
}

void display_grid() {
    for (int y = 0; y < size; y++) {
        write(sprintf("%s\n", grid[y] * ""));
    }
}

void find_row(memory mem, int y, int prev_x1, int prev_x2) {
    int curr_x1 = prev_x1;
    int curr_x2 = prev_x2;
    write(sprintf("%d ", y));
    for (int x = 0; x < size; x++) {
        if (is_beam(mem, x, y)) {
            grid[y][x] = "#";
            affected++;
        }
    }

    if (y < size) {
        find_row(mem, ++y, curr_x1, curr_x2);
    }
}

int affected = 0;

int main() {
    for (int i = 0; i < size; i++) {
        grid[i] = allocate(size, ".");
    }

    Stdio.File file = Stdio.FILE();
    file->open("input", "r");

    foreach(file->line_iterator(true); int idx; string line) {
        array(int) int_codes = map(line / ",", lambda(string v) { return (int)v; });
        memory mem = memory(int_codes, 10000);
        int x = 0, y = 0;
        if (is_beam(mem, x, y)) {
            grid[y][x] = "#";
            affected++;
        }
        find_row(mem, 1, 0, 0);
        write("\n");
        display_grid();
        write(affected+"\n");
    }

    return 0;
}
