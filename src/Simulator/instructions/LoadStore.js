class LoadStore extends Instruction {
    constructor(line, column, inst, op1, op2, op3, op4) {
        super();
        this.line = line;
        this.column = column;
        this.inst = inst.trim().toLowerCase();
        this.op1 = op1;
        this.op2 = op2;
        this.op3 = op3;
        this.op4 = op4;
    }

    async execute(ast, env, gen) {
        let isArray = false
        let temp = null
        if(this.op4.op1 instanceof Array){
            isArray = true
            temp = this.op4.op1[0] +" off " + this.op4.op1[1]
        }
        gen.addQuadruple(this.inst, this.op1!=null ? this.op1.dir : null, this.op2!=null ? this.op2.execute(ast,env, gen).value: null, this.op3!=null ? this.op3.execute(ast,env, gen).value: null, isArray ? temp : this.op4.op1);
        // console.log(this.inst, this.op1, this.op2, this.op3, this.op4)
        if(this.inst === "ldr"){
            if(this.op4.op1[0] === "SP"){
                let offset = this.op4.execute(ast, env, gen);
                spMemory.ldr(ast,this.op1.dir, offset );
                return;
            }else{
                ast?.registers?.setRegister(this.op1.dir, this.op4.execute(ast, env, gen));
            }
        }else if(this.inst === "ldrb"){
            let value = this.op4.execute(ast, env, gen);
            if(this.op4.op1[0] === "SP"){
                let offset = this.op4.execute(ast, env, gen);
                let memVal = spMemory.ldrb(offset);
                let resVal = {value: memVal, type: Type.INT}
                ast?.registers?.setRegister(this.op1.dir, resVal);
                return;
            }
            if(value < 1000){
                let val = {value: memory.loadByteBSS(value), type: Type.INT}
                ast?.registers?.setRegister(this.op1.dir, val);
                return;
            }
            let val = {value: memory.loadByte(value), type: Type.MEMORY}
            ast?.registers?.setRegister(this.op1.dir, val);
        }else if(this.inst === "strb"){
            let value = this.op4.execute(ast, env, gen);
            // console.log("test", value)
            if(this.op4.op1[0] === "SP"){
                let offset = this.op4.execute(ast, env, gen);
                spMemory.strb(offset, this.op1.execute(ast, env, gen).value);
                return;
            }
            if(value < 1000){
                // await memory.storeByteBSS(value, this.op1.execute(ast, env, gen).value);
                handlerStoreByte(value, this.op1.execute(ast, env, gen).value)
                // await handlerStoreByte(value, this.op1.execute(ast, env, gen).value)
                return;
            }
            memory.storeByte(value, this.op1.execute(ast, env, gen).value);
        }else if(this.inst === "str"){
            if(this.op4.op1[0]=== "SP"){
                spMemory.str(this.op1.execute(ast, env, gen).value, this.op4.execute(ast, env, gen));
            }
        }
    }

    buildCST(parent, cst) {

        let titleId = cst.newId();
        cst.addNode(titleId, "Load and Store Instruction");
        cst.addEdge(parent, titleId);

        let typeId = cst.newId();
        cst.addNode(typeId, this.inst);
        cst.addEdge(titleId, typeId);

        if (this.op1 === "PRFM") {
            this.op1.buildCST(titleId, cst);
        } else {
            let numericalRegister1 = cst.newId();
            cst.addNode(numericalRegister1, "PreFetch operation");
            cst.addEdge(titleId, numericalRegister1);

            this.op1.buildCST(numericalRegister1, cst);
        }

        if (this.op2) {
            this.op2.buildCST(titleId, cst);
        }

        if (this.op3) {
            this.op3.buildCST(titleId, cst);
        }

        if (this.op4) {
            let numericalRegister4 = cst.newId();
            cst.addNode(numericalRegister4, "Memory Operand");
            cst.addEdge(titleId, numericalRegister4);

            this.op4.buildCST(numericalRegister4, cst);
        }
    }

    getText(){
        let inst = this.inst;
        let text = inst
        let op1 = this.op1
        let op2 = this.op2
        let op3 = this.op3
        let op4 = this.op4

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
        if(op4 != null){
            if(op4 instanceof Register){
                text += ", " + op4.dir
            }else{
                text += ", " + op4.getText();
            }
        }
        return text
    }
}