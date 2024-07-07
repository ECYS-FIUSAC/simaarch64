class Atomic extends Instruction {
    constructor(line, column, type, op1, op2, op3, op4, op5) {
        super();
        this.line = line;
        this.column = column;
        this.type = type;
        this.op1 = op1;
        this.op2 = op2;
        this.op3 = op3;
        this.op4 = op4;
        this.op5 = op5;
    }

    execute(ast, env, gen) {
        gen.addQuadruple(this.type, this.op2 != null ? this.op2.text : null, this.op3 != null ? this.op3.text : null, this.op4 != null ? this.op4.text : null, this.op1.text);
    }

    buildCST(parent, cst) {

        let titleId = cst.newId();
        cst.addNode(titleId, "Atomic");
        cst.addEdge(parent, titleId);

        let typeId = cst.newId();
        cst.addNode(typeId, this.type);
        cst.addEdge(titleId, typeId);

        this.op1.buildCST(titleId, cst);

        if (this.op2) {
            this.op2.buildCST(titleId, cst);
        }

        if (this.op3) {
            this.op3.buildCST(titleId, cst);
        }

        if (this.op4) {
            this.op4.buildCST(titleId, cst);
        }


        let memryop = cst.newId();
        cst.addNode(memryop, "Memory Operand");
        cst.addEdge(titleId, memryop);

        this.op5.buildCST(memryop, cst);

    }
}