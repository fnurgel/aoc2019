inherit "intcode_program";

void display_output(Thread.Queue out) {
    int x=0, y=0;
    while (true) {
        int char = out.read();
        if (char == '\n') {
            y++;
            x = 0;
            write("\n");
            continue;
        }
        if (char > 255) {
            write(char+"\n");
        } else {
            write(int2char(char));
        }
    }
}

object(Thread.Fifo) ended_fifo = Thread.Queue();
object(Thread.Queue) out = Thread.Queue();
object(Thread.Fifo) in = Thread.Fifo();

void input_string(string input) {
    foreach (map(input / "", lambda(string v) { return char2int(v); }), int ascii) {
        in.write(ascii);
    }
}

int char2int(string v) {
    sscanf(v, "%c", int char);
    return char;
}

void input_springcodefile(string filename) {
    Stdio.File file = Stdio.FILE();
    file->open(filename, "r");

    foreach(file->line_iterator(true); int idx; string line) {
        string command = line + "\n";
        input_string(command);
    }
}

int main(int c, array(string) argv) {
    if (c != 2) {
        write("Supply filename\n");
        return 1;
    }
    string springcode_filename = argv[1];

    Stdio.File file = Stdio.FILE();
    file->open("input", "r");

    foreach(file->line_iterator(true); int idx; string line) {
        array(int) int_codes = map(line / ",", lambda(string v) { return (int)v; });

        memory mem = memory(int_codes, 100000);

        thread_create(display_output, out);

        input_springcodefile(springcode_filename);

        execute(mem->copy(), in, out, ended_fifo);

        while (out.size() > 0) {
            sleep(1);
        }
    }
    return 0;
}
