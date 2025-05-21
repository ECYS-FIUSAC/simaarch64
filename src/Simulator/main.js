const console_output = document.querySelector('#console-output');
let listLabels = new Map();

const Analyze = async ()=>{
    const start = performance.now();
    const activeContent = document.querySelector('.tab-content.active');
    if (!activeContent) return; // Si no hay ninguna pestaña activa, no hacemos nada

    const editor = activeContent.querySelector('.CodeMirror').CodeMirror;
    const content = editor.getValue();
    console_output.value = '';
    //Se borran los errores de la tabla de errores
    var tErrors = document.querySelector('#errorTable tbody');
    tErrors.innerHTML = '';

    //Se borra la lista de cuadruplos
    let tbody = document.getElementById('quad-body');
    tbody.innerHTML = '';

        //Se borra la lista de cuadruplos
    tbody = document.getElementById('address-body');
    tbody.innerHTML = '';

    let buttonStep = document.getElementById("next-inst");
    buttonStep.disabled = true;
    buttonStep.style.color = '#4b5563'
    
    let buttonStart = document.getElementById("start-debug");
    buttonStart.disabled = true;
    buttonStart.style.color = '#4b5563'

    let endDeb = document.getElementById("end-deb");
    endDeb.disabled = true;
    endDeb.style.color = '#4b5563'

    //Se borra el cst
    let tcst = document.getElementById('tabresult3');
    tcst.innerHTML = '';


    try {
        //implementacion del parser
        let resultado = PEG.parse(content);
        console_output.value = "";
        let ast = new Ast();
        let env = new Environment(null, 'Global');
        memory = new Memory();
        spMemory = new SPMemory();
        let gen = new Generator();
        await RootExecuter(resultado, ast, env, gen)

        showQuadruples(gen.getQuadruples());

        showMemory(memory.getAllVariables());
        let cst = new Cst();
        
        let startId = cst.newId();
        cst.addNode(startId, "Start");
        CSTBuilder(resultado, cst, startId);
        generateCst(cst);
        // console.log(memory.getDescriptors())
        showRegisters(ast.getRegisters(),ast.getRegW())
        // showRegisters()
        // console.log(ast.getConsole())
        let errors = ast.getErrors();
        if(errors.length > 0){
            console_output.value = "Se han encontrado errores en el código\n"
            showErrors(errors)
        }else{
            ast.setConsole("Se ha analizado el código correctamente\n");
            console_output.value = ast.getConsole();
        }
        ast.cleanConsole()
    } catch (error) {
        console.log(error)
        if (error instanceof PEG.SyntaxError) {
            if (isLexicalError(error)) {
                printError("Error Léxico", error, console_output);
            } else {
                printError("Error Sintáctico", error, console_output);
            }
        } else {
            printError("Error desconocido", error, console_output);
        }
    }
    const end = performance.now();
    let generalTime = (end - start).toFixed(2);
    let time = document.querySelector('#timer');
    time.innerHTML = generalTime + ' ms';
    
    buttonStep.disabled = false;
    buttonStep.style.color = '#8da3af'
    
    buttonStart.disabled = false;
    buttonStart.style.color = '#0090f7'

}

showErrors = (errors) => {
    var tbody = document.querySelector('#errorTable tbody');
    errors.forEach(error => {
        var tr = document.createElement('tr');
        var td1 = document.createElement('td');
        td1.textContent = error.type;
        tr.appendChild(td1);
        var td2 = document.createElement('td');
        td2.textContent = error.msg;
        tr.appendChild(td2);
        var td3 = document.createElement('td');
        td3.textContent = error.line;
        tr.appendChild(td3);
        var td4 = document.createElement('td');
        td4.textContent = error.col;
        tr.appendChild(td4);
        tbody.appendChild(tr);
        td1.style.paddingTop = '1rem';
        td1.style.paddingBottom = '1rem';
        tr.style.borderBottom = '1px solid #4b5563';
    });

}

