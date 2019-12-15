inherit "intcode_program";

class robot {
    int x;
    int y;
    int direction = 0; // 0 ^  1 < 2 \/ 3 >

    void create(int _x, int _y) {
        x = _x;
        y = _y;
    }

    string coord_id() {
        return sprintf("%O,%O", x, y);
    }

    void move() {
        switch(direction) {
            case 0:
                y--;
                break;
            case 1:
                x--;
                break;
            case 2:
                y++;
                break;
            case 3:
                x++;
                break;
        }
        write(to_string() + "\n");
    }

    void turn_and_move(int instruction) {
        if (instruction == 0) {
            direction = (direction + 1) % 4;
        } else {
            direction = (direction - 1) % 4;
        }
        move();
    }

    string to_string() {
        mapping dir_str = ([
            0: "^",
            1: "<",
            2: "v",
            3: ">"
        ]);
        return sprintf("(%O,%O) %s", x, y, dir_str[direction]);
    }
}

int main() {
    Stdio.File file = Stdio.FILE();
    file->open("input", "r");

    foreach(file->line_iterator(true); int idx; string line) {
        array(int) int_codes = map(line / ",", lambda(string v) { return (int)v; });
        memory mem = memory(int_codes, 10000);

        mapping grid = ([]);

        robot r = robot(0,0);
        write(sprintf("%O\n", r.to_string()));
        object(Thread.Fifo) input_fifo = Thread.Fifo();
        object(Thread.Fifo) output_fifo = Thread.Fifo();

        input_fifo.write(0);

        thread_create(execute, mem->copy(), input_fifo, output_fifo);

        int paints = 0;
        while(true) {
            int paint_color = output_fifo.read();
            int existing_color = grid[r->coord_id()] - 1;
            if (paint_color != existing_color) {
                paints++;
                write("Paints: " + sizeof(indices(grid)) + "\n");
            }
            grid[r->coord_id()] = paint_color + 1;
            int direction_command = output_fifo.read();
            r->turn_and_move(direction_command);
            int new_color = grid[r->coord_id()];
            if (new_color > 0) {
                new_color -= 1;
            }
            input_fifo.write(new_color);
        }
    }

    return 0;
}
