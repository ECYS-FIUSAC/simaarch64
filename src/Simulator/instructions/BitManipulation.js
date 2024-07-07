class BitManipulation extends Instruction{
    constructor(line, column, type, op1, op2, op3, op4){
        super();
        this.line = line;
        this.column = column;
        this.type = type.trim().toLowerCase();
        this.op1 = op1;
        this.op2 = op2;
        this.op3 = op3;
        this.op4 = op4;
    }

    execute(ast, env, gen){
        gen.addQuadruple(this.type, this.op2 != null ? this.op2.text : null, this.op3 != null ? this.op3.text : null, this.op4 != null ? this.op4.text : null, this.op1.dir);
        const instruccion = (this.type.toLowerCase()).trim();
        let registro_fuente, lsb, width, registro_destino;
        var operador1_original = this.op1;
        var operador2_original = this.op2;
        var operador3_original = this.op3;
        var operador4_original = this.op4;

         if(this.op1 != null){
            this.op1 = this.op1.text.toLowerCase().trim();
        }
        if(this.op2 != null){
            this.op2 = this.op2.text.toLowerCase().trim();
        }

        if(this.op3 != null && this.op3 != undefined){
            this.op3 = this.op3.text
        }
        if(this.op4 != null && this.op4 != undefined){
            this.op4 = this.op4.text
        }



        switch(instruccion){
            case "bfi":

                this.op3 = this.op3.toLowerCase().trim();
                this.op3 = this.op3.replace("#", "");
                if(this.op3.includes("0x")){
                    let cNumber = this.op3.replace("0x", "");
                    this.op3 = parseInt(cNumber, 16);
                }
                if(this.op3.includes("0b")){
                    let cNumber = this.op3.replace("0b", "");
                    this.op3 = parseInt(cNumber, 2);
                }

                this.op4 = this.op4.toLowerCase().trim();
                this.op4 = this.op4.replace("#", "");
                if(this.op4.includes("0x")){
                    let cNumber = this.op4.replace("0x", "");
                    this.op4 = parseInt(cNumber, 16);
                }
                
                if(this.op4.includes("0b")){
                    let cNumber = this.op4.replace("0b", "");
                    this.op4 = parseInt(cNumber, 2);
                }   

                registro_fuente = ast.registers.getRegister(this.op2);
                registro_fuente = registro_fuente.value;
                lsb = Number(this.op3);
                width = Number(this.op4);
                registro_destino = ast.registers.getRegister(this.op1);
                registro_destino = registro_destino.value;

                if (typeof registro_fuente === "string"){
                    registro_fuente = parseInt(registro_fuente, 10);
                }
                if (typeof registro_destino === "string"){
                    registro_destino = parseInt(registro_destino, 10);
                }

                const mask_bfi = (1 << width) - 1;
                const bits_bfi = registro_fuente & mask_bfi;
                const mask_destino_bfi = ~(mask_bfi << lsb);
                registro_destino &= mask_destino_bfi;
                registro_destino |= bits_bfi << lsb;

                ast.registers.setRegister(this.op1, {value: registro_destino, type: this.type.INT});
                break;
            
            case "bfxil":

                this.op3 = this.op3.toLowerCase().trim();
                this.op3 = this.op3.replace("#", "");
                if(this.op3.includes("0x")){
                    let cNumber = this.op3.replace("0x", "");
                    this.op3 = parseInt(cNumber, 16);
                }
                if(this.op3.includes("0b")){
                    let cNumber = this.op3.replace("0b", "");
                    this.op3 = parseInt(cNumber, 2);
                }

                this.op4 = this.op4.toLowerCase().trim();
                this.op4 = this.op4.replace("#", "");
                if(this.op4.includes("0x")){
                    let cNumber = this.op4.replace("0x", "");
                    this.op4 = parseInt(cNumber, 16);
                }
                
                if(this.op4.includes("0b")){
                    let cNumber = this.op4.replace("0b", "");
                    this.op4 = parseInt(cNumber, 2);
                }   

                registro_fuente = ast.registers.getRegister(this.op2);
                registro_fuente = registro_fuente.value;
                lsb = Number(this.op3);
                width = Number(this.op4);
                registro_destino = ast.registers.getRegister(this.op1);
                registro_destino = registro_destino.value;


                if (typeof registro_fuente === "string") {
                    registro_fuente = parseInt(registro_fuente, 10); 
                }
                if (typeof registro_destino === "string") {
                    registro_destino = parseInt(registro_destino, 10);
                }

                const mask_bfxil = (1 << width) - 1;
                const bits_bfxil = (registro_fuente >> lsb) & mask_bfxil;
                const mask_destino_bfxil = ~mask_bfxil;
                registro_destino &= mask_destino_bfxil;
                registro_destino |= bits_bfxil;

                ast.registers.setRegister(this.op1, {value: registro_destino, type: this.type.INT});

                break;

            case "cls": 

                registro_fuente = ast.registers.getRegister(this.op2);
                registro_fuente = registro_fuente.value;
                registro_destino = ast.registers.getRegister(this.op1);
                registro_destino = registro_destino.value;


                let valor_binario = BigInt(registro_fuente).toString(2).padStart(64, '0');

                const sign_bit = (BigInt(registro_fuente) >> 63n) & 1n;


                let count = 0;
                for (let i = 63; i >= 0; i--) {
                    const current_bit = (BigInt(registro_fuente) >> BigInt(i)) & 1n;
                    if (current_bit === sign_bit) {
                        count++;
                    } else {
                        break;
                    }
                }

                ast.registers.setRegister(this.op1, {value: count, type: this.type.INT});

                break;
            
            case "clz":  

                registro_fuente = ast.registers.getRegister(this.op2);
                registro_fuente = registro_fuente.value;
                registro_destino = ast.registers.getRegister(this.op1);
                registro_destino = registro_destino.value;
            
                if (typeof registro_fuente === "string") {
                    registro_fuente = parseInt(registro_fuente, 10);
                }
            
                let valor_binario_clz = BigInt(registro_fuente).toString(2).padStart(64, '0');
            
                let count_clz = 0;
                for (let i = 63; i >= 0; i--) {
                    const current_bit = (BigInt(registro_fuente) >> BigInt(i)) & 1n;
                    if (current_bit === 0n) {
                        count_clz++;
                    } else {
                        break;
                    }
                }
            
                ast.registers.setRegister(this.op1, {value: count_clz, type: this.type.INT});
            
                break;

            case "extr":
                this.op4 = this.op4.toLowerCase().trim();
                this.op4 = this.op4.replace("#", "");
                if(this.op4.includes("0x")){
                    let cNumber = this.op4.replace("0x", "");
                    this.op4 = parseInt(cNumber, 16);
                }
                
                if(this.op4.includes("0b")){
                    let cNumber = this.op4.replace("0b", "");
                    this.op4 = parseInt(cNumber, 2);
                }

                let registro_fuente1 = ast.registers.getRegister(this.op2);
                registro_fuente1 = registro_fuente1.value;
                let registro_fuente2 = ast.registers.getRegister(this.op3);
                registro_fuente2 = registro_fuente2.value;

                let n = Number(this.op4);


                if (typeof registro_fuente1 === "string") {
                    registro_fuente1 = parseInt(registro_fuente1, 10);
                }
                if (typeof registro_fuente2 === "string") {
                    registro_fuente2 = parseInt(registro_fuente2, 10);
                }

                let operand1 = BigInt(registro_fuente1) & ((1n << 64n) - 1n);
                let operand2 = BigInt(registro_fuente2) & ((1n << 64n) - 1n);

                let concatenado = (operand1 << 64n) | operand2;
                let resultado = (concatenado >> BigInt(n)) & ((1n << 64n) - 1n);
                resultado = Number(resultado);
                ast.registers.setRegister(this.op1, {value: resultado, type: this.type.INT});
                break;

            
            case "rbit":
                registro_fuente = ast.registers.getRegister(this.op2);
                registro_fuente = registro_fuente.value;

                if (typeof registro_fuente === "string") {
                    registro_fuente = parseInt(registro_fuente, 10);
                }

                let operand_rbit = BigInt(registro_fuente) & ((1n << 64n) - 1n);
                let resultado_rbit = 0n;

                for (let i = 0; i < 64; i++) {
                    resultado_rbit |= ((operand_rbit >> BigInt(i)) & 1n) << BigInt(63 - i);
                }
                resultado_rbit = Number(resultado_rbit);
                ast.registers.setRegister(this.op1, {value: resultado_rbit, type: this.type.INT});

                break;

            case "rev":
                registro_fuente = ast.registers.getRegister(this.op2);
                registro_fuente = registro_fuente.value;

                if (typeof registro_fuente === "string") {
                    registro_fuente = parseInt(registro_fuente, 10);
                }

                let operand_rev = BigInt(registro_fuente) & ((1n << 64n) - 1n);
                let resultado_rev = 0n;

                for (let i = 0; i < 8; i++) {
                    resultado_rev |= ((operand_rev >> BigInt(i * 8)) & 0xFFn) << BigInt((7 - i) * 8);
                }

                resultado_rev = Number(resultado_rev);
                ast.registers.setRegister(this.op1, {value: resultado_rev, type: this.type.INT});
                break;

            case "rev16":
                let registro_fuente_rev16 = ast.registers.getRegister(this.op2);
                registro_fuente_rev16 = registro_fuente_rev16.value;

                if (typeof registro_fuente_rev16 === "string") {
                    registro_fuente_rev16 = parseInt(registro_fuente_rev16, 10);
                }

                let operand_rev16 = BigInt(registro_fuente_rev16) & ((1n << 64n) - 1n);
                let resultado_rev16 = 0n;

                for (let i = 0n; i < 8n; i += 2n) {
                    let halfword = (operand_rev16 >> (i * 8n)) & 0xFFFFn;
                    let reversed_halfword = ((halfword & 0xFF00n) >> 8n) | ((halfword & 0x00FFn) << 8n);
                    resultado_rev16 |= reversed_halfword << (i * 8n);
                }
                resultado_rev16 = Number(resultado_rev16);
                ast.registers.setRegister(this.op1, {value: resultado_rev16, type: this.type.INT});
                break;

            case "rev32":
                let registro_fuente_rev32 = ast.registers.getRegister(this.op2);
                registro_fuente_rev32 = registro_fuente_rev32.value;

                if (typeof registro_fuente_rev32 === "string") {
                    registro_fuente_rev32 = parseInt(registro_fuente_rev32, 10);
                }

                let operand_rev32 = BigInt(registro_fuente_rev32) & ((1n << 64n) - 1n);
                let resultado_rev32 = 0n;

                for (let i = 0n; i < 8n; i+=4n) {
                    let word = (operand_rev32 >> (i * 8n)) & 0xFFFFFFFFn;
                    let reversed_word = ((word & 0xFF000000n) >> 24n) 
                                        | ((word & 0x00FF0000n) >> 8n) 
                                        | ((word & 0x0000FF00n) << 8n) 
                                        | ((word & 0x000000FFn) << 24n);
                    
                    resultado_rev32 |= reversed_word << (i * 8n);
                }
                resultado_rev32 = Number(resultado_rev32);
                ast.registers.setRegister(this.op1, {value: resultado_rev32, type: this.type.INT});
                break;

            case "bfiz":
            case "ubfiz":
                registro_fuente = ast.registers.getRegister(this.op2);
                registro_fuente = registro_fuente.value;
                if (typeof registro_fuente === "string") {
                    registro_fuente = parseInt(registro_fuente, 10);
                }

                this.op3 = this.op3.toLowerCase().trim();
                this.op3 = this.op3.replace("#", "");
                if(this.op3.includes("0x")){
                    let cNumber = this.op3.replace("0x", "");
                    this.op3 = parseInt(cNumber, 16);
                }
                if(this.op3.includes("0b")){
                    let cNumber = this.op3.replace("0b", "");
                    this.op3 = parseInt(cNumber, 2);
                }

                this.op4 = this.op4.toLowerCase().trim();
                this.op4 = this.op4.replace("#", "");
                if(this.op4.includes("0x")){
                    let cNumber = this.op4.replace("0x", "");
                    this.op4 = parseInt(cNumber, 16);
                }
                
                if(this.op4.includes("0b")){
                    let cNumber = this.op4.replace("0b", "");
                    this.op4 = parseInt(cNumber, 2);
                }

                let p_bfiz = Number(this.op3);
                let n_bfiz = Number(this.op4);

                let mask_bfiz = ((1n << BigInt(n_bfiz)) - 1n) << BigInt(p_bfiz);
                let resultado_bfiz = (BigInt(registro_fuente) & mask_bfiz) >> BigInt(p_bfiz);
                resultado_bfiz = Number(resultado_bfiz);
                ast.registers.setRegister(this.op1, {value: resultado_bfiz, type: this.type.INT});
                break;

            case "sbfiz":
                registro_fuente = ast.registers.getRegister(this.op2);
                registro_fuente = registro_fuente.value;
                if (typeof registro_fuente === "string") {
                    registro_fuente = parseInt(registro_fuente, 10);
                }

                this.op3 = this.op3.toLowerCase().trim();
                this.op3 = this.op3.replace("#", "");
                if(this.op3.includes("0x")){
                    let cNumber = this.op3.replace("0x", "");
                    this.op3 = parseInt(cNumber, 16);
                }
                if(this.op3.includes("0b")){
                    let cNumber = this.op3.replace("0b", "");
                    this.op3 = parseInt(cNumber, 2);
                }

                this.op4 = this.op4.toLowerCase().trim();
                this.op4 = this.op4.replace("#", "");
                if(this.op4.includes("0x")){
                    let cNumber = this.op4.replace("0x", "");
                    this.op4 = parseInt(cNumber, 16);
                }
                
                if(this.op4.includes("0b")){
                    let cNumber = this.op4.replace("0b", "");
                    this.op4 = parseInt(cNumber, 2);
                }

                let p_sbfiz = Number(this.op3);
                let n_sbfiz = Number(this.op4);

                let mask_sbfiz = ((1n << BigInt(n_sbfiz)) - 1n) << BigInt(p_sbfiz);
                let resultado_sbfiz = (BigInt(registro_fuente) & mask_sbfiz) >> BigInt(p_sbfiz);

                let sign_bit_sbfiz = 1n << BigInt(n_sbfiz - 1);
                if (resultado_sbfiz & sign_bit_sbfiz) {
                    resultado_sbfiz |= ~((1n << BigInt(n_sbfiz)) - 1n);
                }
                resultado_sbfiz = Number(resultado_sbfiz);
                ast.registers.setRegister(this.op1, {value: resultado_sbfiz, type: this.type.INT});
                break;

            case "bfx":
            case "ubfx":
                registro_fuente = ast.registers.getRegister(this.op2);
                registro_fuente = registro_fuente.value;

                if (typeof registro_fuente === "string") {
                    registro_fuente = parseInt(registro_fuente, 10);
                }

                this.op3 = this.op3.toLowerCase().trim();
                this.op3 = this.op3.replace("#", "");
                if(this.op3.includes("0x")){
                    let cNumber = this.op3.replace("0x", "");
                    this.op3 = parseInt(cNumber, 16);
                }
                if(this.op3.includes("0b")){
                    let cNumber = this.op3.replace("0b", "");
                    this.op3 = parseInt(cNumber, 2);
                }

                this.op4 = this.op4.toLowerCase().trim();
                this.op4 = this.op4.replace("#", "");
                if(this.op4.includes("0x")){
                    let cNumber = this.op4.replace("0x", "");
                    this.op4 = parseInt(cNumber, 16);
                }
                
                if(this.op4.includes("0b")){
                    let cNumber = this.op4.replace("0b", "");
                    this.op4 = parseInt(cNumber, 2);
                }

                let p_bfx = Number(this.op3);
                let n_bfx = Number(this.op4);

                let mask_bfx = ((1n << BigInt(n_bfx)) - 1n) << BigInt(p_bfx);
                let resultado_bfx = (BigInt(registro_fuente) & mask_bfx) >> BigInt(p_bfx);
                resultado_bfx = Number(resultado_bfx);
                ast.registers.setRegister(this.op1, {value: resultado_bfx, type: this.type.INT});
                break;
            
            case "sbfx":
                registro_fuente = ast.registers.getRegister(this.op2);
                registro_fuente = registro_fuente.value;

                if (typeof registro_fuente === "string") {
                    registro_fuente = parseInt(registro_fuente, 10);
                }

                this.op3 = this.op3.toLowerCase().trim();
                this.op3 = this.op3.replace("#", "");
                if(this.op3.includes("0x")){
                    let cNumber = this.op3.replace("0x", "");
                    this.op3 = parseInt(cNumber, 16);
                }
                if(this.op3.includes("0b")){
                    let cNumber = this.op3.replace("0b", "");
                    this.op3 = parseInt(cNumber, 2);
                }

                this.op4 = this.op4.toLowerCase().trim();
                this.op4 = this.op4.replace("#", "");
                if(this.op4.includes("0x")){
                    let cNumber = this.op4.replace("0x", "");
                    this.op4 = parseInt(cNumber, 16);
                }
                
                if(this.op4.includes("0b")){
                    let cNumber = this.op4.replace("0b", "");
                    this.op4 = parseInt(cNumber, 2);
                }

                let p_sbfx = Number(this.op3);
                let n_sbfx = Number(this.op4);

                let mask_sbfx = ((1n << BigInt(n_sbfx)) - 1n) << BigInt(p_sbfx);
                let resultado_sbfx = (BigInt(registro_fuente) & mask_sbfx) >> BigInt(p_sbfx);

                let sign_bit_sbfx = 1n << BigInt(n_sbfx - 1);
                if (resultado_sbfx & sign_bit_sbfx) {
                    resultado_sbfx |= ~((1n << BigInt(n_sbfx)) - 1n);
                }
                resultado_sbfx = Number(resultado_sbfx);
                ast.registers.setRegister(this.op1, {value: resultado_sbfx, type: this.type.INT});
                break;
            
            case "sxtb":
            case "uxtb":
            case "xtb":
            case "xt":
            registro_fuente = ast.registers.getRegister(this.op2);
            registro_fuente = registro_fuente.value;

            if (typeof registro_fuente === "string") {
                registro_fuente = parseInt(registro_fuente, 10);
            }


            let byte_sxtb = BigInt(registro_fuente) & 0xFFn;
            let resultado_xtb;

            if(instruccion === "sxtb" || instruccion === "xtb"){
                resultado_xtb = (byte_sxtb & 0x80n) ? (byte_sxtb | ~0xFFn) : byte_sxtb;
            }else{
                resultado_xtb = byte_sxtb;
            }
            resultado_xtb = Number(resultado_xtb);
            let temp = ast.registers.getRegister(this.op1);
            ast.registers.setRegister(this.op1, {value: resultado_xtb, type: temp.type});
            break;

            case "sxth":
            case "uxth":
            case "xth":
                registro_fuente = ast.registers.getRegister(this.op2); 
                registro_fuente = registro_fuente.value; 

                if (typeof registro_fuente === "string") {
                    registro_fuente = parseInt(registro_fuente, 10);
                }

                let halfword_sxth = BigInt(registro_fuente) & 0xFFFFn;
                let resultado_xth;

                if(instruccion === "sxth" || instruccion === "xth"){
                    resultado_xth = (halfword_sxth & 0x8000n) ? (halfword_sxth | ~0xFFFFn) : halfword_sxth;
                }else{
                    resultado_xth = halfword_sxth;
                }
                resultado_xth = Number(resultado_xth);

                ast.registers.setRegister(this.op1, {value: resultado_xth, type: this.type.INT});
                break;


                case "sxtw":

                    registro_fuente = ast.registers.getRegister(this.op2);
                    registro_fuente = registro_fuente.value;

                    if (typeof registro_fuente === "string") {
                        registro_fuente = parseInt(registro_fuente, 10);
                    }

                    let word_sxtw = BigInt(registro_fuente) & 0xFFFFFFFFn;
                    let resultado_xthw;

                    if(instruccion === "sxtw"){
                        resultado_xthw = (word_sxtw & 0x80000000n) ? (word_sxtw | ~0xFFFFFFFFn) : word_sxtw;
                    }else{
                        resultado_xthw = word_sxtw;
                    }
                    resultado_xthw = Number(resultado_xthw);
                    ast.registers.setRegister(this.op1, {value: resultado_xthw, type: this.type.INT});


                    break;
            
            default:
                ast.setNewError({msg: `Instrucción ${instruccion} no reconocida`, line: this.line, col: this.column, type: "semantico"});
        }
        this.op1 = operador1_original;
        this.op2 = operador2_original;
        this.op3 = operador3_original;
        this.op4 = operador4_original;
    }

    buildCST(parent, cst) {
        let titleId = cst.newId();
        cst.addNode(titleId, "Bit Manipulation");
        cst.addEdge(parent, titleId);

        let typeId = cst.newId();
        cst.addNode(typeId, this.type);
        cst.addEdge(titleId, typeId);

        this.op1.buildCST(titleId, cst);

        if (this.op2) {
            this.op2.buildCST(titleId, cst);
        }

        if (this.op3) {
            this.op3.buildCST(titleId, cst);
        }
        if (this.op4) {
            this.op3.buildCST(titleId, cst);
        }

    }
}