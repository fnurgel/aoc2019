
int NORTH = 1;
int WEST = 3;
int SOUTH = 2;
int EAST = 4;

ADT.Queue queue_r = ADT.Queue();
ADT.Queue queue_c = ADT.Queue();
ADT.Queue queue_d = ADT.Queue();
multiset visited = (<>);
mapping(string:int) tiles = ([]);
mapping(string:string) previous_tile = ([]);

// north, west, south, east
array(int) dr = ({-1, 0, 1, 0});
array(int) dc = ({ 0,-1, 0, 1});

mapping opposite_direction = ([
    NORTH: SOUTH,
    SOUTH: NORTH,
    WEST: EAST,
    EAST: WEST
]);

void explore_neighbours(int r, int c, int d) {

    for (int i=0; i<4; i++) {
        int rr = r + dr[i];
        int cc = c + dc[i];
        int dd = d;
        string coord_id = coords_to_str(rr, cc);
        sscanf(coord_id, "%d,%d", int maze_y, int maze_x);
        string portal_name;
        if (is_character(maze[maze_y][maze_x])) {
            string coord_id_portal = coords_to_str(r, c);
            portal_name = portals[coord_id_portal];
            array(string) coords = get_coords_of_portal(portal_name);
            if (sizeof(coords) == 2) {
                coords -= ({ coord_id_portal });
                if (sizeof(coords) == 1) {
                    coord_id = coords[0];
                    sscanf(coord_id, "%d,%d", maze_y, maze_x);
                    rr = maze_y;
                    cc = maze_x;
                    dd += portal_dimension[coord_id_portal];
                    if (dd < 0) {
                        dd = 0;
                        continue;
                    }
                } else {
                    write(sprintf("Error @ %s %O\n", portal_name, coords));
                }
            }
        }

        if (visited[coord_id+","+dd]) continue;
        if (maze[maze_y][maze_x] != '.') continue;
        string portal_here = portals[coord_id];
        if (portal_here && d > 0 && (portal_here == "AA" || portal_here == "ZZ")) continue;
        if (portal_name) {
            write(sprintf("Portal %s (%d,%d,%d) -> %d,%d,%d\n", portal_name, r, c, d, rr, cc, dd));
        }
        queue_r.put(rr);
        queue_c.put(cc);
        queue_d.put(dd);
        visited[coord_id+","+dd] = true;
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

int explore(string start_coord_id, string end_coord_id) {
    sscanf(start_coord_id, "%d,%d", int start_y, int start_x);

    write(sprintf("Exploring from %d,%d\n", start_y, start_x));

    queue_r.put(start_y);
    queue_c.put(start_x);
    queue_d.put(0);
    visited[start_coord_id+",0"] = true;

    int r, c, d;
    int reached_end = 0;
    while (!queue_r.is_empty()) {
        r = queue_r.get();
        c = queue_c.get();
        d = queue_d.get();

        string coord_id = coords_to_str(r, c);

        if (coord_id == end_coord_id && d == 0) {
            reached_end = true;
            break;
        }

        explore_neighbours(r, c, d);
        nodes_left_in_layer--;
        if (nodes_left_in_layer == 0) {
            nodes_left_in_layer = nodes_in_next_layer;
            nodes_in_next_layer = 0;
            move_count++;
        }
    }
    if (reached_end) {
        write(sprintf("Done at %d,%d,%d\n", r, c, d));
    }
    return move_count;
}

array(array(int)) maze = 0;

int char2int(string v) {
    sscanf(v, "%c", int char);
    return char;
}

// coord_id:portal_name
mapping(string:string) portals = ([]);
mapping(string:int) portal_dimension = ([]);

int outer_donut_x1, outer_donut_y1;
int outer_donut_x2, outer_donut_y2;
int inner_donut_x1, inner_donut_y1;
int inner_donut_x2, inner_donut_y2;

int is_donut(int char) {
    return char == '#' || char == '.' ;
}

void find_donut_coords() {
    int mid_x = sizeof(maze[0]) / 2;
    int mid_y = sizeof(maze) / 2;

    for (int y = 0; y < sizeof(maze); y++) {
        if (outer_donut_y1 == 0) {
            if (!is_donut(maze[y][mid_x])) continue;
            outer_donut_y1 = y;
        } else if (inner_donut_y1 == 0) {
            if (is_donut(maze[y][mid_x])) continue;
            inner_donut_y1 = y - 1;
        } else if (inner_donut_y2 == 0) {
            if (!is_donut(maze[y][mid_x])) continue;
            inner_donut_y2 = y;
        } else if (outer_donut_y2 == 0) {
            if (is_donut(maze[y][mid_x])) continue;
            outer_donut_y2 = y - 1;
        }
    }

    for (int x = 0; x < sizeof(maze[0]); x++) {
        if (outer_donut_x1 == 0) {
            if (!is_donut(maze[mid_y][x])) continue;
            outer_donut_x1 = x;
        } else if (inner_donut_x1 == 0) {
            if (is_donut(maze[mid_y][x])) continue;
            inner_donut_x1 = x - 1;
        } else if (inner_donut_x2 == 0) {
            if (!is_donut(maze[mid_y][x])) continue;
            inner_donut_x2 = x;
        } else if (outer_donut_x2 == 0) {
            if (is_donut(maze[mid_y][x])) continue;
            outer_donut_x2 = x - 1;
        }
    }

    write(sprintf("outer1: %d,%d inner1: %d,%d inner2: %d,%d outer2: %d,%d\n", 
        outer_donut_x1, outer_donut_y1,
        inner_donut_x1, inner_donut_y1,
        inner_donut_x2, inner_donut_y2,
        outer_donut_x2, outer_donut_y2));
}

int is_character(int char) {
    return char >= 'A' && char <= 'Z';
}

array(string) get_coords_of_portal(string portal_name) {
    array(string) matches = ({});
    foreach(indices(portals), string coord_id) {
        if (portals[coord_id] == portal_name) {
            matches += ({ coord_id });
        }
    }
    return matches;
}

string find_portal_name(int x, int y) {

    for (int i=0; i<4; i++) {
        int dx = x + dc[i];
        int dy = y + dr[i];
        int dx2 = x + dc[i] * 2;
        int dy2 = y + dr[i] * 2;

        if (is_character(maze[dy][dx])) {
            string portal_name;
            if (dy < y || dx < x) {
                portal_name = ({int2char(maze[dy2][dx2]), int2char(maze[dy][dx]) }) * "";
            } else {
                portal_name = ({int2char(maze[dy][dx]), int2char(maze[dy2][dx2]) }) * "";
            }
            write(sprintf("Found portal: %s @ %d,%d\n", portal_name, y, x));
            return portal_name;
        }
    }
}

void find_portals() {
    for (int x = outer_donut_x1; x <= outer_donut_x2; x++) {
        if (maze[outer_donut_y1][x] == '.') {
            portals[coords_to_str(outer_donut_y1, x)] = find_portal_name(x, outer_donut_y1);
            portal_dimension[coords_to_str(outer_donut_y1, x)] = -1;
        }
        if (maze[inner_donut_y1][x] == '.' && x > inner_donut_x1 && x < inner_donut_x2) {
            portals[coords_to_str(inner_donut_y1, x)] = find_portal_name(x, inner_donut_y1);
            portal_dimension[coords_to_str(inner_donut_y1, x)] = 1;
        }
        if (maze[inner_donut_y2][x] == '.' && x > inner_donut_x1 && x < inner_donut_x2) {
            portals[coords_to_str(inner_donut_y2, x)] = find_portal_name(x, inner_donut_y2);
            portal_dimension[coords_to_str(inner_donut_y2, x)] = 1;
        }
        if (maze[outer_donut_y2][x] == '.') {
            portals[coords_to_str(outer_donut_y2, x)] = find_portal_name(x, outer_donut_y2);
            portal_dimension[coords_to_str(outer_donut_y2, x)] = -1;
        }
    }
    for (int y = outer_donut_y1; y <= outer_donut_y2; y++) {
        if (maze[y][outer_donut_x1] == '.') {
            portals[coords_to_str(y, outer_donut_x1)] = find_portal_name(outer_donut_x1, y);
            portal_dimension[coords_to_str(y, outer_donut_x1)] = -1;
        }
        if (maze[y][inner_donut_x1] == '.' && y > inner_donut_y1 && y < inner_donut_y2) {
            portals[coords_to_str(y, inner_donut_x1)] = find_portal_name(inner_donut_x1, y);
            portal_dimension[coords_to_str(y, inner_donut_x1)] = 1;
        }
        if (maze[y][inner_donut_x2] == '.' && y > inner_donut_y1 && y < inner_donut_y2) {
            portals[coords_to_str(y, inner_donut_x2)] = find_portal_name(inner_donut_x2, y);
            portal_dimension[coords_to_str(y, inner_donut_x2)] = 1;
        }
        if (maze[y][outer_donut_x2] == '.') {
            portals[coords_to_str(y, outer_donut_x2)] = find_portal_name(outer_donut_x2, y);
            portal_dimension[coords_to_str(y, outer_donut_x2)] = -1;
        }
    }
}

int main() {
    Stdio.File file = Stdio.FILE();
    file->open("input", "r");
    int y = 0;
    foreach(file->line_iterator(true); int idx; string line) {
        array(string) line_arr = line / "";
        if (maze == 0) {
            maze = allocate(sizeof(line_arr));
        }
        maze[y++] = map(line_arr, lambda(string v) { return char2int(v); });
    }

    find_donut_coords();

    find_portals();

    write(sprintf("%O\n", portals));
    
    int moves = explore(get_coords_of_portal("AA")[0], get_coords_of_portal("ZZ")[0]);
    write(sprintf("moves: %d\n", moves));

    // foreach(indices(portals), string coord_id) {
    //     write(sprintf("%s %s %d\n", portals[coord_id], coord_id, portal_dimension[coord_id]));
    // }
}
