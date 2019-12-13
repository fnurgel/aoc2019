
int execute(array(int) int_codes, int position) {
    while (true) {
        function f;
        switch(int_codes[position]) {
            case 1:
                f = lambda(int a, int b) { return a + b; };
                break;
            case 2:
                f = lambda(int a, int b) { return a * b; };
                break;
            case 99:
                return int_codes[0];
        }
        int int1 = int_codes[int_codes[position + 1]];
        int int2 = int_codes[int_codes[position + 2]];
        int_codes[int_codes[position + 3]] = f(int1, int2);

        position += 4;
    }
}
