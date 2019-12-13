inherit "intcode_program";

int main() {
    Stdio.File file = Stdio.FILE();
    file->open("input", "r");

    foreach(file->line_iterator(true); int idx; string line) {
        for (int noun = 1; noun < 99; noun++) {
            for (int verb = 1; verb < 99; verb++) {
                array(int) int_codes = map(line / ",", lambda(string v) { return (int)v; });
                int_codes[1] = noun;
                int_codes[2] = verb;
                int result = execute(int_codes, 0);
                write("" + result + "\n");
                if (result == 19690720) {
                    int answer = 100 * noun + verb;
                    write("noun = " + noun + ", verb = " + verb + ", answer = " + answer);
                    return 0;
                }
            }
        }
    }
    return 0;
}
