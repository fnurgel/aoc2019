class coord {
    int x;
    int y;
    mapping steps;
}

mapping merge_coords(mapping c1, mapping c2) {
    mapping new_map = c2;
    foreach(indices(c1), int x) {
        if (c2[x] != 0) {
            new_map[x] = c1[x] + c2[x];
        } else {
            new_map[x] = c1[x];
        }
    }
    return new_map;
}

array(coord) find_collisions() {
    array(coord) collisions = ({});

    Stdio.File file = Stdio.FILE();
    file->open("input", "r");

    mapping coords = ([]);

    foreach(file->line_iterator(true); int circuit_id; string line) {
        int current_x = 0;
        int current_y = 0;
        int x_adder = 0;
        int y_adder = 0;

        mapping new_coords = ([]);
        int steps = 0;

        foreach(line / ",", string direction) {
            switch (direction[0..0]) {
                case "R":
                    x_adder = 1;
                    y_adder = 0;
                    break;
                case "L":
                    x_adder = -1;
                    y_adder = 0;
                    break;
                case "U":
                    x_adder = 0;
                    y_adder = 1;
                    break;
                case "D":
                    x_adder = 0;
                    y_adder = -1;
                    break;
            }
            int to_travel = (int)direction[1..];
            for (int i = 0; i < to_travel; i++) {
                steps++;
                current_x += x_adder;
                current_y += y_adder;
                if (new_coords[current_x] == 0) {
                    new_coords[current_x] = ([]);
                }
                if (new_coords[current_x][current_y] == 0) {
                    new_coords[current_x][current_y] = ([]);
                }
                if (new_coords[current_x][current_y][circuit_id] == 0
                    || new_coords[current_x][current_y][circuit_id] > steps) {
                    new_coords[current_x][current_y][circuit_id] = steps;
                    if (coords[current_x] != 0 && coords[current_x][current_y] != 0) {
                        coord c = coord();
                        c.x = current_x;
                        c.y = current_y;
                        c.steps = coords[current_x][current_y] + new_coords[current_x][current_y];
                        collisions += ({ c });
                    }
                }
            }
        }

        coords = merge_coords(new_coords, coords);
    }
    return collisions;
}