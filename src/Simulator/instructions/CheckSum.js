class CheckSum extends Instruction {
    constructor(line, column, type, op1, op2, op3) {
        super();
        this.line = line;
        this.column = column;
        this.type = type;
        this.op1 = op1;
        this.op2 = op2;
        this.op3 = op3;
    }

    execute(ast, env, gen) {
        gen.addQuadruple(this.type, this.op2, this.op3, null, this.op1);
    }

    buildCST(parent, cst) {
        let titleId = cst.newId();
        cst.addNode(titleId, "Checksum Instruction");
        cst.addEdge(parent, titleId);

        let typeId = cst.newId();
        cst.addNode(typeId, this.type);
        cst.addEdge(titleId, typeId);

        this.op1.buildCST(titleId, cst);

        this.op2.buildCST(titleId, cst);

        this.op3.buildCST(titleId, cst);
    }
}