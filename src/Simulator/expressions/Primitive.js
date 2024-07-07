class Primitive extends Expression{
    constructor(line, col, value, type) {
        super();
        this.line = line;
        this.col = col;
        this.value = value;
        this.type = type;
    }

    execute(ast, env, gen) {
        if(this.type === 'integer') return {value: parseInt(this.value), type: this.type}
        return {value: this.value, type: this.type}
    }

    buildCST(parent, cst) {
        return null;
    }
}