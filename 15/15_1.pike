inherit "intcode_program";

int NORTH = 1;
int WEST = 3;
int SOUTH = 2;
int EAST = 4;

mapping camera_codes = ([
    0: "#",
    1: ".",
    2: "X"
]);

ADT.Queue queue_r = ADT.Queue();
ADT.Queue queue_c = ADT.Queue();
multiset visited = (<>);
mapping tiles = ([]);
mapping previous_tile = ([]);

// north, west, south, east
array(int) dr = ({-1, 0, 1, 0});
array(int) dc = ({ 0,-1, 0, 1});
array(int) direction_command = ({NORTH, WEST, SOUTH, EAST});

mapping opposite_direction = ([
    NORTH: SOUTH,
    SOUTH: NORTH,
    WEST: EAST,
    EAST: WEST
]);

void reveal_map() {
    int r = start_r;
    int c = start_c;
    int direction_idx = 0;
    tiles[coords_to_str(start_r, start_c)] = "S";
    while (true) {
        reveal_neighbours(r, c);
        string next_tile;
        do {
            direction_idx = (direction_idx + 1) % sizeof(dr);
            next_tile = tiles[coords_to_str(r + dr[direction_idx], c + dc[direction_idx])];
        } while (next_tile == "#");
        int cmd = direction_command[direction_idx];
        droid_in.write(cmd);
        int status = droid_out.read();
        if (status != 0) {
            r += dr[direction_idx];
            c += dc[direction_idx];
        }
        if (r == start_r && c == start_c) {
            display_tiles();
            break;
        }
        direction_idx = (direction_idx - 2) % sizeof(dr);
    }
}

void reveal_neighbours(int r, int c) {
    for (int i=0; i<4; i++) {
        int rr = r + dr[i];
        int cc = c + dc[i];
        string coord_id = coords_to_str(rr, cc);
        if (tiles[coord_id] != 0) continue;
        tiles[coord_id] = reveal_direction(direction_command[i]);
    }
}

string reveal_direction(int d) {
    droid_in.write(d);
    int status = droid_out.read();
    if (status != 0) {
        droid_in.write(opposite_direction[d]);
        droid_out.read();
    }
    return camera_codes[status];
}

void explore_neighbours(int r, int c) {

    for (int i=0; i<4; i++) {
        int rr = r + dr[i];
        int cc = c + dc[i];

        string coord_id = coords_to_str(rr, cc);

        if (visited[coord_id]) continue;

        if (tiles[coord_id] == "#") continue;

        queue_r.put(rr);
        queue_c.put(cc);
        visited[coord_id] = true;
        previous_tile[coord_id] = coords_to_str(r, c);
        nodes_in_next_layer++;
    }

}

string coords_to_str(int r, int c) {
    return sprintf("%d,%d", r, c);
}

int start_r=0;
int start_c=0;
int move_count = 0;
int nodes_in_next_layer = 0;
int nodes_left_in_layer = 1;

int explore() {
    queue_r.put(start_r);
    queue_c.put(start_c);
    visited[coords_to_str(start_r, start_c)] = true;

    int r, c;
    int reached_end = 0;
    while (!queue_r.is_empty()) {
        r = queue_r.get();
        c = queue_c.get();

        string coord_id = coords_to_str(r, c);

        if (tiles[coord_id] == "X") {
            reached_end = true;
            break;
        }
        explore_neighbours(r, c);
        nodes_left_in_layer--;
        if (nodes_left_in_layer == 0) {
            nodes_left_in_layer = nodes_in_next_layer;
            nodes_in_next_layer = 0;
            move_count++;
        }
    }
    if (reached_end) {
        return move_count;
    }
    return -1;
}

void display_tiles() {
    int lowest_r = 10000, lowest_c = 10000, highest_r = -10000, highest_c = -10000;

    foreach(indices(tiles), string coord_id) {
        sscanf(coord_id, "%d,%d", int r, int c);
        lowest_r = min(lowest_r, r);
        highest_r = max(highest_r, r);
        lowest_c = min(lowest_c, c);
        highest_c = max(highest_c, c);

    }

    int nr_rows = highest_r - lowest_r + 1;
    int nr_columns = highest_c - lowest_c + 1;

    array(array(string)) tiles_arr = allocate(nr_rows);
    for (int i=0; i<nr_rows;i++) {
        tiles_arr[i] = allocate(nr_columns, " ");
    }
    foreach(indices(tiles), string coord_id) {
        sscanf(coord_id, "%d,%d", int r, int c);
        tiles_arr[r - lowest_r][c - lowest_c] = tiles[coord_id];
    }

    foreach(tiles_arr, array(string) row) {
        write(sprintf("%s\n", row * ""));
    }
}

object(Thread.Fifo) droid_in = Thread.Fifo();
object(Thread.Queue) droid_out = Thread.Queue();


int main() {
    Stdio.File file = Stdio.FILE();
    file->open("input", "r");

    foreach(file->line_iterator(true); int idx; string line) {

        array(int) int_codes = map(line / ",", lambda(string v) { return (int)v; });

        memory mem = memory(int_codes, 100000);

        object(Thread.Fifo) ended_fifo = Thread.Queue();

        thread_create(execute, mem->copy(), droid_in, droid_out, ended_fifo);

        reveal_map();

        int moves = explore();

        write(sprintf("Ended! %d", moves));
    }
}
