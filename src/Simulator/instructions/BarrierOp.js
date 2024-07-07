class BarrierOp extends Instruction{
    constructor(line, column, type, op1, op2, op3, op4){
        super();
        this.line = line;
        this.column = column;
        this.type = type;
        this.op1 = op1;
        this.op2 = op2;
        this.op3 = op3;
        this.op4 = op4;
    }

    execute(ast, env, gen){
        gen.addQuadruple(this.type, this.op2, this.op3, this.op4, this.op1);
    }

    buildCST(parent, cst) {
        return null;
    }
}