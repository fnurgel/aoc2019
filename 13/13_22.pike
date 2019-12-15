inherit "intcode_program";

array(array(int)) tiles = allocate(100);
int score = 0;

void display_output(Thread.Queue out, Thread.Fifo in) {
    int ball_x;
    int paddle_x;

    while (true) {
        int x = out.read();
        int y = out.read();
        if (x == -1 && y == 0) {
            score = out.read();
            continue;
        }
        int tile_id = out.read();

        if (tile_id == 3) {
            paddle_x = x;
        } else if (tile_id == 4) {
            ball_x = x;

            if (paddle_x < ball_x) {
                in.write(1);
            } else if (paddle_x > ball_x) {
                in.write(-1);
            } else {
                in.write(0);
            }
        }

        if (tiles[y] == 0) {
            tiles[y] = allocate(50);
        }
        tiles[y][x] = tile_id;

    }

}
mapping tile_id_str = ([
    0: " ",
    1: "|",
    2: "#",
    3: "-",
    4: "o"
]);

int main() {
    Stdio.File file = Stdio.FILE();
    file->open("input", "r");

    foreach(file->line_iterator(true); int idx; string line) {

        array(int) int_codes = map(line / ",", lambda(string v) { return (int)v; });
        int_codes[0] = 2;

        memory mem = memory(int_codes, 100000);

        object(Thread.Fifo) input_fifo = Thread.Fifo();
        object(Thread.Queue) output_fifo = Thread.Queue();
        object(Thread.Fifo) ended_fifo = Thread.Fifo();

        thread_create(display_output, output_fifo, input_fifo);

        thread_create(execute, mem->copy(), input_fifo, output_fifo, ended_fifo);

        ended_fifo.read();

        write(sprintf("Score: %d\n", score));
        foreach(tiles, array(int) row) {
            if (row != 0) {
                write(sprintf("%s\n", map(row, lambda(int v) { return tile_id_str[v]; }) * ""));
            }
        }

    }
}
