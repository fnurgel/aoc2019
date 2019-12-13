inherit "wires.pike";

int main() {
    array(coord) collisions = find_collisions();

    int min_distance = 0;
    foreach(collisions, coord c) {
        int this_distance = abs(c.x) + abs(c.y);
        if (min_distance == 0 || this_distance < min_distance) {
            min_distance = this_distance;
        }
    }
    write("min_distance: " + (string)min_distance + "\n");
    return 0;
}
