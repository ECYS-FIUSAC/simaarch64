class SymbolTab{
    n;
    constructor(line, column, id, typeId, type, env){
        this.line = line
        this.column = column
        this.id = id
        this.typeId = typeId
        this.type = type
        this.env = env
    }
}