class VarAccess extends Expression {
    constructor(line, col, id) {
        super();
        this.line = line;
        this.col = col;
        this.tipo;
        this.id = id;
        this.value;
        this.text = id;
    }

    execute(ast, env, gen) {
        let symbol = env.getVariable(this.id);
        if (symbol == null) {
            throw new Exception(this.line, this.col, "Semantical", "Variable " + this.id + " not declared");
        }
        this.tipo = symbol.type;
        this.value = symbol.value;
        // return this.value;
        return { value: this.value, type: this.tipo }
    }

    buildCST(parent, cst) {
        let varAccess = cst.newId();
        cst.addNode(varAccess, "Var Access");
        cst.addEdge(parent, varAccess);

        let resId = cst.newId();
        cst.addNode(resId, this.id);
        cst.addEdge(varAccess, resId);
    }
}