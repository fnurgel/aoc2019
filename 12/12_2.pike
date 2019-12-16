
int lcm(array(int) nums) {
    int lcm = 1;
    int divisor = 2;

    while (true) {
        int counter = 0;
        int divisable = false;

        for (int i=0; i<sizeof(nums); i++) {
            if (nums[i] == 0) {
                return 0;
            }
            else if (nums[i] < 0) {
                nums[i] = -nums[i];
            }
            if (nums[i] == 1) {
                counter++;
            }

            if (nums[i] % divisor == 0) {
                divisable = true;
                nums[i] = nums[i] / divisor;
            }
        }

        if (divisable) {
            lcm = lcm * divisor;
        } else {
            divisor++;
        }

        if (counter == sizeof(nums)) {
            return lcm;
        }
    }
}

void find_axis_repeat(array(int) coords, string id, Thread.Fifo end_signal) {
    array(int) vel = allocate(4);
    string origin = sprintf("%O", coords);

    int steps = 0;
    while (true) {
        int gr = limit(-1, coords[1] - coords[0], 1);
        vel[0] += gr;
        vel[1] -= gr;
        gr = limit(-1, coords[2] - coords[0], 1);
        vel[0] += gr;
        vel[2] -= gr;
        gr = limit(-1, coords[3] - coords[0], 1);
        vel[0] += gr;
        vel[3] -= gr;
        gr = limit(-1, coords[2] - coords[1], 1);
        vel[1] += gr;
        vel[2] -= gr;
        gr = limit(-1, coords[3] - coords[1], 1);
        vel[1] += gr;
        vel[3] -= gr;
        gr = limit(-1, coords[3] - coords[2], 1);
        vel[2] += gr;
        vel[3] -= gr;

        coords[0] += vel[0];
        coords[1] += vel[1];
        coords[2] += vel[2];
        coords[3] += vel[3];

        steps++;
        if (vel[0] == 0 && vel[1] == 0 && vel[2] == 0 && vel[3] == 0) {
            if (sprintf("%O", coords) == origin) {
                write(sprintf("%s: repeat on step %d\n", id, steps));
                end_signal.write(steps);
                return;
            }
        }          
    }
}

int main() {
    Stdio.File file = Stdio.FILE();
    file->open("input", "r");

    array(int) arr_x = ({});
    array(int) arr_y = ({});
    array(int) arr_z = ({});

    foreach(file->line_iterator(true); int idx; string line) {
        int x, y, z;
        sscanf(line, "<x=%d, y=%d, z=%d>", x, y, z);
        arr_x += ({ x });
        arr_y += ({ y });
        arr_z += ({ z });
    }
    object(Thread.Fifo) end_signal = Thread.Fifo();

    thread_create(find_axis_repeat, arr_x, "x", end_signal);
    thread_create(find_axis_repeat, arr_y, "y", end_signal);
    thread_create(find_axis_repeat, arr_z, "z", end_signal);

    array(int) nums = ({});
    nums += ({ end_signal.read() });
    nums += ({ end_signal.read() });
    nums += ({ end_signal.read() });

    write(sprintf("%O\n", lcm(nums)));
}
