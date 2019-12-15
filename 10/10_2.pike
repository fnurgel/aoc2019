class point {
    int x;
    int y;

    void create(int _x, int _y) {
        x = _x;
        y = _y;
    }

    string to_string() {
        return sprintf("(%O,%O)", x, y);
    }
}

float find_slope(point p1, point p2) {
    int x = p2.x - p1.x;
    int y = p2.y - p1.y;
    if (x == 0) {
        if (y > 0) {
            return 1.5;
        } else {
            return -1.5;
        }
    }
    float slope = atan((float)y/x);
    if (x < 0) {
        slope += 3;
    }
    return slope;
}

mapping find_slopes_to_all_others(array(point) points, int index) {
    point origin = points[index];
    mapping slopes = ([]);
    for (int i=0; i<sizeof(points); i++) {
        if (index == i) {
            continue;
        }
        float slope = find_slope(origin, points[i]);
        if (slopes[slope] == 0) {
            slopes[slope] = ({});
        }
        slopes[slope] += ({ points[i] });
    }
    return slopes;
}

int distance_to(point origin, point to) {
    return abs(to.x - origin.x) + abs(to.y - origin.y);
}

int main() {
    Stdio.File file = Stdio.FILE();
    file->open("input", "r");

    array(point) points = ({});

    int y = 0;
    foreach(file->line_iterator(true); int idx; string line) {
        int x = 0;
        foreach(line / "", string character) {
            if (character == "#") {
                points += ({ point(x, y) });
            }
            x++;
        }
        y++;
    }

    int most_detected = 0;
    point most_detected_point;
    mapping most_detected_slopes;

    for (int i=0; i<sizeof(points); i++) {
        mapping slopes = find_slopes_to_all_others(points, i);
        int detected = sizeof(Array.uniq(indices(slopes)));

        if (detected > most_detected) {
            most_detected = detected;
            most_detected_point = points[i];
            most_detected_slopes = slopes;
        }
    }

    write(sprintf("%O,%O: %O\n", most_detected_point.x, most_detected_point.y, most_detected));

    array slopes_in_order = sort(indices(most_detected_slopes));

    int has_removed;
    int nr_removed = 0;

    do {
        has_removed = false;
        foreach(slopes_in_order, float slope) {
            array points_on_angle = most_detected_slopes[slope];
            if (sizeof(points_on_angle) > 0) {
                array distances = map(points_on_angle, lambda(point p) { return distance_to(most_detected_point, p); });
                sort(distances, points_on_angle);
                most_detected_slopes[slope] = most_detected_slopes[slope] - ({ points_on_angle[0] });
                has_removed = true;
                nr_removed++;
                if (nr_removed == 200) {
                    write(points_on_angle[0].to_string()+"\n");
                    write("result = " + (points_on_angle[0].x * 100 + points_on_angle[0].y) + "\n");
                }
            }
        }
    } while(has_removed);
}
