class Ast {
    constructor() {
        this.instructions = [];
        this.console = "";
        this.errors = [];
        this.registers = new Registers()
    }

    setConsole(str){
        this.console += str;
    }

    setNewError(err){
        this.errors.push(err);
    }

    getErrors(){
        return this.errors;
    }

    getConsole(){
        return this.console;
    }

    getRegisters(){
        return this.registers.getAllRegisters();
    }

    getRegW(reg){
        return this.registers.getRegistersW(reg);
    }

    cleanConsole(){
        this.console = "";
    }
}