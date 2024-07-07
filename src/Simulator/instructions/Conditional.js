class Conditional extends Instruction {
    constructor(line, column, inst, op1, op2, op3, op4, productionType) {
        super();
        this.line = line;
        this.column = column;
        this.inst = inst.trim().toLowerCase();
        this.op1 = op1;
        this.op2 = op2;
        this.op3 = op3;
        this.op4 = op4;
        this.productionType = productionType;
    }

    execute(ast, env, gen) {
        gen.addQuadruple(this.inst, this.op4, this.op2 != null ? this.op2.text : null, this.op3 != null ? this.op3.text : null,  this.op1 != null ? this.op1.text : null);
        if(this.inst === 'csel') this.csel(ast, env, gen);
        else if(this.inst === 'cset') this.cset(ast, env, gen);
        else if(this.inst === 'cneg') this.cneg(ast, env, gen);
        else if(this.inst === 'cinv') this.cinv(ast, env, gen);
        else if(this.inst === 'cinc') this.cinc(ast, env, gen);
        else if(this.inst === 'csneg') this.csneg(ast, env, gen);
        else if(this.inst === 'csinv') this.csinv(ast, env, gen);
        else if(this.inst === 'csinc') this.csinc(ast, env, gen);
    }

    csel(ast, env, gen){
        if(this.evaluateConditionals()){
            let rn = ast.registers.getRegister(this.op2.dir);

            ast?.registers?.setRegister(this.op1.dir, rn);
        }else{
            let rn = ast.registers.getRegister(this.op3.dir);

            ast?.registers?.setRegister(this.op1.dir, rn);
        }
    }

    cset(ast, env, gen){
        if(this.evaluateConditionals()){
            ast?.registers?.setRegister(this.op1.dir, 1);
        }else{
            ast?.registers?.setRegister(this.op1.dir, 0);
        }
    }

    cneg(ast, env, gen){
        if(this.evaluateConditionals()){
            let rn = ast.registers.getRegister(this.op2.dir);
            rn.value = -rn.value;
            ast?.registers?.setRegister(this.op1.dir, rn);
        }else{
            let rn = ast.registers.getRegister(this.op3.dir);
            ast?.registers?.setRegister(this.op1.dir, rn);
        }
    }

    cinv(ast, env, gen){
        if(this.evaluateConditionals()){
            let rn = ast.registers.getRegister(this.op2.dir);
            rn.value = ~rn.value;
            ast?.registers?.setRegister(this.op1.dir, rn);
        }else{
            let rn = ast.registers.getRegister(this.op3.dir);
            ast?.registers?.setRegister(this.op1.dir, rn);
        }
    }

    cinc(ast, env, gen){
        if(this.evaluateConditionals()){
            let rn = ast.registers.getRegister(this.op2.dir);
            rn.value = rn.value + 1;
            ast?.registers?.setRegister(this.op1.dir, rn);
        }else{
            let rn = ast.registers.getRegister(this.op3.dir);
            ast?.registers?.setRegister(this.op1.dir, rn);
        }
    }

    csneg(ast, env, gen){
        if(this.evaluateConditionals()){
            let rn = ast.registers.getRegister(this.op2.dir);

            ast?.registers?.setRegister(this.op1.dir, rn);
        }else{
            let rn = ast.registers.getRegister(this.op3.dir);
            rn.value = -rn.value;
            ast?.registers?.setRegister(this.op1.dir, rn);
        }
    }

    csinv(ast, env, gen){
        if(this.evaluateConditionals()){
            let rn = ast.registers.getRegister(this.op2.dir);
            ast?.registers?.setRegister(this.op1.dir, rn);
        }else{
            let rn = ast.registers.getRegister(this.op3.dir);
            rn.value = ~rn.value;
            ast?.registers?.setRegister(this.op1.dir, rn);
        }
    }

    csinc(ast, env, gen){
        if(this.evaluateConditionals()){
            let rn = ast.registers.getRegister(this.op2.dir);
            ast?.registers?.setRegister(this.op1.dir, rn);
        }else{
            let rn = ast.registers.getRegister(this.op3.dir);
            rn.value = rn.value + 1;
            ast?.registers?.setRegister(this.op1.dir, rn);
        }
    }

    evaluateConditionals(){
        let type = this.op4.trim().toLowerCase();
        if(type === 'eq'){
            return flags.Z === 1;
        }else if(type === 'ne'){
            return flags.Z === 0;
        }else if(type === 'gt'){
            return (flags.Z === 0) && (flags.N === flags.V);
        }else if(type === 'lt'){
            return flags.N !== flags.V;
        }else if(type === 'ge'){
            return flags.N === flags.V;
        }else if(type === 'le'){
            return (flags.Z === 1) || (flags.N !== flags.V);
        }else if(type === 'al'){
            return true;
        }else if(type === 'cs'){
            return flags.C === 1;
        }else if(type === 'cc'){
            return flags.C === 0;
        }else if(type === 'mi'){
            return flags.N === 1;
        }else if(type === 'pl'){
            return flags.N === 0;
        }else if(type === 'vs'){
            return flags.V === 1;
        }else if(type === 'vc'){
            return flags.V === 0;
        }else if(type === 'hi'){
            return (flags.C === 1) && (flags.Z === 0);
        }else if(type === 'ls'){
            return (flags.C === 0) || (flags.Z === 1);
        }
        return false
    }

    buildCST(parent, cst) {

        let titleId = cst.newId();
        cst.addNode(titleId, "Conditional Instruction");
        cst.addEdge(parent, titleId);

        let typeId = cst.newId();
        cst.addNode(typeId, this.inst);
        cst.addEdge(titleId, typeId);

        this.op1.buildCST(titleId, cst);

        if (this.op2) {
            this.op2.buildCST(titleId, cst);
        }

        if (this.op3) {
            this.op2.buildCST(titleId, cst);
        }

        let numericalRegister4 = cst.newId();
        cst.addNode(numericalRegister4, "Conditional Code");
        cst.addEdge(titleId, numericalRegister4);

        let op4Id = cst.newId();
        cst.addNode(op4Id, this.op4);
        cst.addEdge(numericalRegister4, op4Id);
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
        if(op4 != null){
            if(op4 instanceof Register){
                text += ", " + op4.dir
            }else{
                text += ", " + op4.execute().value;
            }
        }
        return text
    }
}