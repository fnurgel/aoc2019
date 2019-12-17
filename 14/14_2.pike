
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

void do_on_thread(Thread.Fifo in, Thread.Fifo out) {
    while (true) {
        string name = in.read();
        int quantity = in.read();

        int result = do_reaction(name, quantity);
        out.write(result);
    }
}

int do_reaction(string name, int quantity) {
    chemical c = reactions[name];

    int in_stock = name != "FUEL" ? materials[c.name] : 0;
    int used_from_stock = min(in_stock, quantity);
    int left_to_produce = quantity - used_from_stock;
    int multiplier = left_to_produce / c.quantity;
    if (left_to_produce % c.quantity > 0) {
        multiplier++;
    }

    for (int i=0; i<sizeof(c.needed_chemicals);i++) {
        chemical needed_c = c.needed_chemicals[i];
        if (needed_c.name == "ORE") {
            if (materials[needed_c.name] < needed_c.quantity * multiplier) {
                write("No more ORE\n");
                return false;
            }
        } else {
            if (do_reaction(needed_c.name, needed_c.quantity * multiplier) == 0) {
                return false;
            }
        }
        materials[needed_c.name] -= needed_c.quantity * multiplier;
    }

    materials[name] += c.quantity * multiplier;

    return true;
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

    materials["ORE"] = 1000000000000;
    int fuels = 0;
    while(true) {
        int result = do_reaction("FUEL", 1);
        if (!result) {
            break;
        }
        fuels++;
        if (fuels % 10000 == 0) {
            write(sprintf("Materials: %O\n", materials));
            write(sprintf("Fuels: %d\n", fuels));
        }
    }
    write(sprintf("Materials: %O\n", materials));
    write(sprintf("Fuels: %d", fuels));
}
