class SymbolTable{
    symbolTable = [];

    push(line, column, id, typeId, type, env){
        let temp = new SymbolTab(line, column, id, typeId, type, env)
        if(this.validate(temp)){
            temp.n = this.symbolTable.length +1 
            this.symbolTable.push(temp)
        }
    }

    validate(value){
        return !this.symbolTable.some((symbol) => symbol.id === value.id && symbol.typeId === value.typeId && symbol.type===value.type && symbol.env === value.env)
    }

    get(){
        return this.symbolTable.map((symbol)=> symbol.toString().join("\n"))
    }

    getSymbolTable(){
        return this.symbolTable
    }

    splice(){
        this.symbolTable.splice(0)
    }
}

symbolTable = new SymbolTable()