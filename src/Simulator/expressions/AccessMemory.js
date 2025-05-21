class AccessMemory extends Expression {
    constructor(line, column, op1, op2, op3, op4 = null, symbol=null, offsetType=true) {
        super();
        this.line = line;
        this.column = column;
        this.op1 = op1;
        this.op2 = op2;
        this.op4 = op4;  
        this.op3 = op3;
        this.symbol = symbol;
        this.offsetType = offsetType;
        this.text = null
    }

    execute(ast, env, gen) {
        this.text = gen.lastTemp;
        if(this.symbol == "=") return this.getMemoryDirection(ast, env, gen);
        if(this.symbol == "!") return this.offsetUpdate(ast, env, gen);
        const op = gen.quadruples[gen.quadruples.length - 1].op;
        //console.log(ast.registers.getRegister(this.op1[0]))

        // faltan todos los store
        if (op === "str")
            return ast.registers.getRegister(this.op1[0]);
        // faltan todos los load
        else 
            return this.getMemoryValue(ast, env, gen);
    }

    getMemoryDirection(ast, env, gen){
        let addr = memory.getVariableAddress(this.op1)
        return {value: addr, type: Type.MEMORY}
    }

    offsetUpdate(ast, env, gen){
    
    }

    getMemoryValue(ast, env, gen){
        // console.log("Getting memory value")
        if(this.op1[0].toUpperCase() === "SP"){
            if(this.op2 != null){
                let offset = this.op2.execute(ast, env, gen);
                return BigInt(offset.value)
            }
            return 0n
        }

        let rt = ast.registers.getRegister(this.op1[0]);
        if(rt.type != Type.MEMORY) throw new Error("Variable no es de tipo memoria")
            if(this.op2 != null){
                let offset = this.op2.execute(ast, env, gen);
                // console.log(offset)
                return {value:memory.loadWord(rt.value + memory.calculateOffset(ast, rt.value, 'immediate', offset.value, 1, false)),type:'integer'};
            }
            // console.log("reg:",rt.value,"value:",memory.loadWord(rt.value),"type:",'integer');
            return {value:memory.loadWord(rt.value),type:'integer'};
    }

    buildCST(parent, cst) {
        let op1 = this.op1 instanceof Array ? this.op1[0] : this.op1;
        op1 = `[${op1}]`
        let memoryOp = cst.newId();
        cst.addNode(memoryOp, "Memory Access");
        cst.addEdge(parent, memoryOp);

        let resId = cst.newId();
        cst.addNode(resId, op1);
        cst.addEdge(memoryOp, resId);
        if (this.op2) {
            this.op2.buildCST(memoryOp, cst);
        }
        if (this.op3) {
            this.op3.buildCST(memoryOp, cst);
        }
        if (this.op4) {
            this.op4.buildCST(memoryOp, cst);
        }
    }

    getText(){
        if(this.symbol==="="){
            return " =" + this.op1;
        }else{
            let operator1 = this.op1[0]
            if(this.op1[0].toUpperCase()==="SP"){
                operator1 = "SP"
            }
            if(this.op2 != null){
                let offset = this.op2.execute();
                // console.log(offset)
                return "[" + operator1 + " , " + offset.value + "]";
            }
            return "[" + operator1 + "]";
        }
    }
        
}
