class point {
    int x;
    int y;
    int distance;

    void create(int _x, int _y) {
        x = _x;
        y = _y;
        distance = x + y;
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

array(float) find_slopes_to_all_others(array(point) points, int index) {
    point origin = points[index];
    array(float) slopes = ({});
    for (int i=0; i<sizeof(points); i++) {
        if (index == i) {
            continue;
        }
        slopes += ({ find_slope(origin, points[i]) });
    }
    return slopes;
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

    for (int i=0; i<sizeof(points); i++) {
        int detected = sizeof(Array.uniq(find_slopes_to_all_others(points, i)));

        if (detected > most_detected) {
            most_detected = detected;
            most_detected_point = points[i];
        }
    }

    write(sprintf("%O,%O: %O\n", most_detected_point.x, most_detected_point.y, most_detected));

    write(sprintf("%O\n", find_slopes_to_all_others(points, 3)));
}
