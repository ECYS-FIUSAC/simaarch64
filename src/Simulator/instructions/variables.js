class Variable extends Instruction {
    constructor(line, col, type, id, value) {
        super();
        this.line = line;
        this.col = col;
        this.type = type;
        this.id = id;
        this.value = value;
    }
    execute(ast, env, gen) {
        // console.log(this.value, this.type)
        // console.log("Creando id: ", this.id);
        gen.addQuadruple("=", this.value.execute(ast, env, gen).value, null, null, this.id);
        // console.log("Variable creada: ", this.value);
        let valorFinal = this.value.execute(ast, env, gen);
        if (valorFinal == null) throw new Exception(this.line, this.col, "Semantical", "Variable " + this.id + " not declared");


        // console.log("TIPO", this.type)
        if (this.type == "skip" || this.type == "space" || this.type == "zero") {
            memory.defineBSSVariable(this.id, valorFinal.value)
        }else{
            memory.defineVariable(this.id, valorFinal.value, this.id, valorFinal.type)
        }
    }

    buildCST(parent, cst) {

        let titleId = cst.newId();
        cst.addNode(titleId, "Variable Declaration");
        cst.addEdge(parent, titleId);

        let variableId = cst.newId();
        cst.addNode(variableId,"Identifier");
        cst.addEdge(titleId, variableId);

        let variableIde = cst.newId();
        cst.addNode(variableIde, this.id);
        cst.addEdge(variableId, variableIde);

        let colon = cst.newId();
        cst.addNode(colon, ":");
        cst.addEdge(titleId, colon);

        let numericalRegister1 = cst.newId();
        cst.addNode(numericalRegister1, "Variable type");
        cst.addEdge(titleId, numericalRegister1);

        let tipoId = cst.newId();
        cst.addNode(tipoId, this.type);
        cst.addEdge(numericalRegister1, tipoId);

        let preNode = cst.newId();
        cst.addNode(preNode, "Value");
        cst.addEdge(titleId, preNode);

        let valueId = cst.newId();
        cst.addNode(valueId, this.value.value);
        cst.addEdge(preNode, valueId);
    }

    getText(){
        let inst = this.type;
        let text = inst
        let id = this.id
        let value = this.value
        if(id != null){
            text += " " + id;
        }
        if(value != null){
            text += " " + value;
        }
        return
    }
}