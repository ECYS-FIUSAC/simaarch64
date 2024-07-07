class Operation extends Expression {

    constructor(line, col, inst, op1, op2, op3, res, productionType) {
        super();
        this.line = line;
        this.col = col;
        this.inst = inst.trim().toLowerCase();
        this.op1 = op1;
        this.op2 = op2;
        this.op3 = op3;
        this.res = res;
        this.productionType = productionType;
    }

    execute(ast, env, gen) {
        // console.log("Operation", this.inst, this.op1, this.op2, this.op3, this.res)
        let operate2 = null
        let operate1 = null
        let operate3 = null
        if(this.op2 instanceof Inmediate){
            operate2 = this.op2.execute(ast, env, gen).value
        }else{
            operate2 = this.op2.dir
        }
        if(this.op1 instanceof Inmediate){
            operate1 = this.op1.execute(ast, env, gen).value
        }else{
            operate1 = this.op1.dir
        }
        if(this.op3 instanceof Inmediate){
            operate3 = this.op3.execute(ast, env, gen).value
        }else{
            if(this.op3 != null) operate3 = this.op3.dir
            // operate3 = this.op3
        }
        gen.addQuadruple(this.inst, operate1, operate2, operate3, this.res!=null ? this.res.dir : null);
        if(this.inst === "add" || this.inst === "addc") this.plus(ast,false)
        else if(this.inst === "adc" || this.inst === "adcs") this.plus(ast, false)
        else if(this.inst === "adr") this.getMemry(ast)
        else if(this.inst === "adrp") this.getMemry(ast, true)
        else if(this.inst === "cmp") this.compare(ast)
        else if(this.inst === "cmn") this.compare(ast, true)
        else if(this.inst === "madd") this.multiplyPlus(ast)
        else if(this.inst === "mneg") this.multiplySubstract(ast)
        else if(this.inst === "msub") this.multiplySubstract(ast,true)  
        else if(this.inst === "mul") this.multiply(ast)
        else if(this.inst === "neg" || this.inst === "negs") this.negate(ast)
        else if(this.inst === "ngc" || this.inst === "negcs") this.negate(ast, true)
        else if(this.inst === "sbc") this.minus(ast, true)
        else if(this.inst === "sdiv") this.divide(ast)
        else if(this.inst === "smull") this.multiply(ast)
        else if(this.inst === "smulh") this.multiply(ast)
        else if(this.inst === "sub" || this.inst === "subs") this.minus(ast)
        else if(this.inst === "udiv") this.divideU(ast)
        else if(this.inst === "umaddl") this.multiplyPlus(ast)
        else if(this.inst === "umnegl") this.multiplySubstract(ast)
        else if(this.inst === "umsubl") this.multiplySubstract(ast,true)
        else if(this.inst === "umulh") this.multiply(ast)
        else if(this.inst === "umull") this.multiply(ast)
    }

    plus(ast, carry = false){
        if(this.op1.dir === "SP"){
            let op2_ = null  
            // console.log(this.op2.classname)      
            if(this.op2 instanceof Inmediate){
                op2_ = this.op2.execute(ast)
            }else{
                op2_ = ast?.registers?.getRegister(this.op2.dir);
            }
            spMemory.add(op2_.value)
            return
        }
        // // console.log(this.op1.dir, this.res.dir)
        // if(!(this.op1.dir.startsWith("x") && this.res.dir.startsWith("x"))){
        //     // ast.setNewError({ msg: `No se puede sumar un registro consigo mismo.`, line: this.line, col: this.col, type: "semantico"});
        //     ast.setNewError({msg: 'No se pueden sumar registros de diferentes tamaños.', line: this.line, col: this.col, type: 'semantico'});
        //     return

        // }
        let rn = ast?.registers?.getRegister(this.op1.dir);
        let op2_ = null        
        if(this.op2 instanceof Inmediate){
            op2_ = this.op2.execute(ast)
        }else{
            op2_ = ast?.registers?.getRegister(this.op2.dir);
        }

        if(rn.type === Type.MEMORY){
            let valueResult = BigInt(rn.value) + BigInt(op2_.value);
            if(carry) valueResult += BigInt(flags.C)
            let returnValue = {value: valueResult, type: Type.MEMORY}
            ast?.registers?.setRegister(this.res.dir,returnValue);
            return
        }

        let valueResult = rn.value + op2_.value;
        if(carry) valueResult += flags.C
        valueResult = parseInt(valueResult)
        let returnValue = {value: valueResult, type: Type.INT}
        // console.log(rn)
        ast?.registers?.setRegister(this.res.dir,returnValue);
    }

    nearestAlignedTo16(number) {
        const lower = Math.floor(number / 16) * 16;
        const upper = Math.ceil(number / 16) * 16;
        
        if (number - lower < upper - number) {
            return Number(lower);
        } else {
            return Number(upper);
        }
    }

    minus(ast, carry = false){
        if(this.op1.dir === "SP"){
            let op2_ = null  
            // console.log(this.op2.classname)      
            if(this.op2 instanceof Inmediate){
                op2_ = this.op2.execute(ast)
            }else{
                op2_ = ast?.registers?.getRegister(this.op2.dir);
            }

            if(op2_.value % 16 !== 0){
                ast.setNewError({ msg: `El valor ${op2_.value} no es multiplo de 16.`, line: this.line, col: this.col, type: "semantico"});
                op2_.value = this.nearestAlignedTo16(op2_.value);
                // return
            }

            spMemory.sub(op2_.value)
            return
            // let valueR = {value: sp, type: Type.SPMEM}
            // ast?.registers?.setRegister(this.res.dir, valueR)
        }
        let rn = ast?.registers?.getRegister(this.op1.dir);
        let op2_ = null  
        // console.log(this.op2.classname)      
        if(this.op2 instanceof Inmediate){
            op2_ = this.op2.execute(ast)
        }else{
            op2_ = ast?.registers?.getRegister(this.op2.dir);
        }
        if(rn.type === Type.MEMORY){
            let valueResult = BigInt(rn.value) - BigInt(op2_.value);
            if(carry) valueResult -= BigInt(flags.C)
            let returnValue = {value: valueResult, type: Type.MEMORY}
            ast?.registers?.setRegister(this.res.dir,returnValue);
            return
        }
        
        let valueResult = rn.value - op2_.value;
        if(carry) valueResult -= flags.C
        valueResult = parseInt(valueResult)
        let returnValue = {value: valueResult, type: Type.INT}
        // console.log(rn)
        ast?.registers?.setRegister(this.res.dir,returnValue);
    }

    multiply(ast){
        let rn = ast?.registers?.getRegister(this.op1.dir);
        let rm = ast?.registers?.getRegister(this.op2.dir);
        if(rn.type === Type.MEMORY){
            let valueResult = rn.value * BigInt(rm.value);
            let returnValue = {value: valueResult, type: Type.MEMORY}
            ast?.registers?.setRegister(this.res.dir,returnValue);
            return
        }
        // console.log(this.op1, this.op2)
        let valueResult = rn.value * rm.value;
        valueResult = parseInt(valueResult)
        let returnValue = {value: valueResult, type: Type.INT}
        ast?.registers?.setRegister(this.res.dir, returnValue);
    }

    divide(ast){
        let rn = ast?.registers?.getRegister(this.op1.dir);
        let rm = ast?.registers?.getRegister(this.op2.dir);

        if(rm.value === 0){
            // ast?.errors.push(new Error_(this.line, this.col, "Error Semantico", "Division por cero"))
            ast.setNewError({ msg: `No se puede dividir por 0.`, line: this.line, col: this.col, type: "semantico"});
            return
        }
        if(rn.type === Type.MEMORY){
            let valueResult = rn.value / BigInt(op2_.value);
            let returnValue = {value: valueResult, type: Type.MEMORY}
            ast?.registers?.setRegister(this.res.dir,returnValue);
            return
        }
        let valueResult = rn.value / rm.value;
        valueResult = parseInt(valueResult)
        let returnValue = {value: valueResult, type: Type.INT}
        ast?.registers?.setRegister(this.res.dir, returnValue);
    }

    divideU(ast){
        let rn = ast?.registers?.getRegister(this.op1.dir);
        let rm = ast?.registers?.getRegister(this.op2.dir);

        if(rm.value === 0){
            ast.setNewError({ msg: `No se puede dividir por 0.`, line: this.line, col: this.col, type: "semantico"});
            return
        }
        let op1 = Math.abs(rn.value)
        let op2 = Math.abs(rm.value)
        
        let valueResult = op1 / op2;
        valueResult = parseInt(valueResult)
        let returnValue = {value: valueResult, type: Type.INT}
        ast?.registers?.setRegister(this.res.dir, returnValue);
    }

    compare(ast, negate = false){
        let rn = ast?.registers?.getRegister(this.op1.dir);
        let op2_ = null
        if(this.op2 instanceof Inmediate){
            op2_ = this.op2.execute(ast)
        }else{
            op2_ = ast?.registers?.getRegister(this.op2.dir);
        }
        let valueResult = 0
        if(negate) {
            valueResult = rn.value + op2_.value;
        }else{
            valueResult = rn.value - op2_.value;
        }
        valueResult = parseInt(valueResult)
        updateFlags(valueResult, rn.value, op2_.value, this.inst.toUpperCase());
    }

    getMemry(ast, adr = false){
        // function to get the memory address
    }

    multiplyPlus(ast, negate = false){
        if(negate){
            return
        }
        let rd = ast?.registers?.getRegister(this.op1.dir);
        let rn = ast?.registers?.getRegister(this.op2.dir);
        let rm = ast?.registers?.getRegister(this.op3.dir);
        let ra = ast?.registers?.getRegister(this.op4.dir);

        let valueResult = ra.value + (rn.value * rm.value);
        valueResult = parseInt(valueResult)
        let returnValue = {value: valueResult, type: Type.INT}
        ast?.registers?.setRegister(rd.dir, returnValue);
    }

    multiplySubstract(ast, fullParams = false){
        let rd = ast?.registers?.getRegister(this.op1.dir);
        let rn = ast?.registers?.getRegister(this.op2.dir);
        

        if (fullParams){
            let ra = ast?.registers?.getRegister(this.op3.dir);
            let valueResult = ra.value - (rd.value * rn.value);
            valueResult = parseInt(valueResult)
            let returnValue = {value: valueResult, type: Type.INT}
            ast?.registers?.setRegister(this.res.dir, returnValue);
        }else{
            let valueResult = -rn.value * rm.value;
            valueResult = parseInt(valueResult)
            let returnValue = {value: valueResult, type: Type.INT}
            ast?.registers?.setRegister(this.res.dir, returnValue);
        }
    }

    negate(ast, carry=false){
        let rn = ast?.registers?.getRegister(this.op1.dir);
        let op_2 = 0
        if(this.op2 instanceof Inmediate){
            op2_ = this.op2.execute(ast)
        }else{
            op2_ = ast?.registers?.getRegister(this.op2.dir);
        }
        let valueResult = -rn.value;
        if(carry) valueResult -= flags.C * -1
        valueResult = parseInt(valueResult)
        let returnValue = {value: valueResult, type: Type.INT}
        ast?.registers?.setRegister(this.res.dir,returnValue)
    }

    buildCST(parent, cst) {
        let titleId = cst.newId();
        cst.addNode(titleId, "Arithmetic");
        cst.addEdge(parent, titleId);

        let opId = cst.newId();
        cst.addNode(opId, "Operation");
        cst.addEdge(titleId, opId);

        let instId = cst.newId();
        cst.addNode(instId, this.inst);
        cst.addEdge(opId, instId);

        if(this.res) {
            this.res.buildCST(titleId, cst);
        }

        this.op1.buildCST(titleId, cst);

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
        let res = this.res

        if(res != null){
            if(res instanceof Register){
                text += " " + res.dir
            }else{
                text += " " + res.execute().value;
            }
            // text += ", " + re3;
        }

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