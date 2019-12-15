class coord {
    int x, y, z;

    void create(int _x, int _y, int _z) {
        x = _x;
        y = _y;
        z = _z;
    }

    string to_string() {
        return sprintf("% 03d% 03d% 03d", x, y, z);
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

    string to_string() {
        return sprintf("%s%s", ::to_string(), velocity->to_string());
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

    string str_to_hash = "";
    foreach(planet_coords, planet p) {
        str_to_hash += p.to_string();
    }
    int origin_hash = hash(str_to_hash);

    mapping velocities = ([]);
    mapping final_velocities = ([]);

    int step = 0;
    while (true) {

        int start_planet = 0;
        do {
            for (int i=start_planet+1;i<sizeof(planet_coords);i++) {
                if (velocities[start_planet] == 0) {
                    velocities[start_planet] = allocate(sizeof(planet_coords));
                }
                velocities[start_planet][i] = planet_coords[start_planet]->velocity_towards(planet_coords[i]);
                if (velocities[i] == 0) {
                    velocities[i] = allocate(sizeof(planet_coords));
                }
                velocities[i][start_planet] = planet_coords[i]->velocity_towards(planet_coords[start_planet]);
            }
            start_planet++;
        } while (start_planet < sizeof(planet_coords)-1);

        foreach(indices(velocities), int planet_idx) {
            int vx = 0;
            int vy = 0;
            int vz = 0;
            foreach(velocities[planet_idx], coord planet_vel) {
                if (planet_vel != 0) {
                    vx += planet_vel.x;
                    vy += planet_vel.y;
                    vz += planet_vel.z;
                }
            }
            final_velocities[planet_idx] = coord(vx, vy, vz);
        }

        foreach(indices(final_velocities), int planet_idx) {
            planet_coords[planet_idx]->apply_velocity(final_velocities[planet_idx]);
        }
        step++;
        string str_to_hash = "";
        foreach(planet_coords, planet p) {
            str_to_hash += p.to_string();
        }
        int hash = hash(str_to_hash);
        if (hash == origin_hash) {
            write(sprintf("Match found on step %d %d %O\n", step, hash, map(planet_coords, lambda(planet c) { return c.to_string(); })));
            return 0;
        }

    }

    int energy = 0;
    foreach(planet_coords, planet p) {
        energy += p->get_energy();
    }

    write(sprintf("Total enrgy: %O", energy));
}
