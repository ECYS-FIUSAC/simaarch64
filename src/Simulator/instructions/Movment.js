class Movment extends Instruction {
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
        let temp = null;
        let opera2 = null
        if(this.op2 instanceof Register) opera2 = this.op2.dir
        else if(this.op2 instanceof Inmediate) opera2 = this.op2.execute(ast, env, gen).value
        if(opera2 === 0){
            opera2 = opera2.toString()
        }
        // console.log(opera2, this.op3)
        // console.log(this.op1, this.op2, this.op3)
        if (this.op3 != null) {
            temp = gen.newTemp();
            gen.addQuadruple(this.op3.type, this.op1.dir, opera2, this.op3.op3.dir, temp);
        }
        gen.addQuadruple(this.type, temp != null ? temp : opera2, temp != null ? null : this.op3, null, this.op1.dir);
        let newValue = null;
        // Validar tipo de valor
        if(this.op2 instanceof Expression) newValue = this.value?.execute(ast, env, gen);
        // console.log(this.op1, newValue, this.op2)
        if (this.op2 instanceof Registers && this.op1.size != this.op2.size) {
            ast.setNewError({ msg: `Los registros de la operación de movimiento no tienen el mismo tamaño.`, line: this.line, col: this.col });
            // console.log("Error en tamaño de registros")mov x2, 2
            return null;
        }else if(this.op2 instanceof Inmediate && this.op1.size === 64) {
            // console.log("--->")
            switch(this.op2.type) {
                case 'integer':
                    // console.log(this.op2.value)
                    if(this.op2.value > 18446744073709551615) ast.registers.setRegister(this.op2.dir, 0)
                    // console.log(this.op2.execute())
                    ast.registers.setRegister(this.op1.dir, this.op2.execute())
                    break;
                case 'hexadecimal':
                    if(this.op2.value.length > 18)
                        ast.registers.setRegister(this.op2.dir, str.substring(0, 18))
                    break;
                case 'binary':
                        ast.registers.setRegister(this.op1.dir, this.op2.execute())
                    break;
                case 'octal':
                    if(this.op2.value.length > 24)
                        ast.registers.setRegister(this.op2.dir, str.substring(0, 24))
                    break;
                case 'character':
                        ast.registers.setRegister(this.op1.dir, this.op2.execute())
                    break;
            }
        }else if(this.op2 instanceof Inmediate && this.op2.size === 32) {
            switch(this.op2.type) {
                case 'integer':
                    if(this.op2.value > 4294967295)
                        ast.registers.setRegister(this.op2.dir, 0)
                    break;
                case 'hexadecimal':
                    if(this.op2.value.length > 10)
                        ast.registers.setRegister(this.op2.dir, str.substring(0, 18))
                    break;
                case 'binary':
                    if(this.op2.value.length > 34)
                        ast.registers.setRegister(this.op2.dir, str.substring(0, 34))
                    break;
                case 'octal':
                    if(this.op2.value.length > 13)
                        ast.registers.setRegister(this.op2.dir, str.substring(0,13))
                    break;
            }
        }else if (this.op2 instanceof Register){
            ast.registers.setRegister(this.op1.dir, this.op2.execute(ast))
        }else return null;
        // Validaciones
    }

    buildCST(parent, cst) {

        let titleId = cst.newId();
        cst.addNode(titleId, "Move Instruction");
        cst.addEdge(parent, titleId);

        let typeId = cst.newId();
        cst.addNode(typeId, this.type);
        cst.addEdge(titleId, typeId);

        this.op1.buildCST(titleId, cst);

        this.op2.buildCST(titleId, cst);
        if (this.op3!=null) {
            this.op3.buildCST(titleId,cst)
        }
    }

    getText(){
        let inst = this.type
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