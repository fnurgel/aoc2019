
class chemical {
    string name;
    int quantity;
    array(chemical) needed_chemicals = ({});

    void create(string quantity_and_name, array(chemical) _needed) {
        sscanf(quantity_and_name, "%d %s", quantity, name);
        needed_chemicals = _needed;
    }
    void add_needed_chemical(chemical c) {
        needed_chemicals += ({ c });
    }

    string to_string() {
        return sprintf("%s:%d <- %O", name, quantity, map(needed_chemicals, lambda(chemical c) { return c->to_string(); }));
    }
}

mapping reactions = ([]);
mapping materials = ([]);

void do_reaction(string name, int quantity) {
    chemical c = reactions[name];

    int in_stock = materials[c.name];
    int used_from_stock = min(in_stock, quantity);
    int left_to_produce = quantity - used_from_stock;
    int multiplier = left_to_produce / c.quantity;
    if (left_to_produce % c.quantity > 0) {
        multiplier++;
    }
    foreach(c.needed_chemicals, chemical needed_c) {
        if (needed_c.name == "ORE") {
            materials[needed_c.name] += needed_c.quantity * multiplier;
        } else {
            do_reaction(needed_c.name, needed_c.quantity * multiplier);
            materials[needed_c.name] -= needed_c.quantity * multiplier;
        }
    }
    materials[name] += c.quantity * multiplier;
}

int main() {
    Stdio.File file = Stdio.FILE();
    file->open("input", "r");

    foreach(file->line_iterator(true); int idx; string line) {
        array(string) split1 = line / " =>";
        chemical result = chemical(split1[1], ({}));
        foreach(split1[0] / ", ", string needed_str) {
            result.add_needed_chemical(chemical(needed_str, ({})));
        }
        reactions[result.name] = result;
    }

    do_reaction("FUEL", 1);

    write(sprintf("Materials: %O\n", materials));
}
