class coord {
    int x, y, z;

    void create(int _x, int _y, int _z) {
        x = _x;
        y = _y;
        z = _z;
    }

    string to_string() {
        return sprintf("<x=% 03d, y=% 03d, z=% 03d", x, y, z);
    }

}

class planet {
    inherit coord;

    coord velocity = coord(0,0,0);

    coord velocity_towards(coord other) {
        int vx = x - other.x > 0 ? -1 : x - other.x < 0 ? 1 : 0;
        int vy = y - other.y > 0 ? -1 : y - other.y < 0 ? 1 : 0;
        int vz = z - other.z > 0 ? -1 : z - other.z < 0 ? 1 : 0;
        return coord(vx, vy, vz);
    }

    void apply_velocity(coord v) {
        velocity.x += v.x;
        velocity.y += v.y;
        velocity.z += v.z;

        x += velocity.x;
        y += velocity.y;
        z += velocity.z;
    }

    int get_energy() {
        return (abs(x) + abs(y) + abs(z)) * (abs(velocity.x) + abs(velocity.y) + abs(velocity.z));
    }
}

int main() {
    Stdio.File file = Stdio.FILE();
    file->open("input", "r");

    array(planet) planet_coords = ({});

    foreach(file->line_iterator(true); int idx; string line) {
        int x, y, z;
        sscanf(line, "<x=%d, y=%d, z=%d>", x, y, z);
        planet_coords += ({ planet(x, y, z) });
    }
    write(sprintf("%O\n", map(planet_coords, lambda(planet c) { return c.to_string(); })));

    int steps = 1000;
    for (int step = 0; step < steps; step++) {

        mapping velocities = ([]);
        int start_planet = 0;
        do {
            for (int i=start_planet+1;i<sizeof(planet_coords);i++) {
                if (velocities[start_planet] == 0) {
                    velocities[start_planet] = ({});
                }
                velocities[start_planet] += ({ planet_coords[start_planet]->velocity_towards(planet_coords[i]) });
                if (velocities[i] == 0) {
                    velocities[i] = ({});
                }
                velocities[i] += ({ planet_coords[i]->velocity_towards(planet_coords[start_planet]) });
            }
            start_planet++;
        } while (start_planet < sizeof(planet_coords)-1);

        mapping final_velocities = ([]);
        foreach(indices(velocities), int planet_idx) {
            int vx = 0;
            int vy = 0;
            int vz = 0;
            foreach(velocities[planet_idx], coord planet_vel) {
                vx += planet_vel.x;
                vy += planet_vel.y;
                vz += planet_vel.z;
            }
            final_velocities[planet_idx] = coord(vx, vy, vz);
        }

        write(sprintf("velocities: %O\n", map(values(final_velocities), lambda(coord c) { return c.to_string(); })));

        foreach(indices(final_velocities), int planet_idx) {
            planet_coords[planet_idx]->apply_velocity(final_velocities[planet_idx]);
        }

        write(sprintf("planet: %O\n", map(planet_coords, lambda(planet c) { return c.to_string(); })));
    }

    int energy = 0;
    foreach(planet_coords, planet p) {
        energy += p->get_energy();
    }

    write(sprintf("Total enrgy: %O", energy));
}
