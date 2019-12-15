inherit "intcode_program";

int main() {
    Stdio.File file = Stdio.FILE();
    file->open("input", "r");

    foreach(file->line_iterator(true); int idx; string line) {
        array(int) int_codes = map(line / ",", lambda(string v) { return (int)v; });
        memory mem = memory(int_codes, 10000);

        object(Thread.Fifo) input_fifo = Thread.Fifo();
        object(Thread.Fifo) output_fifo = Thread.Fifo();

        input_fifo.write(1);

        execute(mem->copy(), input_fifo, output_fifo);

        while (true) {
            write(sprintf("%O\n", output_fifo.read()));
        }
    }

    return 0;
}
