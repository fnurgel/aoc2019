inherit "intcode_program";

int is_beam(memory mem, int x, int y) {
    object(Thread.Fifo) input_fifo = Thread.Fifo();
    object(Thread.Fifo) output_fifo = Thread.Fifo();

    input_fifo.write(x);
    input_fifo.write(y);

    execute(mem->copy(), input_fifo, output_fifo);

    return output_fifo.read();
}

void find_axis_at_point(memory mem, int px, int py, int last_aff_x, int last_aff_y) {
    int new_start_x = max(0, last_aff_x - 2);
    int new_start_y = max(0, last_aff_y - 2);
    int affected_x = new_start_x;
    int affected_y = new_start_y;

    for (int x = px + new_start_x; x < px + 103; x++) {
        if (is_beam(mem, x, py)) {
            affected_x++;
        } else if (affected_x > 0) {
            break;
        }
    }
    for (int y = py + new_start_y; y < py + 103; y++) {
        if (is_beam(mem, px, y)) {
            affected_y++;
        } else if (affected_y > 0) {
            break;
        }
    }
    write(sprintf("aff_x: %d, aff_y: %d (%d,%d)\n", affected_x, affected_y, px, py));

    if (affected_x == 100 && affected_y == 100) {
        write(sprintf("100x100 at %d,%d result %d\n", px, py, px * 10000 + py));
        return;
    }
    if (affected_x < affected_y) {
        px--;
    } else if (affected_y < affected_x) {
        py--;
    }
    px++;
    py++;
    find_axis_at_point(mem, px, py, affected_x, affected_y);
}

int main() {

    Stdio.File file = Stdio.FILE();
    file->open("input", "r");

    foreach(file->line_iterator(true); int idx; string line) {
        array(int) int_codes = map(line / ",", lambda(string v) { return (int)v; });
        memory mem = memory(int_codes, 10000);

        find_axis_at_point(mem, 0, 0, 0, 0);
    }

    return 0;
}
