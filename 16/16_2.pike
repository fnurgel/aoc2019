
int main() {
    Stdio.File file = Stdio.FILE();
    file->open("input", "r");

    foreach(file->line_iterator(true); int idx; string line) {
        string input = allocate(10000, line) * "";
        string offset = input[0..6];
        string input_after_offset = input[(int)offset..];

        array(string) numbers = input_after_offset / "";

        int phases = 100;
        do {
            int sum = 0;
            array(string) values = ({});
            for (int i = sizeof(numbers) - 1; i >= 0; i--) {
                int value = (int)numbers[i];
                sum += value;
                values += ({ ((string)sum)[<0..<0] });
            }
            numbers = reverse(values);
            write(sprintf("%d: %s %d\n", phases, numbers[0..7] * "", sum));
        } while (--phases);

        write(sprintf("%s\n", numbers[0..7] * ""));
    }
    return 0;
}
