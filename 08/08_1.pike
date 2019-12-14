
mapping find_number_of_numbers(array rows) {
    mapping numbers = ([]);
    foreach(rows, array line) {
        foreach(line, int number) {
            if (numbers[number] == 0) {
                numbers[number] = 0;
            }
            numbers[number]++;
        }
    }
    return numbers;
}

int main() {
    Stdio.File file = Stdio.FILE();
    file->open("input", "r");

    int size_x = 25;
    int size_y = 6;

    foreach(file->line_iterator(true); int idx; string line) {
        array layers = ({});

        int position = 0;
        int layer_row = 0;
        array rows = ({});
        do {
            rows += ({ map(line[position..position + size_x-1] / "", lambda(string v) { return (int)v; }) });
            if (sizeof(rows) >= size_y) {
                layers += ({ rows });
                rows = ({});
            }
            position += size_x;
        } while (position < sizeof(line));

        array layer_numbers = ({});
        int fewest_zeroes = 900;
        int fewest_layer = -1;
        foreach(layers, array rows) {
            mapping numbers = find_number_of_numbers(rows);
            layer_numbers += ({ numbers });
            if (numbers[0] < fewest_zeroes) {
                fewest_zeroes = numbers[0];
                fewest_layer = sizeof(layer_numbers) - 1;
            }
        }
        int result = layer_numbers[fewest_layer][1] * layer_numbers[fewest_layer][2];

        write(sprintf("%O %O %O\n", fewest_zeroes, fewest_layer, result));
    }

    return 0;
}
