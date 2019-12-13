
int fuel(int mass) {
    return (int)(floor(mass / 3)) - 2;
}

int main() {
    Stdio.File file = Stdio.FILE();
    file->open("input", "r");
    int sum = 0;
    foreach(file->line_iterator(true); int idx; string line) {
        sum += fuel((int)line);
    }

    write((string) sum + "\n");
    return 0;
}
