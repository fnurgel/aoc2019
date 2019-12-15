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

class dimension {
    int xsize;
    int ysize;
    int start_x;
    int start_y;

    void create(int _xsize, int _ysize, int _start_x, int _start_y) {
        xsize = _xsize;
        ysize = _ysize;
        start_x = _start_x;
        start_y = _start_y;
    }
}

class grid_dimensions {
    int min_x = 10000;
    int min_y = 10000;
    int max_x = -10000;
    int max_y = -10000;

    dimension get_dimension() {
        return dimension(max_x - min_x, max_y - min_y, abs(min_x), abs(min_y));
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

        input_fifo.write(1);

        thread_create(execute, mem->copy(), input_fifo, output_fifo);

        int paints = 0;
        while(true) {
            int paint_color = output_fifo.read();
            int existing_color = grid[r->coord_id()] - 1;
            if (paint_color != existing_color) {
                paints++;
                write(sprintf("Paints (%O): %O\n", paints, sizeof(indices(grid))));
            }
            grid[r->coord_id()] = paint_color + 1;
            if (paints > 248) break;
            int direction_command = output_fifo.read();
            r->turn_and_move(direction_command);
            int new_color = grid[r->coord_id()];
            if (new_color > 0) {
                new_color -= 1;
            }
            input_fifo.write(new_color);
        }

        for (int y=0; y<50; y++) {
            array row = ({});
            for (int x=0; x<50; x++) {
                switch (grid[sprintf("%O,%O", x, y)]) {
                    case 0:
                    case 1:
                        row += ({ "." });
                        break;
                    case 2:
                        row += ({ "#" });
                        break;
                }
            }
            write(row * "" + "\n");
        }
    }

    return 0;
}
