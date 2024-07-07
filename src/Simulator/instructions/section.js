class Section extends Instruction {
    constructor(line, column, name) {
        super();
        this.line = line;
        this.column = column;
        this.name = name;
    }

    execute() {
    }

    buildCST(parent, cst) {
        return null;
    }
}