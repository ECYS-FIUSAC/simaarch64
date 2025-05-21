class Register{
    
    constructor(line, col, dir, type) {
        // super();
        this.line = line;
        this.col = col;
        this.dir = dir;
        this.size = 64;
        this.value = 1
        this.type = type;
        this.text = dir
    }
    execute(ast, env, gen) {
        if(this.dir === "SP"){
            return {value: spMemory.getSP(), type: Type.SPMEM}
        }

        this.value = ast.registers?.getRegister(this.dir);
        // return this.value
        return {value: this.value?.value, type: this.value.type}
    }

    buildCST(parent, cst) {
        let reg = cst.newId();
        cst.addNode(reg, "Register");
        cst.addEdge(parent, reg);

        let resId = cst.newId();
        cst.addNode(resId, this.dir);
        cst.addEdge(reg, resId);
    }
}