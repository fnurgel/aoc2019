inherit "intcode_program";

array(array(int)) grid = allocate(100);

int robot_y = 0;
int robot_x = 0;

array(string) scaffold = ({});

string coord_id(int x, int y) {
    return sprintf("%d,%d", x, y);
}

void display_output(Thread.Queue out) {
    for (int i=0; i<sizeof(grid); i++) {
        grid[i] = allocate(100);
    }
    int x=0, y=0;
    while (true) {
        int char = out.read();
        if (char > 255) {
            write(sprintf("End? %d", char));
        }
        if (char == '\n') {
            y++;
            x = 0;
            write("\n");
            continue;
        } else if (char == '^') {
            robot_y = y;
            robot_x = x;
        } else if (char == '#') {
            scaffold += ({ coord_id(x, y) });
        }
        grid[y][x++] = char;
        write(int2char(char));
    }
}

// north, west, south, east
array(int) dy = ({-1, 0, 1, 0});
array(int) dx = ({ 0,-1, 0, 1});

array(array(string)) movements = ({});
array(string) visited = ({});

string find_path(int start_y, int start_x, int direction_idx) {
    string result = "";
    for (int i=0; i<sizeof(dy); i++) {
        if ((direction_idx + 2) % 4 == i) {
            continue;
        }
        int y = start_y;
        int x = start_x;
        if (grid[y+dy[i]][x+dx[i]] == '#') {
            do {
                y += dy[i];
                x += dx[i];
            } while (grid[y+dy[i]][x+dx[i]] == '#');

            if ((i - 1) % 4 == direction_idx) {
                result += "L,";
            } else {
                result += "R,";
            }
            int length_y = abs(y - start_y);
            int length_x = abs(x - start_x);
            int length = max(length_y, length_x);
            result += sprintf("%d,", length);
            write(sprintf("%d,%d - %d\n", x, y, length));
            result += find_path(y, x, i);
            return result;
        }
    }
    return result;
}

int char2int(string v) {
    sscanf(v, "%c", int char);
    return char;
}

void input_movement(string filename, Thread.Fifo in, Thread.Queue out) {
    Stdio.File file = Stdio.FILE();
    file->open(filename, "r");
    foreach(file->line_iterator(true); int idx; string line) {
        array(int) ascii_codes = map(line / ",", lambda(string v) { return char2int(v); });
        out.read();
        foreach(ascii_codes, int chr) {
            in.write(chr);
        }
        in.write('\n');
    }
}

void read_keyboard(Thread.Fifo in) {
    while(true) {
        string s = Stdio.stdin.gets() - "\r" ;
        array(string) chars = s / "";
        foreach (chars, string c) {
            int kb = char2int(c);
            write(c);
            in.write(kb);
        }
        in.write('\n');
    }
}

int main() {
    Stdio.File file = Stdio.FILE();
    file->open("input", "r");

    foreach(file->line_iterator(true); int idx; string line) {
        array(int) int_codes = map(line / ",", lambda(string v) { return (int)v; });

        int_codes[0] = 2;

        memory mem = memory(int_codes, 100000);

        object(Thread.Fifo) ended_fifo = Thread.Queue();
        object(Thread.Queue) out = Thread.Queue();
        object(Thread.Fifo) in = Thread.Fifo();

        thread_create(display_output, out);

        thread_create(execute, mem->copy(), in, out, ended_fifo);

        thread_create(read_keyboard, in);

        ended_fifo.read();
        while(out.size() > 0) {
            int chr = out.read();
            if (chr > 255) {
                write(sprintf("%O\n", chr));
            } else {
                write(int2char(chr));

            }
        }
    }
}