const AnalyzeDeb = async ()=>{
    const activeContent = document.querySelector('.tab-content.active');
    if (!activeContent) return; // Si no hay ninguna pestaña activa, no hacemos nada

    const editor = activeContent.querySelector('.CodeMirror').CodeMirror;
    const content = editor.getValue();
    console_output.value = '';
    //Se borran los errores de la tabla de errores
    var tErrors = document.querySelector('#errorTable tbody');
    tErrors.innerHTML = '';

    //Se borra la lista de cuadruplos
    let tbody = document.getElementById('quad-body');
    tbody.innerHTML = '';

    //Se borra el cst
    let tcst = document.getElementById('tabresult3');
    tcst.innerHTML = '';

    let buttonStep = document.getElementById("next-inst");
    buttonStep.disabled = false;
    buttonStep.style.color = '#f2af2d'
    
    let buttonStart = document.getElementById("start-debug");
    buttonStart.disabled = true;
    buttonStart.style.color = '#4b5563'

    let buttonRun = document.getElementById("printTab");
    buttonRun.disabled = true;
    buttonRun.style.color = '#4b5563'

    let endDeb = document.getElementById("end-deb");
    endDeb.disabled = false;
    endDeb.style.color = '#f47961'

    let time = document.querySelector('#timer');
    time.innerHTML = '00.00 ms';

    try {
        //implementacion del parser
        let resultado = PEG.parse(content);
        console_output.value = "";
        let ast = new Ast();
        let env = new Environment(null, 'Global');
        memory = new Memory();
        spMemory = new SPMemory();
        let gen = new Generator();
        await RootExecuterDebug(resultado, ast, env, gen, editor)    
        // console.log(ast.getConsole())   
    } catch (error) {
        console.log(error)
        if (error instanceof PEG.SyntaxError) {
            if (isLexicalError(error)) {
                printError("Error Léxico", error, console_output);
            } else {
                printError("Error Sintáctico", error, console_output);
            }
        } else {
            printError("Error desconocido", error, console_output);
        }
    }
}

document.getElementById("start-debug").addEventListener("click", async function() {
    stateDebug = statesDebug.running;
    await AnalyzeDeb();
});

