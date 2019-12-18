inherit "intcode_program";

mapping chars = ([
    35: "#",
    46: ".",
    10: "\n"
]);

array(array(int)) grid = allocate(100);

void display_output(Thread.Queue out) {
    for (int i=0; i<sizeof(grid); i++) {
        grid[i] = allocate(100);
    }
    int x=0, y=0;
    while (true) {
        int char = out.read();
        if (char == 10) {
            y++;
            x = 0;
            write("\n");
            continue;
        }
        grid[y][x++] = char;
        write(sprintf("%c", char));
    }
}

void display_grid() {
    for (int i=0; i<sizeof(grid); i++) {
        for (int j=0; j<sizeof(grid); j++) {
            write(sprintf("%c", grid[i][j]));
        }
        write("\n");
    }
}

array(int) dy = ({-1, 0, 1, 0});
array(int) dx = ({ 0,-1, 0, 1});

int is_crossing(int y, int x) {
    if (y == 0 || x == 0 || y == sizeof(grid) - 1 || x == sizeof(grid[0]) - 1) {
        return false;
    }
    for (int i=0; i<sizeof(dy); i++) {
        if (grid[y+dy[i]][x+dx[i]] != 35) {
            return false;
        }
    }
    return true;
}

int main() {
    Stdio.File file = Stdio.FILE();
    file->open("input", "r");

    foreach(file->line_iterator(true); int idx; string line) {
        array(int) int_codes = map(line / ",", lambda(string v) { return (int)v; });

        memory mem = memory(int_codes, 100000);

        object(Thread.Fifo) ended_fifo = Thread.Queue();
        object(Thread.Queue) out = Thread.Queue();
        object(Thread.Fifo) in = Thread.Fifo();

        thread_create(display_output, out);

        thread_create(execute, mem->copy(), in, out, ended_fifo);

        ended_fifo.read();
        do {
            sleep(1);
        } while (out.size() > 0);

        int alignment = 0;
        for (int y=0; y<sizeof(grid); y++) {
            for (int x=0; x<sizeof(grid[y]); x++) {
                if (grid[y][x] == 35) {
                    int is = is_crossing(y, x);
                    if (is) {
                        alignment += y * x;
                        grid[y][x] = 79;
                    }
                }
            }
        }
        display_grid();
        write("Alignment: " + alignment + "\n");
    }
}
