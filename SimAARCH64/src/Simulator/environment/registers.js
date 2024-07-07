class Registers {
    constructor() {
        this.registersX = new Array(32).fill(0);
        this.registersW = new Array(32).fill(0);
        this.initRegisters();
    }

    initRegisters() {
        this.registersX.forEach((register, index) => {
            this.registersX[index] = {value:0,type:Type.INT};
            this.registersW[index] = { value: 0, type: Type.INT };
        })
        // console.log(this.registers)
    }

    getRegister(registerIndex) {
        try {
            let regNumber = null;
            if (!registerIndex.includes('x') && !registerIndex.includes('w')) {
                return null;
            } else if (registerIndex.includes('w')) {
                regNumber = parseInt(registerIndex.replace('w', ''));
            } else if (registerIndex.includes('x')) {
                regNumber = parseInt(registerIndex.replace('x', ''));
            }

            if (regNumber >= 0 && regNumber < 32) {
                return this.registersX[regNumber];
            } else {
                return null;
            }
        } catch (e) {
            return null;
        }
    }

    setRegister(registerIndex, value) {
        // console.log(registerIndex, value)
        try {
            let regNumber = null;
            if (!registerIndex.includes('x') && !registerIndex.includes('w')) {
                return null;
            } else if (registerIndex.includes('w')) {
                regNumber = parseInt(registerIndex.replace('w', ''));
            } else if (registerIndex.includes('x')) {
                regNumber = parseInt(registerIndex.replace('x', ''));
            }

            if (regNumber >= 0 && regNumber < 32) {
                this.registersX[regNumber] = value;
                value.value = value.value & 0xFFFFFFFF; // Obtén los primeros 64 bits
                this.registersW[regNumber] = value; // Obtén los primeros 32 bits
            } else {
                return null;
            }
        } catch (e) {
            return null;
        }
    }

    getRegisterHexa(){
        //ToDo:
    }

    getAllRegisters(){
        return this.registersX
    }

    getRegistersW(){
        return this.registersW
    }

    buildCST(parent, cst) {
        let reg = cst.newId();
        cst.addNode(reg, "Register");
        cst.addEdge(parent, reg);

        let resId = cst.newId();
        cst.addNode(resId, this.dir);
        cst.addEdge(reg, resId);
    }
}