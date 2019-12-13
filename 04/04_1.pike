int check(string number, int position, int previous_number, int had_double) {
    int current = (int)number[position..position];
    if (current < previous_number) {
        return false;
    }
    int have_double = had_double;
    if (current == previous_number) {
        have_double |= true;
    }
    if (position + 1 < sizeof(number)) {
        return check(number, position + 1, current, have_double);
    }
    return have_double;
}

int match(int number) {
    string number_str = (string) number;

    return check(number_str, 0, -1, false);
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