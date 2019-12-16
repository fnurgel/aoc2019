class result_multiple {
    string name;
    int multiple;

    void create(string _name, int _multiple) {
        name = _name;
        multiple = _multiple;
    }

    string to_string() {
        return sprintf("%s * %d", name, multiple);
    }
}

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

array(result_multiple) quantity_needed(string name, int quantity) {
    chemical c = reactions[name];

    if (c == 0) {
        return ({ result_multiple(name, quantity) });
    }

    int multiplier = quantity / c.quantity;

    int less_than_produced = quantity % c.quantity;

    if (less_than_produced > 0) {
        multiplier++;
    }
    array(result_multiple) needed_result = ({});
    foreach(c.needed_chemicals, chemical needed_c) {
        write(sprintf("%O\n", needed_c.to_string()));
        if (needed_c.name == "ORE") {
            needed_result += ({ result_multiple(name, quantity) });
        } else {
            needed_result += quantity_needed(needed_c.name, needed_c.quantity * multiplier);
        }
    }
    return needed_result;
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

    write(sprintf("%O\n", map(values(reactions), lambda(chemical c) { return c->to_string(); })));

    array(result_multiple) needed = quantity_needed("FUEL", 1);

    write(sprintf("%O\n", map(needed, lambda(result_multiple r) { return r->to_string(); })));

    mapping amount = ([]);
    foreach(needed, result_multiple r) {
        amount[r.name] += r->multiple;
    }
    write(sprintf("Amount: %O\n", amount));

    int total_ore = 0;
    foreach(indices(amount), string name) {
        int ore_amount = amount[name];
        int multiplier = ore_amount / reactions[name].quantity;
        if (ore_amount % reactions[name].quantity > 0) {
            multiplier++;
        }
        write(sprintf("%s: %d\n", name, multiplier));
        total_ore += multiplier * reactions[name].needed_chemicals[0].quantity;
    }
    write(sprintf("Ore: %O\n", total_ore));
}
