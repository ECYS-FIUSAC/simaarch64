class Inmediate extends Expression{
    constructor(line, col, value, type) {
        super();
        this.line = line;
        this.col = col;
        this.value = value;
        if(value.startsWith('#')){
            this.value = value.substring(1)
        } 
        // console.log(type)
        this.type = type
        this.text = value
    }
    
    execute(ast, env, gen) {
        // return this.value;Type
        // console.log(this.type, this.value)
        if(this.type === 'integer') return {value: parseInt(this.value), type: this.type}
        else if(this.type === 'float') return {value: parseFloat(this.value), type: this.type}
        else if(this.type === 'string'){
            this.value = this.value.replace(/\\n/g, '\n')
                this.value = this.value.replace(/\\t/g, '\t')
                this.value = this.value.replace(/\\r/g, '\r')
                this.value = this.value.replace(/\\"/g, '\"')
                this.value = this.value.replace(/\\'/g, '\'')
                this.value = this.value.replace(/\\\\/g, '\\')
                return { value: this.value, type: this.type }
        }
        else if(this.type==='binary'){
            let temp = this.value.trim().substring(2);
            let num = parseInt(temp, 2)
            return {value: num, type: this.type}
        }else if(this.type === 'octal'){
            let num = parseInt(this.value, 8)
            return {value: num, type: this.type}
        }else if(this.type === 'hexadecimal'){
            let num = parseInt(this.value, 16)
            return {value: num, type: this.type}
        }else if(this.type === 'character'){
            let num = this.value
            num = num.charCodeAt(0)
            return {value: num, type: this.type}
        }
        return {value: this.value, type: this.type}
    }

    buildCST(parent, cst) {
        let inmediate = cst.newId();
        cst.addNode(inmediate, "Inmediate");
        cst.addEdge(parent, inmediate);

        let resId = cst.newId();
        cst.addNode(resId, this.value);
        cst.addEdge(inmediate, resId);
    }
    
}