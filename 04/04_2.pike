int check(string number, int position, int previous_number, mapping instances) {
    int current = (int)number[position..position];
    if (current < previous_number) {
        return false;
    }
    if (instances[current] == 0) {
        instances[current] = 0;
    }
    instances[current]++;
    if (position + 1 < sizeof(number)) {
        return check(number, position + 1, current, instances);
    }
    foreach(indices(instances), int v) {
        if (instances[v] == 2) {
            return true;
        }
    }
    return false;
}

int match(int number) {
    string number_str = (string) number;

    return check(number_str, 0, -1, ([]));
}

int main() {
    int matches = 0;

    for (int i = 248345; i <= 746315; i++) {
        if (match(i)) {
            matches++;
        }
    }
    write(sprintf("%O\n", matches));
}