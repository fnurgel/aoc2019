inherit "intcode_program";

int main() {
    Stdio.File file = Stdio.FILE();
    file->open("input", "r");

    foreach(file->line_iterator(true); int idx; string line) {

        array(int) int_codes = map(line / ",", lambda(string v) { return (int)v; });
        memory mem = memory(int_codes, 100000);

        object(Thread.Fifo) input_fifo = Thread.Fifo();
        object(Thread.Queue) output_fifo = Thread.Queue();
        object(Thread.Fifo) ended_fifo = Thread.Fifo();

        input_fifo.write(1);

        thread_create(execute, mem->copy(), input_fifo, output_fifo, ended_fifo);

        // while (true) {
        //     write(sprintf("out: %O\n", output_fifo.read()));

        // }
        ended_fifo.read();
        mapping tiles = ([]);

        for (int i = 0; i < output_fifo.size(); i++) {
            int x = output_fifo.read();
            int y = output_fifo.read();
            int tile_id = output_fifo.read();
            tiles[sprintf("%d,%d", x, y)] = tile_id;
//            write(sprintf("%O\n", output_fifo.read()));
        }

        int block_tiles = 0;
        foreach(indices(tiles), string tile_coord) {
            if (tiles[tile_coord] == 2) {
                block_tiles++;
            }
        }

        write(sprintf("Block tiles: %O\n", block_tiles));
    }
}
