class System extends Instruction {
    constructor(line, column, type, op1, op2, productionType) {
        super();
        this.line = line;
        this.column = column;
        this.type = type;
        this.op1 = op1;
        this.op2 = op2;
        this.productionType = productionType;
    }

    async execute(ast, env, gen) {
        gen.addQuadruple(this.type, this.op1.value, this.op2, null, null);
        // console.log('Ejecutando una llamada de sistema');
        // Obteniendo parámetros de la llamada
        let regtemp0 = ast?.registers?.getRegister('x0');
        let reg8 = ast?.registers?.getRegister('x8');

        if(reg8.value === 93) return this.exit(ast, env, gen)
        // console.log(regtemp0)
        if(regtemp0.value === null) return
        // Comprobando acción a realizar
        if (regtemp0.value === 0) await this.stdin(ast, env, gen);  // Se maneja una salida del sistema
        else if (regtemp0.value === 1) await this.stdout(ast, env, gen);  // Se maneja una salida del sistema
        else if (regtemp0.value === 2) await this.stderr(ast, env, gen);  // Se maneja una salida del sistema
        else if (regtemp0.value === -100) await this.files(ast, env, gen);  // Se maneja una salida del sistema
        else{
            await this.fileManagement(ast, env, gen);
        }
    }

    
    async stdin(ast, env, gen) { // Entrada estándar
        console_output.readOnly = false;
        console_output.focus();
        let regtemp8 = ast?.registers?.getRegister('x8');
        if (regtemp8.value === 63) { // read
            console_output.value = ast?.getConsole();
            lastInputPosition = console_output.scrollHeight;
            lastInputPosition  = console_output.value.length;
            let userInput = await getUserInput();
            userInput = userInput + '\n';
            ast?.setConsole(userInput);
            // console.log('User input:', userInput);
            memory.storeToBSS(ast,userInput);
            console_output.readOnly = true;
        }
        console_output.readOnly = true;
        return false;
    }

    async stdout(ast, env, gen) { // Salida estándar 
        let regtemp8 = ast?.registers?.getRegister('x8');
        if (regtemp8.value === 64) { // write
            let text = ""
            text = memory.getDataBySize(ast);
            ast?.setConsole(text);
            // console.log('Output:', text);
            console_output.value = ast?.getConsole();
        }
        if (regtemp8.value === 93) { // end
            return;
        }
        return false;

    }

    async stderr(ast, env, gen) { // Salida de errores estándar
        // ToDo:
        return false;

    }

    async files(ast, env, gen) { // Salida de errores estándar
        let regTemp8 = ast?.registers?.getRegister('x8');
        if(regTemp8.value === 56){
            let reg2 = ast?.registers?.getRegister('x2');
            if(reg2.value === 0){
                let file = await getUserFile();
                // console.log(file)
                memory.openFile(ast, "r",file.content)
            }else if(reg2.value === 101){
                memory.openFile(ast, "w")
            }
        }
        return false;
    }

    async fileManagement(ast, env, gen) { // Salida de errores estándar
        let regTemp8 = ast?.registers?.getRegister('x8');
        if (regTemp8.value === 64){
            const file= memory.writeFile(ast)
            const blob = new Blob([file.content], { type: 'text/plain' });
            const url = URL.createObjectURL(blob);

            const a = document.createElement('a');
            a.href = url;
            let fileName = file.filename;
            a.download = fileName;
            a.click();
            // console.log(file)
            
        }else if (regTemp8.value === 63){
            // const [filename, content] = memory.writeFile(ast)
            // let reg1 = ast?.registers?.getRegister('x1');
            const file = memory.getFileContent(ast)
            memory.storeToBSS(ast, file)
            // console.log()
        }else{
        }
        return false;

    }

    async exit(ast, env, gen){
        let ope = this.op1.execute(ast, env, gen);
        if (ope.value === 0) {
            return true;
        }
        return false;

    }

    buildCST(parent, cst) {
        let titleId = cst.newId();
        cst.addNode(titleId, "System Instruction");
        cst.addEdge(parent, titleId);

        let typeId = cst.newId();
        cst.addNode(typeId, this.type);
        cst.addEdge(titleId, typeId);

        if (this.op1) {
            this.op1.buildCST(titleId, cst);
        }

        if (this.op2) {
            this.op2.buildCST(titleId, cst);
        }
    }

    getText(){
        let inst = this.type;
        let text = inst
        let op1 = this.op1
        let op2 = this.op2
        if(op1 != null){
            text += " " + op1.value;
        }
        if(op2 != null){
            text += ", " + op2;
        }
        return text
    
    }


}

let lastInputPosition = 0;
let inputResolver = null;

function getUserInput() {
    return new Promise((resolve) => {
        function onKeyDown(e) {
            if (e.key === 'Enter') {
                e.preventDefault(); // Prevenir la acción predeterminada

                let fullText = console_output.value;
                let userInput = fullText.substring(lastInputPosition).trim();

                // print("\n");
                lastInputPosition = console_output.value.length;

                console_output.removeEventListener('keydown', onKeyDown); // Remove the event listener
                resolve(userInput);
            }
        }
        console_output.addEventListener('keydown', onKeyDown);
    });
}


function getUserFile() {
    return new Promise((resolve, reject) => {
        Swal.fire({
            text: "How was your experience getting help with this issue?",
            html: `<div style="display: flex; flex-direction: column; border: 2px dashed #485773; cursor: pointer; border-radius: 0.5rem; transition: transform 0.15s ease-in-out; transition: all 0.15s ease-in-out;">
            <input type="file"  id="name"  class="input-f" hidden onchange="handleFileChange(this)"/>
            <label for="name" style="width: 100%; height: 100%; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 0.5rem;padding:15px 0px">

                <svg xmlns="http://www.w3.org/2000/svg"  height="2em" viewBox="0 0 384 512"><path fill="currentColor" d="M320 464c8.8 0 16-7.2 16-16V160h-80c-17.7 0-32-14.3-32-32V48H64c-8.8 0-16 7.2-16 16v384c0 8.8 7.2 16 16 16zM0 64C0 28.7 28.7 0 64 0h165.5c17 0 33.3 6.7 45.3 18.7l90.5 90.5c12 12 18.7 28.3 18.7 45.3V448c0 35.3-28.7 64-64 64H64c-35.3 0-64-28.7-64-64z"/></svg>
                <p id="label-name" style="color: #9ea2ab;">Clic para elegir el archivo</p>
            </div>
        </div>`,
            background: '#232529',
            showClass: {
                popup: 'animate__bounceIn'
            },
            backdrop: `
                rgba(40,40,48,0.6)
                left top
            `
        }).then((result) => {
            if (result.isConfirmed) {
                const fileInput = document.getElementById('name');
                const selectedFile = fileInput.files[0]; // El primer archivo seleccionado (si hay alguno)
                if (selectedFile) {
                    const reader = new FileReader();
                    reader.onload = function(e) {
                        e.preventDefault(); 
                        const fileContent = e.target.result;
                        resolve({
                            name: selectedFile.name,
                            content: fileContent
                        });
                    };
                    reader.onerror = function(e) {
                        reject(new Error('Error reading file'));
                    };
                    reader.readAsText(selectedFile); // Puedes cambiar esto según el tipo de archivo (por ejemplo, readAsDataURL, readAsArrayBuffer, etc.)
                } else {
                    reject(new Error('No file selected'));
                }
            } else {
                reject(new Error('Swal was not confirmed'));
            }
        });
    });
}