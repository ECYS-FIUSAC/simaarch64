class Memory {
    constructor(memorySize = 1024 * 1024, bssSize = 1024 * 1024) {
        this.memory = new ArrayBuffer(memorySize);
        this.memoryView = new DataView(this.memory);
        this.memoryPrint = new Uint8Array(this.memory);
        this.bssMemory = new ArrayBuffer(bssSize);
        this.bssMemoryView = new DataView(this.bssMemory);
        this.memoryPrintBSS = new Uint8Array(this.bssMemory);
        this.symbolTable = new Map();
        this.currentAddress = 1000;
        this.currentBSSAddress = 0;
        this.descriptors = new Map();
    }

    allocateMemory(size) {
        const address = this.currentAddress;
        this.currentAddress += size;
        return BigInt(address);
    }

    allocateBSSMemory(size) {
        const address = this.currentBSSAddress;
        this.currentBSSAddress += size;
        // console.log("Allocating BSS memory at", address, "with size", size)
        return BigInt(address);
    }

    defineVariable(name, initialValue, id, type) {
        id = name
        // console.log("Definiendo variable", name, "con valor inicial", initialValue, id);
        if (!id) {
            throw new Error("ID no puede ser undefined");
        }
        let data;
        if (typeof initialValue === 'string') {
            initialValue += '\0'; // Agregar un caracter nulo al final de la cadena
            const encoder = new TextEncoder();
            data = encoder.encode(initialValue);
        } else if (typeof initialValue === 'number') {
            data = new Uint8Array([initialValue]);
        } else {
            throw new Error("Tipo de valor inicial no soportado");
        }

        const address = this.allocateMemory(data.length);
        new Uint8Array(this.memory, Number(address), data.length).set(data);
        const symbol = new Symbol(address, initialValue, id, type);
        this.symbolTable.set(name, symbol);
        return address;
    }

    defineBSSVariable(name, size, id, type) {
        id = name
        if (!id) {
            throw new Error("ID no puede ser undefined");
        }

        const address = this.allocateBSSMemory(size);

        // Inicializar la variable en .bss a cero
        new Uint8Array(this.bssMemory, Number(address), size).fill(0);
        const symbol = new Symbol(address, 0, id, type);
        this.symbolTable.set(name, symbol);
        return address;
    }

    storeToBSS(ast, data) {
        
        const address = Number(ast.registers.getRegister('x1').value);
        
        if (typeof data === 'string') {
            const encoder = new TextEncoder();
            data = encoder.encode(data);
        } else if (typeof data === 'number') {
            data = new Uint8Array([data]);
        } else if (data instanceof Uint8Array) {
            // Si data ya es un Uint8Array, no necesitamos convertirlo.
        } else {
            ast.setNewError({ msg: `No se soporta el tipo de dato ingresado`, line: this.line, col: this.col, type: "semantico"});
            return 
        }

        if (address + data.length > this.bssMemory.byteLength) {
            // throw new Error("Datos exceden el tamaño de la memoria BSS");
            ast.setNewError({ msg: `Datos exceden el tamaño de la memoria BSS.`, line: this.line, col: this.col, type: "semantico"});
            return
        }

        new Uint8Array(this.bssMemory, address, data.length).set(data);
    }

    getVariableAddress(name) {
        const symbol = this.symbolTable.get(name);
        return symbol ? symbol.address : undefined;
    }

    loadAddressToRegister(ast,register, variableName) {
        // console.log(variableName)
        const address = this.getVariableAddress(variableName);
        if (address === undefined) {
            // throw new Error(`Variable no definida: ${variableName}`);
            ast.setNewError({ msg: `Variable no definida: ${variableName}`, line: this.line, col: this.col, type: "semantico"});
            return
        }
        ast.registers.setRegister(register, address)
    }

    getAddress(variableName){
        const address = this.getVariableAddress(variableName);
        if (address === undefined) {
            ast.setNewError({ msg: `Variable no definida: ${variableName}`, line: this.line, col: this.col, type: "semantico"});
            return
        }
        return address
    }

    moveToRegister(ast,register, value) {
        // this.registers[register] = BigInt(value);
        ast.registers.setRegister(register, BigInt(value))
    }

    loadByte(address) {
        return this.memoryView.getUint8(Number(address));
    }

    loadByteBSS(address) {
        return this.bssMemoryView.getUint8(Number(address));
    }

    storeByte(address, value) {
        this.memoryView.setUint8(Number(address), value & 0xFF);
    }

    storeByteBSS(address, value) {
        this.bssMemoryView.setUint8(Number(address), value & 0xFF);
    }

    loadWord(address) {
        return this.memoryView.getUint32(Number(address), true); // Little-endian
    }

    storeWord(address, value) {
        this.memoryView.setUint32(Number(address), value & 0xFFFFFFFF, true); // Little-endian
    }

    loadDoubleWord(address) {
        return this.memoryView.getBigUint64(Number(address), true); // Little-endian
    }

    storeDoubleWord(address, value) {
        this.memoryView.setBigUint64(Number(address), BigInt(value), true); // Little-endian
    }

    loadByteWithOffset(baseAddress, offsetType, offsetValue, scale = 1, extend = false) {
        const offset = this.calculateOffset(baseAddress, offsetType, offsetValue, scale, extend);
        return this.loadByte(baseAddress + offset);
    }

    storeByteWithOffset(baseAddress, offsetType, offsetValue, byteValue, scale = 1, extend = false) {
        const offset = this.calculateOffset(baseAddress, offsetType, offsetValue, scale, extend);
        this.storeByte(baseAddress + offset, byteValue);
    }

    calculateOffset(ast,baseAddress, offsetType, offsetValue, scale = 1, extend = false) {
        switch (offsetType) {
            case 'immediate':
                return BigInt(offsetValue);
            case 'register':
                // return this.registers[offsetValue];
                return ast.registers.getRegister(offsetValue)
            case 'scaled':
                // return this.registers[offsetValue] * BigInt(scale);
                return ast.registers.getRegister(offsetValue) * BigInt(scale)
            case 'extended':
                // let value = this.registers[offsetValue];
                let value = ast.registers.getRegister(offsetValue)
                if (extend) {
                    value = BigInt.asIntN(64, value);
                }
                return value * BigInt(scale);
            default:
                throw new Error('Tipo de offset no válido');
        }
    }

    getAllVariables(){
        return this.symbolTable;
    }

    openFile(ast, mode, content= ""){
        // const fd = Object.keys(this.descriptors).length+4;
        // this.descriptors.set(fd, {filename, mode, content});
        // let retValue = {value:fd, type: Type.DESCRIPTOR}
        // ast.registers.setRegister('x0', retValue)
        let filename = this.getDataByEOF(ast)
        const fd = this.descriptors.size + 4;
        this.descriptors.set(fd, {filename, mode, content});
        let retValue = {value:fd, type: Type.DESCRIPTOR}
        // console.log(retValue)
        ast.registers.setRegister('x0', retValue)
    }

    readFile(ast){
        let desc = Number(ast.registers.getRegister('x0').value)
        if(desc.Type !== Type.DESCRIPTOR){
            ast.setNewError({ msg: `Descriptor no válido`, line: this.line, col: this.col, type: "semantico"});
            return
        }
        let buffer = Number(ast.registers.getRegister('x1').value)
        // let size = Number(ast.registers.getRegister('x2').value)
        let file = this.descriptors.get(desc)

        const encoder = new TextEncoder();
        let data = encoder.encode(file.content)
        new Uint8Array(this.bssMemory, buffer, data.length).set(data);
    }

    writeFile(ast){
        let desc = ast.registers.getRegister('x0')
        // console.log(desc)
        if(desc.type !== 'descriptor'){
            ast.setNewError({ msg: `Descriptor no válido`, line: this.line, col: this.col, type: "semantico"});
            return
        }
        let text = this.getDataBySize(ast)
        let file = this.descriptors.get(desc.value)
        file.content = text
        return file
    }

    getFileContent(ast){
        let desc = ast.registers.getRegister('x0')
        if(desc.type !== 'descriptor'){
            ast.setNewError({ msg: `Descriptor no válido`, line: this.line, col: this.col, type: "semantico"});
            return
        }
        let file = this.descriptors.get(desc.value)
        return file.content
    }

    closeFile(ast){
        let desc = Number(ast.registers.getRegister('x0').value)
        if(desc.Type !== Type.DESCRIPTOR){
            ast.setNewError({ msg: `Descriptor no válido`, line: this.line, col: this.col, type: "semantico"});
            return
        }
        this.descriptors.delete(desc)
    }

    reset(memorySize = 1024 * 1024, bssSize = 1024 * 1024){
        this.memory = new ArrayBuffer(memorySize);
        this.memoryView = new DataView(this.memory);
        this.memoryPrint = new Uint8Array(this.memory);
        this.bssMemory = new ArrayBuffer(bssSize);
        this.bssMemoryView = new DataView(this.bssMemory);
        this.memoryPrintBSS = new Uint8Array(this.bssMemory);
        this.symbolTable = new Map();
        this.currentAddress = 1000;
        this.currentBSSAddress = 0;
        this.descriptors = new Map();
    }

    getDataBySize(ast){
        let validate = ast.registers.getRegister('x1')
        let sizeText = this.getSizeEOF(ast)
        if(validate.value < 1000){
            const address = Number(ast.registers.getRegister('x1').value)
            let size = Number(ast.registers.getRegister('x2').value)
            if(size > sizeText){
                size = sizeText
            }
            const buffer =  this.memoryPrintBSS.slice(address, address + size);
            // console.log("Buffer: ", buffer. )
            return new TextDecoder().decode(buffer);
        }
        const fd = Number(ast.registers.getRegister('x0').value)
        const bufferAddress = Number(ast.registers.getRegister('x1').value)
        let size = Number(ast.registers.getRegister('x2').value)
        if(size > sizeText){
                size = sizeText
        }
        const buffer =  this.memoryPrint.slice(bufferAddress, bufferAddress + size);
        return new TextDecoder().decode(buffer);
    }

    getDataByEOF(ast){
        let validate = ast.registers.getRegister('x1')
        if(validate.value < 1000){
            const address = Number(ast.registers.getRegister('x1').value)
            const size = this.getSizeEOF(ast)
            const buffer =  this.memoryPrintBSS.slice(address, address + size);
            return new TextDecoder().decode(buffer);
        }
        const fd = Number(ast.registers.getRegister('x0').value)
        const bufferAddress = Number(ast.registers.getRegister('x1').value)
        const size = this.getSizeEOF(ast)
            // console.log("Size: ", size)

        const buffer =  this.memoryPrint.slice(bufferAddress, bufferAddress + size);
        return new TextDecoder().decode(buffer);
    }

    getSizeEOF(ast){
        let validate = ast.registers.getRegister('x1')
        if(validate.value < 1000){
            let outAddress = validate.value
            let count = 0
            for(let i = 0; i < this.currentAddress; i++){
                let byte = this.loadByteBSS(outAddress + BigInt(i))
                if(byte === 0){
                    break;
                }
                count++
            }
        return count
        }
        let outAddress = validate.value
        let count = 0
        for(let i = 1000; i < this.currentAddress; i++){
            let byte = this.loadByte(outAddress + BigInt(count))
            if(byte === 0){
                break;
            }
            count++
        }
        return count
    }

    getDescriptors(){
        return this.descriptors
    }
}

