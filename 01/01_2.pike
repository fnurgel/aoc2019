
int fuel(int mass) {
    return (int)(floor(mass / 3)) - 2;
}

int fuel_and_fuel_of_fuel(int mass) {
    int f = fuel(mass);
    if (f > 0) {
        return f + fuel_and_fuel_of_fuel(f);
    }
    return 0;
}

int main() {
    Stdio.File file = Stdio.FILE();
    file->open("input", "r");
    int sum = 0;
    foreach(file->line_iterator(true); int idx; string line) {
        sum += fuel_and_fuel_of_fuel((int)line);
    }

    write((string) sum + "\n");
    return 0;
}