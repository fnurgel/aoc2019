
int find_orbits(mapping relations, string key, int level) {
    int orbits = 0;
    if (level > 0) {
        orbits++; // direct
    }
    if (level > 1) {
        orbits += level - 1; // indirect
    }
    if (relations[key] != 0) {
        foreach(indices(relations[key]), string child) {
            orbits += find_orbits(relations, child, level + 1);
        }
    }
    return orbits;
}

int main() {
    Stdio.File file = Stdio.FILE();
    file->open("input", "r");

    mapping relations = ([]);

    foreach(file->line_iterator(true); int idx; string line) {
        array(string) relation = line / ")";
        if (relations[relation[0]] == 0) {
            relations += ([ relation[0]: (<>) ]);
        }
        relations[relation[0]] += (< relation[1] >);
    }
    write(sprintf("%O\n", find_orbits(relations, "COM", 0)));
    return 0;
}
