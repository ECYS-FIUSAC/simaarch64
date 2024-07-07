class SystemCall extends Instruction {


    constructor(line, col, text, id) {
        super();
        this.line = line;
        this.col = col;
        this.text = text;
        this.id = id;
    }
    execute(ast, env, gen) {
        // Obteniendo parámetros de la llamada
        let regtemp0 = ast?.registers?.getRegister('x0');
        if(regtemp0 === null) return
        // Comprobando acción a realizar
        if (regtemp0.value === 0) this.stdin(ast, env, gen);  // Se maneja una salida del sistema
        if (regtemp0.value === 1) this.stdout(ast, env, gen);  // Se maneja una salida del sistema
        if (regtemp0.value === 2) this.stderr(ast, env, gen);  // Se maneja una salida del sistema
    }

    stdin(ast, env, gen) { // Entrada estándar
        // ToDo:
    }

    stdout(ast, env, gen) { // Salida estándar 
        let regtemp8 = ast?.registers?.getRegister('x8');
        // Validar número de llamada al sistema
        if (regtemp8.value === 64) { // write
            // let msg = ast?.registers?.getRegister('x1');
            
        }
        if (regtemp8.value === 93) { // end
            return;
        }
    }

    stderr(ast, env, gen) { // Salida de errores estándar
        // ToDo:
    }


    buildCST(parent, cst) {
        let globalId = cst.newId();
        cst.addNode(globalId, this.text);
        cst.addEdge(parent, globalId);

        let preNode = cst.newId();
        cst.addNode(preNode,"Identifier");
        cst.addEdge(parent, preNode);

        let typeId = cst.newId();
        cst.addNode(typeId, this.id);
        cst.addEdge(preNode, typeId);

    }

    getText(){
        return this.text;
    }
}