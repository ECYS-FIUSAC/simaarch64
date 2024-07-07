class Logical extends Instruction {
    constructor(line, column, inst, op1, op2, op3) {
        super();
        this.line = line;
        this.column = column;
        this.inst = inst.trim();
        this.op1 = op1;
        this.op2 = op2;
        this.op3 = op3;
    }

    execute(ast, env, gen) {       
        let op_2 = null

        if(this.op3 instanceof Register){
            op_2 = this.op3.dir
        }else{
            op_2 = this.op3.execute(ast).value
        }

        gen.addQuadruple(this.inst, this.op2.dir, op_2, null, this.op1.dir);
        if (this.inst === "ands") this.and(ast,false, true);
        else if(this.inst === "and") this.and(ast);
        else if(this.inst === "eon") this.eon(ast,true);
        else if(this.inst === "eor") this.eon(ast);
        else if(this.inst === "orn") this.orn(ast,true);
        else if(this.inst === "orr") this.orn(ast);
        else if(this.inst === "tst") this.and(ast, true)
    }

    and(ast, test = false, flags = false) {
        let rd = ast.registers.getRegister(this.op1.dir);
        let rn = ast.registers.getRegister(this.op2.dir);

        let op2_ = null
        if(this.op3 instanceof Inmediate){
            op2_ = this.op3.execute(ast)
        }else{
            op2_ = ast.registers.getRegister(this.op3.dir);
        }
        let valueResult = 0
        valueResult = rn.value & op2_.value;
        // console.log(valueResult,rd, rn)
        if(!test) {
            let res = {value: valueResult, type: Type.INT}
            ast.registers.setRegister(this.op1.dir, res);
        }
        if(flags) updateFlags(valueResult, rn.value, op2_.value, this.inst)

    }

    eon(ast, negate = false) {
        let rd = ast.registers.getRegister(this.op1.dir);
        let rn = ast.registers.getRegister(this.op2.dir);

        let op2_ = null
        if(this.op3 instanceof Inmediate){
            op2_ = this.op3.execute(ast)
        }else{
            op2_ = ast.registers.getRegister(this.op3.dir);
        }
        let valueResult = 0
        if (negate) op2_.value = ~op2_.value;
        // ^ is the XOR operator
        valueResult = rn.value ^ op2_.value;

        let res = {value: valueResult, type: Type.BIN}
        ast.registers.setRegister(this.op1.dir, res);

    }

    orn(ast, negate = false) {
        let rd = ast.registers.getRegister(this.op1.dir);
        let rn = ast.registers.getRegister(this.op2.dir);

        let op2_ = null
        if(this.op3 instanceof Inmediate){
            op2_ = this.op3.execute(ast)
        }else{
            op2_ = ast.registers.getRegister(this.op3.dir);
        }
        let valueResult = 0
        if (negate) op2_.value = ~op2_.value;
        // | is the OR operator
        valueResult = rn.value | op2_.value;

        let res = {value: valueResult, type: Type.BIN}
        ast.registers.setRegister(this.op1.dir, res);
    }

    buildCST(parent, cst) {

        let titleId = cst.newId();
        cst.addNode(titleId, "Logical");
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
    }

    getText(){
        let inst = this.inst;
        let text = inst
        let op1 = this.op1
        let op2 = this.op2
        let op3 = this.op3
        if(op1 != null){
            if(op1 instanceof Register){
                text += " " + op1.dir
            }else{
                text += " " + op1.execute().value;
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
        return text;
    }
}