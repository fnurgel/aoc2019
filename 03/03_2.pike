inherit "wires.pike";

int main() {

    array(coord) collisions = find_collisions();

    int min_steps = 0;
    foreach(collisions, coord c) {
        int this_steps = 0;
        foreach(values(c.steps), int steps) {
            this_steps += steps;
        }
        if (min_steps == 0 || this_steps < min_steps) {
            min_steps = this_steps;
        }
    }
    write("min_steps: " + (string)min_steps + "\n");
    return 0;
}
