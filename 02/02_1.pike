inherit "intcode_program";

int main() {
    Stdio.File file = Stdio.FILE();
    file->open("input", "r");

    foreach(file->line_iterator(true); int idx; string line) {
        array(int) int_codes = map(line / ",", lambda(string v) { return (int)v; });
        int_codes[1] = 12;
        int_codes[2] = 2;
        write("Finished! " + execute(int_codes, 0));
    }

    return 0;
}