// const handlerStoreByte = async ( address, value) => {
//     // const memory = ast.memory;
//     memory.storeByteBSS(address, value);
// }

// make a promise for storeByteBSS
const handlerStoreByte = (address, value) => {
    return new Promise((resolve, reject) => {
        memory.storeByteBSS(address, value);
        resolve();
    });
}

class SPMemory{
    constructor(initialAddres = 0xFFFFFFFFFFFFFFFFn){
        this.sp = BigInt(initialAddres)
        // console.log(this.sp)
        this.spMem = new Map()
    }

    
    sub(value) {
        // Ahora restamos el valor directamente, ya que 'value' ya representa bytes
        this.sp -= BigInt(value);
        
    }

    add(value) {
        // Sumamos el valor directamente
        this.sp += BigInt(value);
    }

    getSP(){
        return this.sp
    }

    getSPValue(){
        // let mem = BigInt(this.spMem.get(this.sp))
        let value = (this.sp) || 0n
        value = "0x"+ value.toString(16)

        // value ="0x" + value.toString(16)
        return {value: value, type: Type.SPMEM}
    }

    ldr(ast,destReg, offset){
        const baseAddress = this.sp 
        const address = baseAddress + BigInt(offset)
        const value = this.spMem.get(address) || 0n
        // const valueinPos = this.spMem.get(address)
        let valRet = {value: value, type: Type.SPMEM}
        // console.log(valRet,address, this.sp, destReg)
        ast.registers.setRegister(destReg, valRet)
    }

    str(value, offset = 0){
        const address = this.sp + BigInt(offset);
        this.spMem.set(address,value);
    }

    ldrb(offset){
        const address = this.sp + BigInt(offset)
        const value = this.spMem.get(address) || 0n
        let retVal = {value: value, type: Type.SPMEM}
        return retVal
    }

    strb(offset, value){
        const address = this.sp + BigInt(offset)
        const byteValue = Number(value);
        this.spMem.set(address, byteValue)
    }

    reset(){
        this.sp = 0xFFFFFFFFFFFFFFFFn
        this.spMem = new Map()
    }
}