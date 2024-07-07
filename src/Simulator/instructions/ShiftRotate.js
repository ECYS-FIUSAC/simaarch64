class ShiftRotate extends Instruction {
    constructor(line, column, inst, op1, op2, op3, productionType) {
        super();
        this.line = line;
        this.column = column;
        this.inst = inst.trim();
        this.op1 = op1;
        this.op2 = op2;
        this.op3 = op3;
        this.productionType = productionType;
    }

    execute(ast, env, gen) {
        gen.addQuadruple(this.inst, this.op2.dir, this.op3.execute(ast,env,gen).value, null, this.op1.dir);
        if(this.inst === "lsl") this.lsl(ast)
        else if(this.inst === "lsr") this.lsr(ast)
        else if(this.inst === "ror") this.ror(ast)
        else if(this.inst === "asr") this.asr(ast)
    }

    lsl(ast) {
        let rn = ast.registers.getRegister(this.op2.dir);

        let op2_ = null
        if(this.op3 instanceof Inmediate){
            op2_ = this.op3.execute(ast)
        }else{
            op2_ = ast.registers.getRegister(this.op3.dir);
        }
        let valueResult = 0
        valueResult = rn.value << op2_.value;
        let res = {value: valueResult, type: Type.INT}
        ast.registers.setRegister(this.op1.dir, res);
    }

    lsr(ast) {
        let rn = ast.registers.getRegister(this.op2.dir);

        let op2_ = null
        if(this.op3 instanceof Inmediate){
            op2_ = this.op3.execute(ast)
        }else{
            op2_ = ast.registers.getRegister(this.op3.dir);
        }
        let valueResult = 0
        valueResult = rn.value >>> op2_.value;
        let res = {value: valueResult, type: Type.INT}
        ast.registers.setRegister(this.op1.dir, res);
    }

    asr(ast) {
        let rn = ast.registers.getRegister(this.op2.dir);

        let op2_ = null
        if(this.op3 instanceof Inmediate){
            op2_ = this.op3.execute(ast)
        }else{
            op2_ = ast.registers.getRegister(this.op3.dir);
        }
        let valueResult = 0
        valueResult = rn.value >> op2_.value;
        let res = {value: valueResult, type: Type.INT}
        ast.registers.setRegister(this.op1.dir, res);
    }

    ror(ast) {
        let rn = ast.registers.getRegister(this.op2.dir);

        let op2_ = null
        if(this.op3 instanceof Inmediate){
            op2_ = this.op3.execute(ast)
        }else{
            op2_ = ast.registers.getRegister(this.op3.dir);
        }
        op2_.value = op2_.value % 63
        let valueResult = 0
        valueResult =  ((rn.value >>> op2_.value) | (rn.value << (32 - op2_.value))) >>> 0;
        let res = {value: valueResult, type: Type.INT}
        ast.registers.setRegister(this.op1.dir, res);
    }

    buildCST(parent, cst) {
        let titleId = cst.newId();
        cst.addNode(titleId, "Shift/Rotate Instruction");
        cst.addEdge(parent, titleId);

        let typeId = cst.newId();
        cst.addNode(typeId, this.inst);
        cst.addEdge(titleId, typeId);

        if (this.op1) {
            this.op1.buildCST(titleId, cst);
        }

        if (this.op2) {
            this.op2.buildCST(titleId, cst);
        }

        if (this.op3) {
            this.op3.buildCST(titleId, cst);
        }

    }
    getText(){
        let inst = this.inst
        let text = inst
        let op1 = this.op1
        let op2 = this.op2
        let op3 = this.op3
        if(op1 != null){
            if(op1 instanceof Register){
                text += ", " + op1.dir
            }else{
                text += ", " + op1.execute().value;
            }
        }
        if(op2 != null){
            if(op2 instanceof Register){
                text += ", " + op2.dir
            }else{
                text += ", " + op2.execute().value;
            }
        }
        if(op3 != null){
            if(op3 instanceof Register){
                text += ", " + op3.dir
            }else{
                text += ", " + op3.execute().value;
            }
        }
        return text
    }
}