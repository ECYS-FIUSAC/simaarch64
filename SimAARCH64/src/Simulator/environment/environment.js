class Environment {

    constructor(prev,name){
        this.prev = prev
        this.name = name
        this.ids = {}
    }

    saveID(line, col, id, type, value){
        let env = this
        console.log("Creando id:> ", id)
        if(env.ids[id]){
            this.setErrors(line, col, `La variable ${id} ya ha sido declarada`)
            return
        }
        env.ids[id] = new Symbol(value,id, type)
        symbolTable.push(line, col, id.toLowerCase(), 'Variable', type , env.name);
        console.log(symbolTable)
        console.log(env.ids)
    }

    getValue(id){
        id = id.toLowerCase()
        let env = this
        while(env){
            if(env.ids[id]){
                return env.ids[id].toLowerCase()
            }
            env = env.prev
        }
        return null
    }

    setErrors(line,column, description){
        if(this.matchError(line,column+1, TypeErrors.SEMANTIC)) return
        errors.push(new Error(line, column, TypeErrors.SEMANTIC, description))
    }

    matchError(line,column, err){
        for(const s of errors){
            return s.line === line && s.column === column && s.descxription === err
        }
        return false
    }
}