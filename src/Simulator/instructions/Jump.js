class Jump extends Instruction {
    constructor(line, column, type, op2, op3, id, productionType) {
        super();
        this.line = line;
        this.column = column;
        this.type = type.trim().toLowerCase();
        this.op2 = op2;
        this.op3 = op3;
        this.id = id;
        this.productionType = productionType;
    }

    execute(ast, env, gen) {
        let op2 = null
        if (this.op2 instanceof Register) {
            op2 = this.op2.text
        }else if (typeof this.op2 === 'string') {
            op2 = this.op2.trim()
        }
        gen.addQuadruple(this.type, op2, null, null, this.id);
        if (this.type === "b") return this.b(ast, env, gen);
        if (this.type === "bl") return this.b(ast, env, gen);
        else if(this.type === "ret") return this.ret(ast, env, gen);
        else if(this.type === "cbz") return this.cbz(ast, env, gen);
        else if(this.type === "cbnz") return this.cbnz(ast, env, gen);
        else{
            this.op2 = this.op2.trim()
            if(this.evaluateConditionals()){
                let index = listLabels.get(this.op2.toLowerCase());
                if(index === undefined){
                    ast.setNewError({ msg: `No se encontro la etiqueta ${this.op2}`, line: this.line, col: this.col, type: "semantico"});
                    return null
                }
                return index
            }
            return null
        }
    }

    b(ast, env, gen) {
        this.op2 = this.op2.trim()
        let index = listLabels.get(this.op2.toLowerCase());
        if(index === undefined){
                ast.setNewError({ msg: `No se encontro la etiqueta ${this.op2}`, line: this.line, col: this.column, type: "semantico"});
                return null
        }
        return index
    }

    ret(ast, env, gen){
        // this.op2 = this.op2.trim()
        let index = ast.registers.getRegister("x30").value;
        return index
    }

    cbz(ast, env, gen){
        let index = listLabels.get(this.id.trim().toLowerCase());
        if(index === undefined){
            ast.setNewError({ msg: `No se encontro la etiqueta ${this.id}`, line: this.line, col: this.column, type: "semantico"});
            return null
        }
        let register = ast.registers.getRegister(this.op2.dir);
        if(register.value === 0){
            return index
        }
        return null
    }

    cbnz(ast, env, gen){
        let index = listLabels.get(this.id.toLowerCase());
        if(index === undefined){
            ast.setNewError({ msg: `No se encontro la etiqueta ${this.id}`, line: this.line, col: this.column, type: "semantico"});
            return null
        }
        let register = ast.registers.getRegister(this.op2);
        if(register.value !== 0){
            return index
        }
        return null
    }

    evaluateConditionals(){
        let type = this.type.substring(1).trim().toLowerCase();
        // console.log(type)
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
        cst.addNode(titleId, "Branch Instruction");
        cst.addEdge(parent, titleId);

        let typeId = cst.newId();
        cst.addNode(typeId, this.type);
        cst.addEdge(titleId, typeId);

        if (this.op2 instanceof Register) {
            this.op2.buildCST(titleId, cst);
        } else {
            let preNode = cst.newId();
            cst.addNode(preNode, "Identifier");
            cst.addEdge(titleId, preNode);

            let op2Id = cst.newId();
            cst.addNode(op2Id, this.op2);
            cst.addEdge(preNode, op2Id)
        }

        if (this.op3) {
            this.op3.buildCST(titleId, cst);
        }

        if (this.id) {
            let preNode2 = cst.newId();
            cst.addNode(preNode2, "Identifier");
            cst.addEdge(titleId, preNode2);

            let idId = cst.newId();
            cst.addNode(idId, this.id);
            cst.addEdge(preNode2, idId);
        }
    }

    getText(){
        let inst = this.type;
        let text = inst
        let op2 = this.op2
        let op3 = this.op3
        let id = this.id
        if(op2 != null){
            text += " " + op2;
        }
        if(op3 != null){
            text += ", " + op3;
        }
        if(id != null){
            text += ", " + id;
        }
        return text
    }
}