function isLexicalError(e) {
    const validIdentifier = /^[a-zA-Z_$][a-zA-Z0-9_$]*$/;
    const validInteger = /^[0-9]+$/;
    const validRegister = /^[xwdsXWDS][0-9]+$/;
    const validCharacter = /^[a-zA-Z0-9_$,\[\]#"]$/;
    if (e.found) {
        if (!validIdentifier.test(e.found) &&
            !validInteger.test(e.found) &&
            !validRegister.test(e.found) &&
            !validCharacter.test(e.found)) {
            return true; // Error léxico
        }
    }
    return false; // Error sintáctico
}

function showQuadruples(quadruples) {
    let tbody = document.getElementById('quad-body');
    tbody.innerHTML = '';

    quadruples.forEach(function (object) {
        var newRow = document.createElement('tr');
        for (var key in object) {
            let newCell = document.createElement('td');
            newCell.style.paddingTop = '1rem';
            newCell.style.paddingBottom = '1rem';
            newCell.style.borderBottom = '1px solid #4b5563';
            // console.log(object[key])
            newCell.textContent = object[key].toString().toLowerCase();
            newRow.appendChild(newCell);
        }
        tbody.appendChild(newRow);
    });
}

function showMemory(quadruples) {
    let tbody = document.getElementById('address-body');
    tbody.innerHTML = '';

    quadruples.forEach(function (object) {
        var newRow = document.createElement('tr');
        for (var key in object) {
            let newCell = document.createElement('td');
            newCell.style.paddingTop = '1rem';
            newCell.style.paddingBottom = '1rem';
            newCell.style.borderBottom = '1px solid #4b5563';
            // console.log(object[key])
            newCell.textContent = object[key].toString().toLowerCase();
            newRow.appendChild(newCell);
        }
        tbody.appendChild(newRow);
    });
}

function showRegisters(registers, regW){
    let tbody = document.getElementById('register-body');
    tbody.innerHTML = '';
    // console.log("REGISTERS", registers)
    let i = 0;
    registers.forEach(function (object) {
        var newRow = document.createElement('tr');
        let newCell = document.createElement('td');
        newCell.style.paddingTop = '1rem';
        newCell.style.paddingBottom = '1rem';
        newCell.style.borderBottom = '1px solid #4b5563';
        if(i !== 32){
            newCell.textContent = "x"+i;
        }else{
            newCell.textContent = "SP"
        }
        
        let newCell2 = document.createElement('td');
        newCell2.style.paddingTop = '1rem';
        newCell2.style.paddingBottom = '1rem';
        newCell2.style.borderBottom = '1px solid #4b5563';
        if(object.value !== null){
            newCell2.textContent = object.value;
        }
        // console.log(object)
        newRow.appendChild(newCell);
        newRow.appendChild(newCell2);
        tbody.appendChild(newRow);
        i++;
    });

    var newRow = document.createElement('tr');
    let newCell = document.createElement('td');
    newCell.style.paddingTop = '1rem';
    newCell.style.paddingBottom = '1rem';
    newCell.style.borderBottom = '1px solid #4b5563';
    newCell.textContent = "SP"
    let newCell2 = document.createElement('td');
    newCell2.style.paddingTop = '1rem';
    newCell2.style.paddingBottom = '1rem';
    newCell2.style.borderBottom = '1px solid #4b5563';
    newCell2.textContent = spMemory.getSPValue().value;
    newRow.appendChild(newCell);
    newRow.appendChild(newCell2);
    tbody.appendChild(newRow);

    i = 0;
    registers.forEach(function (object) {
        var newRow = document.createElement('tr');
        let newCell = document.createElement('td');
        newCell.style.paddingTop = '1rem';
        newCell.style.paddingBottom = '1rem';
        newCell.style.borderBottom = '1px solid #4b5563';
        if(i !== 32){
            newCell.textContent = "w"+i;
        }else{
            newCell.textContent = " "
        }
        
        let newCell2 = document.createElement('td');
        newCell2.style.paddingTop = '1rem';
        newCell2.style.paddingBottom = '1rem';
        newCell2.style.borderBottom = '1px solid #4b5563';
        if(object.value !== null){
            newCell2.textContent = object.value;
        }
        // console.log(object)
        newRow.appendChild(newCell);
        newRow.appendChild(newCell2);
        tbody.appendChild(newRow);
        i++;
    });

    // newRow.appendChild(newCell2W);
    // tbody.appendChild(newRow);

}

function printError(type, error) {
    console.error('INVALIDO \n' + type + ':' + error + " linea: " + error.location?.start.line + ', columna:' + error.location?.start.column + ".");
    console_output.value = 'INVALIDO \n' + type + ': ' + error.message + " linea: " + error.location?.start.line + ', columna:' + error.location?.start.column + ".";
    var tbody = document.querySelector('#errorTable tbody');
    var tr = document.createElement('tr');
    var td1 = document.createElement('td');
    td1.textContent = type;
    tr.appendChild(td1);
    var td2 = document.createElement('td');
    td2.textContent = error.message;
    tr.appendChild(td2);
    var td3 = document.createElement('td');
    td3.textContent = error.location?.start.line;
    tr.appendChild(td3);
    var td4 = document.createElement('td');
    td4.textContent = error.location?.start.column;
    tr.appendChild(td4);
    tbody.appendChild(tr);
    td1.style.paddingTop = '1rem';
    td1.style.paddingBottom = '1rem';
    tr.style.borderBottom = '1px solid #4b5563';
}

const generateCst = (CstObj) => {
    // console.log(CstObj);
    let nodes = new vis.DataSet(CstObj.Nodes);
    let edges = new vis.DataSet(CstObj.Edges);
    let container = document.getElementById('tabresult3');

    let data = {
        nodes: nodes,
        edges: edges
    };

    let options = {
        layout: {
            hierarchical: {
                enabled: true, // Habilita el layout jerárquico
                levelSeparation: 150, // Aumenta la separación entre niveles
                nodeSpacing: 150, // Aumenta el espacio entre nodos en el mismo nivel
                treeSpacing: 250, // Aumenta el espacio entre árboles diferentes en el layout
                direction: "UD", // Dirección del layout (UD = de arriba hacia abajo)
                sortMethod: "directed" // Método de ordenamiento, 'directed' mantiene la dirección de padre a hijo
            }
        },
        nodes: {
            shape: "box",
            color: {
                border: 'blue',
                background: 'lightblue'
            },
            font: {
                face: 'Monospace',
                align: 'left'
            }
        },
        edges: { 
            color: {
                color: 'gray',
                highlight: 'red', // Color cuando el nodo está seleccionado
            },
            smooth: true, // Hace que las aristas sean curvas
        },
        interaction: {
            selectConnectedEdges: true, // Selecciona automáticamente las aristas conectadas al seleccionar un nodo
        },
        physics: false // Desactiva el sistema de físicas para hacer que los nodos sean estáticos
    };

    let network = new vis.Network(container, data, options);

    // Cambiar el color de las aristas al seleccionar un nodo
    network.on("select", function (params) {
        if (params.nodes.length > 0) {
            let selectedNode = params.nodes[0];
            nodes.update({id: selectedNode, color: {border: 'red', background: 'pink'}});
            edges.get().forEach((edge) => {
                if (edge.from === selectedNode || edge.to === selectedNode) {
                    edges.update({id: edge.id, color: 'purple'});
                    nodes.update({id: edge.from === selectedNode ? edge.to : edge.from, color: {border: 'purple', background: 'pink'}});
                }
            });
        }
    });

    network.on("deselectNode", function () {
        nodes.get().forEach((node) => {
            nodes.update({id: node.id, color: {border: 'blue', background: 'lightblue'}});
        });
        edges.get().forEach((edge) => {
            edges.update({id: edge.id, color: 'gray'});
        });
    });
}