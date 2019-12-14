mapping parents = ([]);
mapping relations = ([]);

multiset(string) find_jumps(string from, string to) {
    string current = from;
    multiset(string) path = (<>);
    while (parents[current] != to) {
        current = parents[current];
        path += (<current>);
    }
    return path;
}

int main() {
    Stdio.File file = Stdio.FILE();
    file->open("input", "r");

    foreach(file->line_iterator(true); int idx; string line) {
        array(string) relation = line / ")";
        if (relations[relation[0]] == 0) {
            relations += ([ relation[0]: (<>) ]);
        }
        relations[relation[0]] += (< relation[1] >);
        parents[relation[1]] = relation[0];
    }

    multiset jumps = find_jumps("YOU", "COM") ^ find_jumps("SAN", "COM");
    write(sprintf("%O\n", sizeof(jumps)));
    return 0;
}
