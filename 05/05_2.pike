inherit "intcode_program";

int main() {
    Stdio.File file = Stdio.FILE();
    file->open("input", "r");

    foreach(file->line_iterator(true); int idx; string line) {
        array(int) int_codes = map(line / ",", lambda(string v) { return (int)v; });
        write("Finished! " + execute(int_codes, 5));
    }

    return 0;
}
