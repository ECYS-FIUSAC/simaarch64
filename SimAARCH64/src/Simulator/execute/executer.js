let mode=null;
let main = []
const RootExecuter = async  (root, ast, env, gen) => {
    main.splice(0, main.length);
    memory.reset();
    mode = null;
    const instructions = root?.instructions ?? [];
    let index = 0
    instructions.forEach(inst => {
        if (inst === undefined) {
            index++;
            return;
        };
        if (inst instanceof Array) {
            inst.forEach(i => i.execute(ast, env, gen));
        } else {
            if(inst instanceof Section){
                inst.execute(ast, env, gen);
                mode = inst.name;
            }else{
                if(mode === ("bss" || "data")){
                    // console.log(inst)
                    inst.execute(ast, env, gen);
                }else{
                    if(inst instanceof Label){
                        listLabels.set(inst.label.toLowerCase(), index)
                    }
                    main.push(inst);
                    index++;
                }
            }
        }

    });

    let i = 0;
    let exit = false
    while(i < main.length){
        let inst = main[i];
        if(inst instanceof Jump){
            let index = inst.execute(ast, env, gen);
            if(inst.type === "bl"){
                ast.registers.setRegister("x30", {value: i, type: Type.INT });
            }
            if(index !== null){
                i = index;
            }
        }else{
            if(inst instanceof System){
                exit = await inst.execute(ast, env, gen);
            }else{
                await inst.execute(ast, env, gen);
            }
        }
        if(exit) break;
        i++;
    }

    // console.log(memory.getAllVariables());
}
let indexForDebug = 0;
let statesDebug = {
    "init": 0,
    "step": 1,
    "end": 2
}
let stateDebug = null;
let changeToInstructions = false;
const RootExecuterDebug = async (root, ast, env, gen, editor_deb) => {
    main.splice(0, main.length);
    memory.reset();
    mode = null;
    const instructions = root?.instructions ?? [];
    let index = 0;
    stateDebug = statesDebug.init;
    let idx = 0;

    instructions.forEach(inst => {
        if (inst === undefined) {
            // index++;
            return;
        };
        if (inst instanceof Array) {
            inst.forEach(i => i.execute(ast, env, gen));
        } else {
            if(inst instanceof Section){
                inst.execute(ast, env, gen);
                mode = inst.name;
            }else{
                if(mode === ("bss" || "data")){
                    // console.log(inst)
                    inst.execute(ast, env, gen);
                }else{
                    if(inst instanceof Label){
                        listLabels.set(inst.label.toLowerCase(), index)
                    }
                    main.push(inst);
                    index++;
                }
            }
        }

    });
    let i = 0;
    document.getElementById("show-instructions").value = "Iniciando el debug"
    document.getElementById("next-inst").addEventListener("click", nextInstruction);
    async function nextInstruction() {
        let exit = false;
        let inst = main[i];
        if(i >= main.length){
            endDebug(ast);
            stateDebug = statesDebug.end;
        }else{
            if(inst instanceof Jump){
                let index = inst.execute(ast, env, gen);
                if(inst.type === "bl"){
                    ast.registers.setRegister("x30", {value: i, type: Type.INT });
                }
                if(index !== null){
                    i = index;
                }
            } else {
                if(inst instanceof System){
                    exit = await inst.execute(ast, env, gen);
                } else {
                    await inst.execute(ast, env, gen);
                }
            }
            if(exit) {
                stateDebug = statesDebug.end;
                endDebug(ast);
                i = 0;
            }
            i++;
            document.getElementById("show-instructions").value = ""
            // document.getElementById("show-instructions").value = inst.getText()
            showRegisters(ast.getRegisters())
            let text = inst.line + "\t\t" + editor_deb.getLine(inst.line-1).trim()
            document.getElementById("show-instructions").value = text
            if(i >= main.length){
                endDebug(ast);
                stateDebug = statesDebug.end;
                i = 0;
            }
        }
    }

    document.getElementById("start-debug").addEventListener("click", function() {
        stateDebug = statesDebug.running;
    });

    document.getElementById("end-deb").addEventListener("click", function() {
        endDebug(ast,true);
        stateDebug = statesDebug.end;
    })
};

const endDebug = (ast, finish=false) =>{
    // ast.setConsole("Se ha analizado el código correctamente\n");
    // console_output.value = ast.getConsole();
    
    stateDebug = null
    let buttonStep = document.getElementById("next-inst");
    buttonStep.disabled = true;
    buttonStep.style.color = '#4b5563'

    let buttonStart = document.getElementById("start-debug");
    buttonStart.disabled = false;
    buttonStart.style.color = '#0090f7'

    let buttonRun = document.getElementById("printTab");
    buttonRun.disabled = false;
    buttonRun.style.color = '#49b9a0'

    let endDeb = document.getElementById("end-deb");
    endDeb.disabled = true;
    endDeb.style.color = '#4b5563'

    let errors = ast.getErrors();
    if(errors.length > 0){
        console_output.value = "Se han encontrado errores en el código\n"
        showErrors(errors)
    }else{
        if(finish){
            console_output.value = "Se ha finalizado la ejecución del programa\n"
            document.getElementById("show-instructions").value = "Se ha finalizado la ejecución del programa\n"

        }else{
            ast.setConsole("Se ha analizado el código correctamente\n");
            console_output.value = ast.getConsole();
        }
    }
    ast.cleanConsole()
}

const CSTBuilder = (root, cst, start) => {
    const instructions = root?.instructions ?? [];
    var currentSection = "";
    const globalSection = cst.newId();
    cst.addNode(globalSection, "Global Section");
    cst.addEdge(start, globalSection);
    let isTextSectionDeclared = false;
    let textSection = 0;
    instructions.forEach(inst => {
        if(inst === undefined) return;
        if (inst instanceof SystemCall) {
            inst.buildCST(globalSection, cst);
        } else if (inst instanceof Section) {
            if (inst.name != "text") {
                let titleId = cst.newId();
                currentSection = titleId;
                cst.addNode(titleId, inst.name.charAt(0).toUpperCase() + inst.name.slice(1)+ " Section");
                cst.addEdge(start, titleId);

                let firstElement = cst.newId();
                cst.addNode(firstElement, "."+inst.name);
                cst.addEdge(titleId, firstElement);
            }else{
                if(!isTextSectionDeclared){
                    isTextSectionDeclared = true;
                    textSection = cst.newId();
                    cst.addNode(textSection, "Text Section");
                    cst.addEdge(start, textSection);
                }
                let titleId = cst.newId();
                cst.addNode(titleId,  "."+inst.name);
                cst.addEdge(textSection, titleId);
            }
        } else if (inst instanceof Label) {
            if(!isTextSectionDeclared){
                isTextSectionDeclared = true;
                textSection = cst.newId();
                cst.addNode(textSection, "Text Section");
                cst.addEdge(start, textSection);
            }
            let titleId = cst.newId();
            currentSection = titleId;
            cst.addNode(titleId, inst.label);
            cst.addEdge(textSection, titleId);
        } else if (inst instanceof Array) {
            inst.forEach(i => {
                i.buildCST(currentSection, cst);
            });
        } else {
            inst.buildCST(currentSection, cst);
        }
    });
}