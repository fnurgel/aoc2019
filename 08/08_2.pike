
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

void merge_layer(array rows, array merged) {
    for (int row=0; row<sizeof(rows); row++) {
        array(int) columns = rows[row];
        for (int column=0; column<sizeof(columns); column++) {
            switch(columns[column]) {
                case 0:
                case 1:
                    merged[row][column] = columns[column];
                    break;
            }
        }
    }
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

        array merged = ({});
        for (int i=0; i<size_y; i++) {
            merged += ({ allocate(size_x) });
        }
        for (int l=sizeof(layers)-1; l>=0; l--) {
            merge_layer(layers[l], merged);
        }

        foreach(merged, array(int) row) {
            write(map(row, print_pixel) * "" + "\n");
        }
    }

    return 0;
}

string print_pixel(int pixel) {
    if (pixel == 0) {
        return " ";
    } else if (pixel == 1) {
        return "O";
    }
}