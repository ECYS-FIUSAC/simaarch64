class Label extends Instruction {
    constructor(line, column, label) {
        super();
        this.line = line;
        this.column = column;
        this.label = label.trim().toLowerCase();
    }

    execute(ast, env, gen) {
        // console.log("Creando label: ", this.label);
        gen.addQuadruple("LABEL", this.label, null, null, null);
        // return listLabels.get(this.label.toLowerCase())
    }

    buildCST(parent, cst) {
        return null;
    }

    getText(){
        return this.label;
    }
}