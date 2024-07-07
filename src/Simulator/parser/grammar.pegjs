start
    = list:(directive_section / code_section / comment / blank_line)* EOI 
    {root.children = [...list]; root.children = root.children = root.children.filter(node => node.type !== TYPE.BLANK);
    root.children = root.children.filter(node => node.type !== TYPE.COMMENT); return root;}
// ************************************************** Directivas ************************************************** \\
directive_section
    = d:directive _* de:directive_exp? _* comment? "\n" exp:(vardeclaration)*
    {const n = createNode(TYPE.DIRECTIVE_SECTION, 'SECCION DE DIRECTIVAS', ''); n.addChild(d); if(de){n.addChild(de);} 
    exp.forEach(e => {if(e instanceof CSTnode &&  e.type !== TYPE.BLANK && e.type !== TYPE.COMMENT){n.addChild(e);}}); root.addChild(n); return n;}
directive_exp
    = e:directive {const n = createNode(TYPE.DIRECT_EXP, 'EXPRESION DIRECTIVA', ''); n.addChild(e); return n;}
    / i:identifier c:comma _* int:int {const n = createNode(TYPE.DIRECT_EXP, 'EXPRESION DIRECTIVA', ''); n.addChild(i); n.addChild(c); n.addChild(int); return n;}
    / i:identifier c:comma _* "@" i2:identifier {const n = createNode(TYPE.DIRECT_EXP, 'EXPRESION DIRECTIVA', ''); n.addChild(i); n.addChild(c); n.addChild(i2); return n;} 
    / i:identifier c:comma _* string:string {const n = createNode(TYPE.DIRECT_EXP, 'EXPRESION DIRECTIVA', ''); n.addChild(i); n.addChild(c); n.addChild(string); return n;}
    / i:identifier {const n = createNode(TYPE.DIRECT_EXP, 'EXPRESION DIRECTIVA', ''); n.addChild(i); return n;}
directive
    = _* "." directive_name {return createNode(TYPE.DIRECTIVE, text().replaceAll(/\s/g, ''), '');}
directive_name
    = "align" / "ascii" / "asciz" / "balign" / "bss" / "byte" / "comm" / "data" / "double" / "end" / "equ" / "extern"
    / "file" / "float" / "global" / "hword" / "incbin" / "include" / "int" / "long" / "p2align" / "quad" / "section"
    / "set" / "size" / "skip" / "space" / "string" / "text" / "type" / "word" / "zero"

// ************************************************** Expresiones ************************************************** \\
vardeclaration
    = l:label _* "\n"? d:directive _* s:string _* comment? "\n"? 
    {return new Variable(loc?.line, loc?.column, d, l, s)}
    / l:label _* "\n"? d:directive _* i:int _* comment? "\n"?
    {return new Variable(loc?.line, loc?.column, d, l, i)}
    / l:label _* "\n"? d:directive _* i:identifier _* comment? "\n"?
    {const n = createNode(TYPE.EXPRESSION, 'EXPRESSION', ''); n.addChild(l); n.addChild(d); n.addChild(i); return n;}
    / blank_line {return null;}
    / comment {return null;}
// ************************************************** Sección de Código ************************************************** \\
code_section
    = l:label _* comment? "\n" list:(instruction / blank_line / comment)+
    {const n = createNode(TYPE.INSTRUCTION_SECTION, 'SECCION DE INSTRUCCIONES', ''); n.addChild(l); const inst = createNode(TYPE.INSTRUCTIONS, 'INSTRUCCIONES', '');
    list.forEach(e => {if(e instanceof CSTnode &&  e.type !== TYPE.BLANK && e.type !== TYPE.COMMENT){inst.addChild(e);}}); n.addChild(inst); return n;}
// ************************************************** Instrucciones en ARM64 v8 ************************************************** \\
instruction
    = i:aadd_inst _* comment? "\n"? {return i;}
    / i:aclr_inst _* comment? "\n"? {return i;}
    / i:adc_inst _* comment? "\n"? {return i;}
    / i:add_inst _* comment? "\n"? {return i;}
    / i:adr_inst _* comment? "\n"? {return i;}
    / i:adrp_inst _* comment? "\n"? {return i;}
    / i:aeor_inst _* comment? "\n"? {return i;}
    / i:and_inst _* comment? "\n"? {return i;}
    / i:asr_inst _* comment? "\n"? {return i;}
    / i:at_inst _* comment? "\n"? {return i;}
    / i:bcc_inst _* comment? "\n"? {return i;}
    / i:bfi_inst _* comment? "\n"? {return i;}
    / i:bfxil_inst _* comment? "\n"? {return i;}
    / i:bic_inst _* comment? "\n"? {return i;}
    / i:blr_inst _* comment? "\n"? {return i;}
    / i:bl_inst _* comment? "\n"? {return i;}
    / i:brk_inst _* comment? "\n"? {return i;}
    / i:br_inst _* comment? "\n"? {return i;}
    / i:b_inst _* comment? "\n"? {return i;}
    / i:casbh_inst _* comment? "\n"? {return i;}
    / i:casp_inst _* comment? "\n"? {return i;}
    / i:cas_inst _* comment? "\n"? {return i;}
    / i:cbnz_inst _* comment? "\n"? {return i;}
    / i:cbz_inst _* comment? "\n"? {return i;}
    / i:ccmn_inst _* comment? "\n"? {return i;}
    / i:ccmp_inst _* comment? "\n"? {return i;}
    / i:cinc_inst _* comment? "\n"? {return i;}
    / i:cinv_inst _* comment? "\n"? {return i;}
    / i:clrex_inst _* comment? "\n"? {return i;}
    / i:cls_inst _* comment? "\n"? {return i;}
    / i:clz_inst _* comment? "\n"? {return i;}
    / i:cmn_inst _* comment? "\n"? {return i;}
    / i:cmp_inst _* comment? "\n"? {return i;}
    / i:cneg_inst _* comment? "\n"? {return i;}
    / i:crc32cx_inst _* comment? "\n"? {return i;}
    / i:crc32cw_inst _* comment? "\n"? {return i;}
    / i:crc32c_inst _* comment? "\n"? {return i;}
    / i:crc32w_inst _* comment? "\n"? {return i;}
    / i:crc32x_inst _* comment? "\n"? {return i;}
    / i:crc32_inst _* comment? "\n"? {return i;}
    / i:csetm_inst _* comment? "\n"? {return i;}
    / i:cset_inst _* comment? "\n"? {return i;}
    / i:csel_inst _* comment? "\n"? {return i;}
    / i:csinc_inst _* comment? "\n"? {return i;}
    / i:csinv_inst _* comment? "\n"? {return i;}
    / i:csneg_inst _* comment? "\n"? {return i;}
    / i:dmb_inst _* comment? "\n"? {return i;}
    / i:dsb_inst _* comment? "\n"? {return i;}
    / i:eon_inst _* comment? "\n"? {return i;}
    / i:eor_inst _* comment? "\n"? {return i;}
    / i:eret_inst _* comment? "\n"? {return i;}
    / i:extr_inst _* comment? "\n"? {return i;}
    / i:hvc_inst _* comment? "\n"? {return i;}
    / i:isb_inst _* comment? "\n"? {return i;}
    / i:ldaobh_inst _* comment? "\n"? {return i;}
    / i:ldao_inst _* comment? "\n"? {return i;}
    / i:ldaxrbh_inst _* comment? "\n"? {return i;}
    / i:ldaxr_inst _* comment? "\n"? {return i;}
    / i:ldaxp_inst _* comment? "\n"? {return i;}
    / i:ldnp_inst _* comment? "\n"? {return i;}
    / i:ldpsw_inst _* comment? "\n"? {return i;}
    / i:ldp_inst _* comment? "\n"? {return i;}
    / i:ldtrsbh_inst _* comment? "\n"? {return i;}
    / i:ldtrsw_inst _* comment? "\n"? {return i;}
    / i:ldtrbh_inst _* comment? "\n"? {return i;}
    / i:ldtr_inst _* comment? "\n"? {return i;}
    / i:ldursbh_inst _* comment? "\n"? {return i;}
    / i:ldursw_inst _* comment? "\n"? {return i;}
    / i:ldurbh_inst _* comment? "\n"? {return i;}
    / i:ldur_inst _* comment? "\n"? {return i;}
    / i:lsl_inst _* comment? "\n"? {return i;}
    / i:lsr_inst _* comment? "\n"? {return i;}
    / i:madd_inst _* comment? "\n"? {return i;}
    / i:mneg_inst _* comment? "\n"? {return i;}
    / i:movk_inst _* comment? "\n"? {return i;}
    / i:movn_inst _* comment? "\n"? {return i;}
    / i:movz_inst _* comment? "\n"? {return i;}
    / i:mov_inst _* comment? "\n"? {return i;}
    / i:msub_inst _* comment? "\n"? {return i;}
    / i:msr_inst _* comment? "\n"? {return i;}
    / i:mrs_inst _* comment? "\n"? {return i;}
    / i:mul_inst _* comment? "\n"? {return i;}
    / i:mvn_inst _* comment? "\n"? {return i;}
    / i:neg_inst _* comment? "\n"? {return i;}
    / i:ngc_inst _* comment? "\n"? {return i;}
    / i:nop_inst _* comment? "\n"? {return i;}
    / i:orn_inst _* comment? "\n"? {return i;}
    / i:orr_inst _* comment? "\n"? {return i;}
    / i:prfm_inst _* comment? "\n"? {return i;}
    / i:rbit_inst _* comment? "\n"? {return i;}
    / i:rev32_inst _* comment? "\n"? {return i;}
    / i:rev16_inst _* comment? "\n"? {return i;}
    / i:rev_inst _* comment? "\n"? {return i;}
    / i:ror_inst _* comment? "\n"? {return i;}
    / i:ret_inst _* comment? "\n"? {return i;}
    / i:sbc_inst _* comment? "\n"? {return i;}
    / i:sdiv_inst _* comment? "\n"? {return i;}
    / i:sev_inst _* comment? "\n"? {return i;}
    / i:sevl_inst _* comment? "\n"? {return i;}
    / i:smaddl_inst _* comment? "\n"? {return i;}
    / i:smc_inst _* comment? "\n"? {return i;}
    / i:smnegl_inst _* comment? "\n"? {return i;}
    / i:smsubl_inst _* comment? "\n"? {return i;}
    / i:smulh_inst _* comment? "\n"? {return i;}
    / i:smull_inst _* comment? "\n"? {return i;}
    / i:staobh_inst _* comment? "\n"? {return i;}
    / i:stao_inst _* comment? "\n"? {return i;}
    / i:stlxrbh_inst _* comment? "\n"? {return i;}
    / i:stlxr_inst _* comment? "\n"? {return i;}
    / i:stlxp_inst _* comment? "\n"? {return i;}
    / i:stlrbh_inst _* comment? "\n"? {return i;}
    / i:stlr_inst _* comment? "\n"? {return i;}
    / i:sturbh_inst _* comment? "\n"? {return i;}
    / i:stur_inst _* comment? "\n"? {return i;}
    / i:sttrbh_inst _* comment? "\n"? {return i;}
    / i:sttr_inst _* comment? "\n"? {return i;}
    / i:stnp_inst _* comment? "\n"? {return i;}
    / i:stp_inst _* comment? "\n"? {return i;}
    / i:svc_inst _* comment? "\n"? {return i;}
    / i:susxtbh_inst _* comment? "\n"? {return i;}
    / i:sxtw_inst _* comment? "\n"? {return i;}
    / i:swpbh_inst _* comment? "\n"? {return i;}
    / i:swp_inst _* comment? "\n"? {return i;}
    / i:tbnz_inst _* comment? "\n"? {return i;}
    / i:tbz_inst _* comment? "\n"? {return i;} 
    / i:tst_inst _* comment? "\n"? {return i;}
    / i:udiv_inst _* comment? "\n"? {return i;}
    / i:umaddl_inst _* comment? "\n"? {return i;}
    / i:umnegl_inst _* comment? "\n"? {return i;}
    / i:umsubl_inst _* comment? "\n"? {return i;}
    / i:umulh_inst _* comment? "\n"? {return i;}
    / i:umull_inst _* comment? "\n"? {return i;}
    / i:wfe_inst _* comment? "\n"? {return i;}
    / i:wfi_inst _* comment? "\n"? {return i;}
    / i:yield_inst _* comment? "\n"? {return i;}
    / i:subfiz_inst _* comment? "\n"? {return i;}
    / i:subfx_inst _* comment? "\n"? {return i;}
    / i:sub_inst _* comment? "\n"? {return i;}


// ************************************************** ......................... ************************************************** \\    
// ************************************************** Instrucciones Aritméticas ************************************************** \\
// ************************************************** ......................... ************************************************** \\
arithmetic_instruction
    = i:adc_inst _* comment? "\n"? {return i;}
    / i:add_inst _* comment? "\n"? {return i;}
    / i:adr_inst _* comment? "\n"? {return i;}
    / i:adrp_inst _* comment? "\n"? {return i;}
    / i:cmn_inst _* comment? "\n"? {return i;}
    / i:cmp_inst _* comment? "\n"? {return i;}
    / i:madd_inst _* comment? "\n"? {return i;}
    / i:mneg_inst _* comment? "\n"? {return i;}
    / i:msub_inst _* comment? "\n"? {return i;}
    / i:mul_inst _* comment? "\n"? {return i;}
    / i:neg_inst _* comment? "\n"? {return i;}
    / i:ngc_inst _* comment? "\n"? {return i;}
    / i:sbc_inst _* comment? "\n"? {return i;}
    / i:sdiv_inst _* comment? "\n"? {return i;}
    / i:smaddl_inst _* comment? "\n"? {return i;}
    / i:smnegl_inst _* comment? "\n"? {return i;}
    / i:smsubl_inst _* comment? "\n"? {return i;}
    / i:smulh_inst _* comment? "\n"? {return i;}
    / i:smull_inst _* comment? "\n"? {return i;}
    / i:sub_inst _* comment? "\n"? {return i;}
    / i:udiv_inst _* comment? "\n"? {return i;}
    / i:umaddl_inst _* comment? "\n"? {return i;}
    / i:umnegl_inst _* comment? "\n"? {return i;}
    / i:umsubl_inst _* comment? "\n"? {return i;}
    / i:umulh_inst _* comment? "\n"? {return i;}
    / i:umull_inst _* comment? "\n"? {return i;}
// ************************************************** Suma con Acarreo (ADC{S}) ************************************************** \\
adc_inst
    = _* op:ADC c:cc? q:q? _ args:(rs64 comma rs64 comma rs64)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ARITHMETIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:ADC c:cc? q:q? _ args:(rs32 comma rs32 comma rs32)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ARITHMETIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
ADC
    = _* "adc"i ("s"i)? /*CASES: ADC, ADCS*/
    {const op = text().replaceAll(/\s/g, ''); if(op.toLowerCase() === 'adcs'){return createNode(TYPE.ADCS, op, '');} return createNode(TYPE.ADC, op, '');}
// ************************************************** Suma (ADD{S}) ************************************************** \\
add_inst
    = _* op:ADD c:cc? q:q? _ args:(rs64 comma rs64 comma (op2_arithmetic / rs64 / imm))
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ARITHMETIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:ADD c:cc? q:q? _ args:(rs32 comma rs32 comma (op2_arithmetic / rs32 / imm))
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ARITHMETIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
ADD
    = _* "add"i ("s"i)?/*CASES: ADD, ADDS*/
    {const op = text().replaceAll(/\s/g, ''); if(op.toLowerCase() === 'adds'){return createNode(TYPE.ADDS, op, '');} return createNode(TYPE.ADD, op, '');}
// ************************************************** Dirección de Etiqueta (ADR) ************************************************** \\
adr_inst
    = _* op:ADR c:cc? q:q? _ args:(rs64 comma rel)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ARITHMETIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
ADR
    = _* op:"adr"i {return createNode(TYPE.ADR, op, '');}
// ************************************************** Dirección de Página de Etiqueta (ADRP) ************************************************** \\
adrp_inst
    = _* op:ADRP c:cc? q:q? _ args:(rs64 comma rel)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ARITHMETIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
ADRP
    = _* op:"adrp"i {return createNode(TYPE.ADRP, op, '');}
// ************************************************** Comparar Negativo (CMN) ************************************************** \\
cmn_inst
    = _* op:CMN c:cc? q:q? _ args:(rs64 comma (op2_arithmetic / rs64 / imm))
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ARITHMETIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:CMN c:cc? q:q? _ args:(rs32 comma (op2_arithmetic / rs32 / imm))
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ARITHMETIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
CMN 
    = _* op:"cmn"i {return createNode(TYPE.CMN, op, '');}
// ************************************************** Comparar (CMP) ************************************************** \\
cmp_inst
    = _* op:CMP c:cc? q:q? _ args:(rs64 comma (op2_arithmetic / rs64 / imm))
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ARITHMETIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:CMP c:cc? q:q? _ args:(rs32 comma (op2_arithmetic / rs32 / imm))
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ARITHMETIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
CMP
    = _* op:"cmp"i {return createNode(TYPE.CMP, op, '');}
// ************************************************** Multiplicar y Sumar (MADD) ************************************************** \\
madd_inst
    = _* op:MADD c:cc? q:q? _ args:(rs64 comma rs64 comma rs64 comma rs64)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ARITHMETIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:MADD c:cc? q:q? _ args:(rs32 comma rs32 comma rs32 comma rs32)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ARITHMETIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
MADD
    = _* op:"madd"i {return createNode(TYPE.MADD, op, '');}
// ************************************************** Multiplicar y Negar (MNEG) ************************************************** \\
mneg_inst
    = _* op:MNEG c:cc? q:q? _ args:(rs64 comma rs64 comma rs64 comma rs64)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ARITHMETIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:MNEG c:cc? q:q? _ args:(rs32 comma rs32 comma rs32 comma rs32)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ARITHMETIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
MNEG    
    = _* op:"mneg"i {return createNode(TYPE.MNEG, op, '');}
// ************************************************** Multiplicar y Restar (MSUB) ************************************************** \\
msub_inst
    = _* op:MSUB c:cc? q:q? _ args:(rs64 comma rs64 comma rs64 comma rs64)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ARITHMETIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:MSUB c:cc? q:q? _ args:(rs32 comma rs32 comma rs32 comma rs32)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ARITHMETIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
MSUB
    = _* op:"msub"i {return createNode(TYPE.MSUB, op, '');}
// ************************************************** Multiplicar (MUL) ************************************************** \\
mul_inst
    = _* op:MUL c:cc? q:q? _ args:(rs64 comma rs64 comma rs64)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ARITHMETIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:MUL c:cc? q:q? _ args:(rs32 comma rs32 comma rs32)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ARITHMETIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
MUL
    = _* op:"mul"i {return createNode(TYPE.MUL, op, '');}
// ************************************************** Negar (NEG{S}) ************************************************** \\
neg_inst
    = _* op:NEG c:cc? q:q? _ args:(rs64 comma (op2_arithmetic / rs64 / imm))
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ARITHMETIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:NEG c:cc? q:q? _ args:(rs32 comma (op2_arithmetic / rs32 / imm))
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ARITHMETIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
NEG
    = _* "neg"i ("s"i)? /*CASES: NEG, NEGS*/
    {const op = text().replaceAll(/\s/g, ''); if(op.toLowerCase() === 'negs'){return createNode(TYPE.NEGS, op, '');} return createNode(TYPE.NEG, 'neg', '');}
// ************************************************** Negar con Acarreo (NGC{S}) ************************************************** \\
ngc_inst
    = _* op:NGC c:cc? q:q? _ args:(rs64 comma rs64)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ARITHMETIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:NGC c:cc? q:q? _ args:(rs32 comma rs32)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ARITHMETIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
NGC
    = _* "ngc"i ("s"i)? /*CASES: NGC, NGCS*/
    {const op = text().replaceAll(/\s/g, ''); if(op.toLowerCase() === 'ngcs'){return createNode(TYPE.NGCS, op, '');} return createNode(TYPE.NGC, 'ngc', '');}
// ************************************************** Restar con Acarreo (SBC{S}) ************************************************** \\
sbc_inst
    = _* op:SBC c:cc? q:q? _ args:(rs64 comma rs64 comma rs64)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ARITHMETIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:SBC c:cc? q:q? _ args:(rs32 comma rs32 comma rs32)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ARITHMETIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
SBC
    = _* "sbc"i ("s"i)? /*CASES: SBC, SBCS*/
    {const op = text().replaceAll(/\s/g, ''); if(op.toLowerCase() === 'sbcs'){return createNode(TYPE.SBCS, op, '');} return createNode(TYPE.SBC, 'sbc', '');}
// ************************************************** Dividir con Signo (SDIV) ************************************************** \\
sdiv_inst
    = _* op:SDIV c:cc? q:q? _ args:(rs64 comma rs64 comma rs64)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ARITHMETIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:SDIV c:cc? q:q? _ args:(rs32 comma rs32 comma rs32)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ARITHMETIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
SDIV
    = _* op:"sdiv"i {return createNode(TYPE.SDIV, op, '');}
// ************************************************** Multiplicar y Sumar Largo con Signo (SMADDL) ************************************************** \\
smaddl_inst
    = _* op:SMADDL c:cc? q:q? _ args:(rs64 comma rs32 comma rs32 comma rs64)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ARITHMETIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
SMADDL
    = _* op:"smaddl"i {return createNode(TYPE.SMADDL, op, '');}
// ************************************************** Multiplicar y Negar Largo con Signo (SMNEGL) ************************************************** \\
smnegl_inst
    = _* op:SMNEGL c:cc? q:q? _ args:(rs64 comma rs32 comma rs32)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ARITHMETIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
SMNEGL
    = _* op:"smnegl"i {return createNode(TYPE.SMNEGL, op, '');}
// ************************************************** Multiplicar y Restar Largo con Signo (SMSUBL) ************************************************** \\
smsubl_inst
    = _* op:SMSUBL c:cc? q:q? _ args:(rs64 comma rs32 comma rs32 comma rs64)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ARITHMETIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
SMSUBL
    = _* op:"smsubl"i {return createNode(TYPE.SMSUBL, op, '');}
// ************************************************** Multiplicar Alto con Signo (SMULH) ************************************************** \\
smulh_inst
    = _* op:SMULH c:cc? q:q? _ args:(rs64 comma rs64 comma rs64)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ARITHMETIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
SMULH
    = _* op:"smulh"i {return createNode(TYPE.SMULH, op, '');}
// ************************************************** Multiplicar Largo con Signo (SMULL) ************************************************** \\
smull_inst
    = _* op:SMULL c:cc? q:q? _ args:(rs64 comma rs32 comma rs32)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ARITHMETIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
SMULL
    = _* op:"smull"i {return createNode(TYPE.SMULL, op, '');}
// ************************************************** Restar (SUB{S}) ************************************************** \\
sub_inst
    = _* op:SUB c:cc? q:q? _ args:(rs64 comma rs64 comma (op2_arithmetic / rs64 / imm))
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ARITHMETIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:SUB c:cc? q:q? _ args:(rs32 comma rs32 comma (op2_arithmetic / rs32 / imm))
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ARITHMETIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
SUB
    = _* "sub"i ("s"i)? /*CASES: SUB, SUBS*/
    {const op = text().replaceAll(/\s/g, ''); if(op.toLowerCase() === 'subs'){return createNode(TYPE.SUBS, op, '');} return createNode(TYPE.SUB, 'sub', '');}
// ************************************************** Dividir con Signo (UDIV) ************************************************** \\
udiv_inst
    = _* op:UDIV c:cc? q:q? _ args:(rs64 comma rs64 comma rs64)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ARITHMETIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:UDIV c:cc? q:q? _ args:(rs32 comma rs32 comma rs32)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ARITHMETIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
UDIV
    = _* op:"udiv"i{return createNode(TYPE.UDIV, op, '');}
// ************************************************** Multiplicar y Sumar Largo con Signo (UMADDL) ************************************************** \\
umaddl_inst
    = _* op:UMADDL c:cc? q:q? _ args:(rs64 comma rs32 comma rs32 comma rs64)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ARITHMETIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
UMADDL
    = _* op:"umaddl"i {return createNode(TYPE.UMADDL, op, '');}
// ************************************************** Multiplicar y Negar Largo con Signo (UMNEGL) ************************************************** \\
umnegl_inst
    = _* op:UMNEGL c:cc? q:q? _ args:(rs64 comma rs32 comma rs32)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ARITHMETIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
UMNEGL
    = _* op:"umnegl"i {return createNode(TYPE.UMNEGL, op, '');}
// ************************************************** Multiplicar y Restar Largo con Signo (UMSUBL) ************************************************** \\
umsubl_inst
    = _* op:UMSUBL c:cc? q:q? _ args:(rs64 comma rs32 comma rs32 comma rs64)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ARITHMETIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
UMSUBL
    = _* op:"umsubl"i {return createNode(TYPE.UMSUBL, op, '');}
// ************************************************** Multiplicar Alto con Signo (UMULH) ************************************************** \\
umulh_inst
    = _* op:UMULH c:cc? q:q? _ args:(rs64 comma rs64 comma rs64)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ARITHMETIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
UMULH
    = _* op:"umulh"i {return createNode(TYPE.UMULH, op, '');}
// ************************************************** Multiplicar Largo con Signo (UMULL) ************************************************** \\
umull_inst
    = _* op:UMULL c:cc? q:q? _ args:(rs64 comma rs32 comma rs32)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ARITHMETIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
UMULL
    = _* op:"umull"i {return createNode(TYPE.UMULL, op, '');}
// ************************************************** .................................... ************************************************** \\
// ************************************************** Instrucciones de Manipulación de Bit ************************************************** \\
// ************************************************** .................................... ************************************************** \\
bit_manipulation_instruction
    = i:bfi_inst _* comment? "\n"? {return i;}
    / i:bfxil_inst _* comment? "\n"? {return i;}
    / i:cls_inst _* comment? "\n"? {return i;}
    / i:clz_inst _* comment? "\n"? {return i;}
    / i:extr_inst _* comment? "\n"? {return i;}
    / i:rbit_inst _* comment? "\n"? {return i;}
    / i:rev_inst _* comment? "\n"? {return i;}
    / i:rev16_inst _* comment? "\n"? {return i;}
    / i:rev32_inst _* comment? "\n"? {return i;}
    / i:subfiz_inst _* comment? "\n"? {return i;}
    / i:subfx_inst _* comment? "\n"? {return i;}
    / i:susxtbh_inst _* comment? "\n"? {return i;}
    / i:sxtw_inst _* comment? "\n"? {return i;}
// ************************************************** Inserción Campo de Bit (BFI) ************************************************** \\
bfi_inst
    = _* op:BFI c:cc? q:q? _ args:(rs64 comma rs64 comma imm comma imm)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('BIT MANIPULATION INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:BFI c:cc? q:q? _ args:(rs32 comma rs32 comma imm comma imm)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('BIT MANIPULATION INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
BFI
    = _* op:"bfi"i {return createNode(TYPE.BFI, op, '');}
// ************************************************** Inserción Extendida de Campo de Bit (BFXIL) ************************************************** \\
bfxil_inst
    = _* op:BFXIL c:cc? q:q? _ args:(rs64 comma rs64 comma imm comma imm)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('BIT MANIPULATION INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:BFXIL c:cc? q:q? _ args:(rs32 comma rs32 comma imm comma imm)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('BIT MANIPULATION INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
BFXIL
    = _* op:"bfxil"i {return createNode(TYPE.BFXIL, op, '');}
// ************************************************** Recuento de Bits en Claro ************************************************** \\
cls_inst
    = _* op:CLS c:cc? q:q? _ args:(rs64 comma rs64)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('BIT MANIPULATION INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:CLS c:cc? q:q? _ args:(rs32 comma rs32)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('BIT MANIPULATION INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
CLS
    = _* op:"cls"i {return createNode(TYPE.CLS, op, '');}
// ************************************************** Recuento de Bits en Cero ************************************************** \\
clz_inst
    = _* op:CLZ c:cc? q:q? _ args:(rs64 comma rs64)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('BIT MANIPULATION INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:CLZ c:cc? q:q? _ args:(rs32 comma rs32)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('BIT MANIPULATION INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
CLZ
    = _* op:"clz"i {return createNode(TYPE.CLZ, op, '');}
// ************************************************** Extracción de Campo de Bit (EXTR) ************************************************** \\
extr_inst
    = _* op:EXTR c:cc? q:q? _ args:(rs64 comma rs64 comma rs64 comma imm)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('BIT MANIPULATION INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:EXTR c:cc? q:q? _ args:(rs32 comma rs32 comma rs32 comma imm)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('BIT MANIPULATION INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
EXTR
    = _* op:"extr"i {return createNode(TYPE.EXTR, op, '');}
// ************************************************** Inversión de Bits de Registro (RBIT) ************************************************** \\
rbit_inst
    = _* op:RBIT c:cc? q:q? _ args:(rs64 comma rs64)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('BIT MANIPULATION INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:RBIT c:cc? q:q? _ args:(rs32 comma rs32)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('BIT MANIPULATION INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
RBIT
    = _* op:"rbit"i {return createNode(TYPE.RBIT, op, '');}
// ************************************************** Reversión de Bytes (REV) ************************************************** \\
rev_inst
    = _* op:REV c:cc? q:q? _ args:(rs64 comma rs64)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('BIT MANIPULATION INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:REV c:cc? q:q? _ args:(rs32 comma rs32)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('BIT MANIPULATION INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
REV
    = _* op:"rev"i {return createNode(TYPE.REV, op, '');}
// ************************************************** Reversión de Mitad de Palabra (16 bits) (REV16) ************************************************** \\
rev16_inst
    = _* op:REV16 c:cc? q:q? _ args:(rs64 comma rs64)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('BIT MANIPULATION INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:REV16 c:cc? q:q? _ args:(rs32 comma rs32)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('BIT MANIPULATION INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
REV16
    = _* op:"rev16"i {return createNode(TYPE.REV16, op, '');}
// ************************************************** Reversión de Mitad de Palabra (REV32) ************************************************** \\
rev32_inst
    = _* op:REV32 c:cc? q:q? _ args:(rs64 comma rs64)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('BIT MANIPULATION INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
REV32
    = _* op:"rev32"i {return createNode(TYPE.REV32, op, '');}
// ************************************************** Inserción de Ceros con Bandera ({S,U}BFIZ) ************************************************** \\
subfiz_inst
    = _* op:SUBFIZ c:cc? q:q? _ args:(rs64 comma rs64 comma imm comma imm)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('BIT MANIPULATION INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:SUBFIZ c:cc? q:q? _ args:(rs32 comma rs32 comma imm comma imm)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('BIT MANIPULATION INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
SUBFIZ
    = _* ("s"i/ "u"i) "bfiz"i /*CASES: SBFIZ, UBFIZ*/
    {const op = text().replaceAll(/\s/g, ''); if(op.toLowerCase() === 'sbfiz'){return createNode(TYPE.SBFIZ, op, '');} else{return createNode(TYPE.UBFIZ, op, '');}}
// ************************************************** Extracción de Campo de Bits con Bandera ({S,U}BFX) ************************************************** \\
subfx_inst
    = _* op:SUBFX c:cc? q:q? _ args:(rs64 comma rs64 comma imm comma imm)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('BIT MANIPULATION INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:SUBFX c:cc? q:q? _ args:(rs32 comma rs32 comma imm comma imm)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('BIT MANIPULATION INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
SUBFX
    = _* ("s"i/ "u"i) "bfx"i /*CASES: SBFX, UBFX*/
    {const op = text().replaceAll(/\s/g, ''); if(op.toLowerCase() === 'sbfx'){return createNode(TYPE.SBFX, op, '');} else{return createNode(TYPE.UBFX, op, '');}}
// ************************************************** Extensión con Signo o Cero ({S,U}XT{B,H}) ************************************************** \\
susxtbh_inst
    = _* op:SUSXTBH c:cc? q:q? _ args:(rs64 comma rs32)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('BIT MANIPULATION INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
SUSXTBH
    = _* ("s"i/ "u"i) "xt"i ("b"i/ "h"i) /*CASES: SXTB, UXTB, SXTH, UXTH*/
    {const op = text().replaceAll(/\s/g, ''); if(op.toLowerCase() === 'sxtb'){return createNode(TYPE.SXTB, op, '');} else if(op.toLowerCase() === 'uxtb'){return createNode(TYPE.UXTB, op, '');} 
    else if(op.toLowerCase() === 'sxth'){return createNode(TYPE.SXTH, op, '');} else{return createNode(TYPE.UXTH, op, '');}}
// ************************************************** Extensión con Signo de Palabra (SXTW) ************************************************** \\
sxtw_inst
    = _* op:SXTW c:cc? q:q? _ args:(rs64 comma rs32)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('BIT MANIPULATION INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
SXTW
    = _* op:"sxtw"i {return createNode(TYPE.SXTW, op, '');}
// ************************************************** ..................................... ************************************************** \\
// ************************************************** Instrucciones Lógicas y de Movimiento ************************************************** \\
// ************************************************** ..................................... ************************************************** \\
logicmov_inst
    = i:and_inst _* comment? "\n"? {return i;}
    / i:asr_inst _* comment? "\n"? {return i;}
    / i:bic_inst _* comment? "\n"? {return i;}
    / i:eon_inst _* comment? "\n"? {return i;}
    / i:eor_inst _* comment? "\n"? {return i;}
    / i:lsl_inst _* comment? "\n"? {return i;}
    / i:lsr_inst _* comment? "\n"? {return i;}
    / i:mov_inst _* comment? "\n"? {return i;}
    / i:movk_inst _* comment? "\n"? {return i;}
    / i:movn_inst _* comment? "\n"? {return i;}
    / i:movz_inst _* comment? "\n"? {return i;}
    / i:mvn_inst _* comment? "\n"? {return i;}
    / i:orn_inst _* comment? "\n"? {return i;}
    / i:orr_inst _* comment? "\n"? {return i;}
    / i:ror_inst _* comment? "\n"? {return i;}
    / i:tst_inst _* comment? "\n"? {return i;}
// ************************************************** Operación lógica AND (AND{S}) ************************************************** \\
and_inst
    = _* op:AND c:cc? q:q? _ args:(rs64 comma rs64 comma (op2_logic / rs64 / mask))
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LOGIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:AND c:cc? q:q? _ args:(rs32 comma rs32 comma (op2_logic / rs32 / mask))
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LOGIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
AND
    = _* "and"i ("s"i)? /*CASES: AND, ANDS*/
    {const op = text().replaceAll(/\s/g, ''); if(op.toLowerCase() === 'and'){return createNode(TYPE.AND, op, '');} else{return createNode(TYPE.ANDS, op, '');}}
// ************************************************** Desplazamiento Aritmético hacia la Derecha (ASR) ************************************************** \\
asr_inst
    = _* op:ASR c:cc? q:q? _ args:(rs64 comma rs64 comma (rs64 / imm))
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LOGIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:ASR c:cc? q:q? _ args:(rs32 comma rs32 comma (rs32 / imm))
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LOGIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
ASR
    = _* op:"asr"i {return createNode(TYPE.ASR, op, '');}
// ************************************************** Borrar Bits (BIC{S}) ************************************************** \\
bic_inst
    = _* op:BIC c:cc? q:q? _ args:(rs64 comma rs64 comma (op2_logic / rs64))
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LOGIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:BIC c:cc? q:q? _ args:(rs32 comma rs32 comma (op2_logic / rs32))
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LOGIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
BIC
    = _* "bic"i ("s"i)? /*CASES: BIC, BICS*/
    {const op = text().replaceAll(/\s/g, ''); if(op.toLowerCase() === 'bic'){return createNode(TYPE.BIC, op, '');} else{return createNode(TYPE.BICS, op, '');}}
// ************************************************** Operación lógica EOR-AND (EON) ************************************************** \\
eon_inst
    = _* op:EON c:cc? q:q? _ args:(rs64 comma rs64 comma (op2_logic / rs64))
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LOGIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:EON c:cc? q:q? _ args:(rs32 comma rs32 comma (op2_logic / rs32))
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LOGIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
EON
    = _* op:"eon"i {return createNode(TYPE.EON, op, '');}
// ************************************************** Operación lógica EOR (OR exclusivo) (EOR) ************************************************** \\
eor_inst
    = _* op:EOR c:cc? q:q? _ args:(rs64 comma rs64 comma (op2_logic / rs64 / mask))
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LOGIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:EOR c:cc? q:q? _ args:(rs32 comma rs32 comma (op2_logic / rs32 / mask))
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LOGIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
EOR
    = _* op:"eor"i {return createNode(TYPE.EOR, op, '');}
// ************************************************** Desplazamiento Lógico hacia la Izquierda (LSL) ************************************************** \\
lsl_inst
    = _* op:LSL c:cc? q:q? _ args:(rs64 comma rs64 comma (rs64 / imm))
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LOGIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:LSL c:cc? q:q? _ args:(rs32 comma rs32 comma (rs32 / imm))
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LOGIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
LSL
    = _* op:"lsl"i {return createNode(TYPE.LSL, op, '');}
// ************************************************** Desplazamiento Lógico hacia la Derecha (LSR) ************************************************** \\
lsr_inst
    = _* op:LSR c:cc? q:q? _ args:(rs64 comma rs64 comma (rs64 / imm))
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LOGIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:LSR c:cc? q:q? _ args:(rs32 comma rs32 comma (rs32 / imm))
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LOGIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
LSR
    = _* op:"lsr"i {return createNode(TYPE.LSR, op, '');}
// ************************************************** Movimiento de Datos (MOV) ************************************************** \\
mov_inst
    = _* op:MOV c:cc? q:q? _ args:(rs64 comma (rs64 / imm)) {return new Movment(loc?.line, loc?.column, op, args[0], args[2],null)}
    / _* op:MOV c:cc? q:q? _ args:(rs32 comma (rs32 / imm)) {return new Movment(loc?.line, loc?.column, op, args[0], args[2],null)}
MOV
    = _* op:"mov"i {return "mov";}
// ************************************************** Mover Inmediato con Complemento (MOVK) ************************************************** \\
movk_inst
    = _* op:MOVK c:cc? q:q? _ args:(rs64 comma imm (comma sh)?)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('MOV INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:MOVK c:cc? q:q? _ args:(rs32 comma imm (comma sh)?)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('MOV INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args);ins.addChild(arg); return ins;}
MOVK
    = _* op:"movk"i {return createNode(TYPE.MOVK, op, '');}
// ************************************************** Mover Inmediato Negativo (MOVN) ************************************************** \\
movn_inst
    = _* op:MOVN c:cc? q:q? _ args:(rs64 comma imm (comma sh)?)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('MOV INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:MOVN c:cc? q:q? _ args:(rs32 comma imm (comma sh)?)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('MOV INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
MOVN
    = _* op:"movn"i {return createNode(TYPE.MOVN, op, '');}
// ************************************************** Mover Inmediato con Ceros (MOVZ) ************************************************** \\
movz_inst
    = _* op:MOVZ c:cc? q:q? _ args:(rs64 comma imm (comma sh)?)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('MOV INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:MOVZ c:cc? q:q? _ args:(rs32 comma imm (comma sh)?)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('MOV INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
MOVZ
    = _* op:"movz"i {return createNode(TYPE.MOVZ, op, '');}
// ************************************************** NOT de Bits (MVN) ************************************************** \\
mvn_inst
    = _* MVN cc? q? _ rs64 comma (op2_logic / rs64)
    / _* op:MVN c:cc? q:q? _ args:(rs32 comma (op2_logic / rs32))
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LOGIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
MVN
    = _* op:"mvn"i {return createNode(TYPE.MVN, op, '');}
// ************************************************** Operación lógica OR-NOT (ORN) ************************************************** \\
orn_inst
    = _* op:ORN c:cc? q:q? _ args:(rs64 comma rs64 comma (op2_logic / rs64))
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LOGIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:ORN c:cc? q:q? _ args:(rs32 comma rs32 comma (op2_logic / rs32))
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LOGIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
ORN
    = _* op:"orn"i {return createNode(TYPE.ORN, op, '');}
// ************************************************** Operación lógica OR (ORR) ************************************************** \\
orr_inst
    = _* op:ORR c:cc? q:q? _ args:(rs64 comma rs64 comma (op2_logic / rs64 / mask))
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LOGIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:ORR c:cc? q:q? _ args:(rs32 comma rs32 comma (op2_logic / rs32 / mask))
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LOGIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
ORR
    = _* op:"orr"i {return createNode(TYPE.ORR, op, '');}
// ************************************************** Rotación hacia la Derecha (ROR) ************************************************** \\
ror_inst
    = _* op:ROR c:cc? q:q? _ args:(rs64 comma rs64 comma (rs64 / imm))
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LOGIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:ROR c:cc? q:q? _ args:(rs32 comma rs32 comma (rs32 / imm))
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LOGIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
ROR
    = _* op:"ror"i {return createNode(TYPE.ROR, op, '');}
// ************************************************** Test de bits (TST) ************************************************** \\
tst_inst
    = _* op:TST c:cc? q:q? _ args:(rs64 comma (op2_logic / rs64 / mask))
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LOGIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:TST c:cc? q:q? _ args:(rs32 comma (op2_logic / rs32 / mask))
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LOGIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
TST
    = _* op:"tst"i {return createNode(TYPE.TST, op, '');}
// ************************************************** ..................... ************************************************** \\
// ************************************************** Instrucciones de Rama ************************************************** \\
// ************************************************** ..................... ************************************************** \\
branch_inst
    = i:b_inst _* comment? "\n"? {return i;}
    / i:bcc_inst _* comment? "\n"? {return i;}
    / i:bl_inst _* comment? "\n"? {return i;}
    / i:blr_inst _* comment? "\n"? {return i;}
    / i:br_inst _* comment? "\n"? {return i;}
    / i:cbnz_inst _* comment? "\n"? {return i;}
    / i:cbz_inst _* comment? "\n"? {return i;}
    / i:ret_inst _* comment? "\n"? {return i;}
    / i:tbnz_inst _* comment? "\n"? {return i;}
    / i:tbz_inst _* comment? "\n"? {return i;}
// ************************************************** Rama Incondicional (B) ************************************************** \\
b_inst
    = _* op:B c:cc? q:q? _ a:rel
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('BRANCH INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChild(a); ins.addChild(arg); return ins;}
B
    = _* op:"b"i {return createNode(TYPE.B, op, '');}
// ************************************************** Rama Condicional (Bcc) ************************************************** \\
bcc_inst
    = _* op:BCC c:cc? q:q? _ a:rel
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('BRANCH INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChild(a); ins.addChild(arg); return ins;}
BCC
    = _* op:"bcc"i {return createNode(TYPE.BCC, op, '');}
// ************************************************** Rama con Enlace (BL) ************************************************** \\
bl_inst
    = _* op:BL c:cc? q:q? _ a:rel
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('BRANCH INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChild(a); ins.addChild(arg); return ins;}
BL
    = _* op:"bl"i {return createNode(TYPE.BL, op, '');}
// ************************************************** Rama con enlace Indirecto (BLR) ************************************************** \\
blr_inst
    = _* op:BLR c:cc? q:q? _ a:rs64
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('BRANCH INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChild(a); ins.addChild(arg); return ins;}
    / _* op:BLR c:cc? q:q? _ a:rs32
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('BRANCH INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChild(a); ins.addChild(arg); return ins;}
BLR
    = _* op:"blr"i {return createNode(TYPE.BLR, op, '');}
// ************************************************** Rama a Registro (BR) ************************************************** \\
br_inst
    = _* op:BR c:cc? q:q? _ a:rs64
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('BRANCH INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChild(a); ins.addChild(arg); return ins;}
    / _* op:BR c:cc? q:q? _ a:rs32
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('BRANCH INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChild(a); ins.addChild(arg); return ins;}
BR
    = _* op:"br"i {return createNode(TYPE.BR, op, '');}
// ************************************************** Compare y Rama si no es Cero (CBNZ) ************************************************** \\
cbnz_inst
    = _* op:CBNZ c:cc? q:q? _ args:(rs64 comma rel)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('BRANCH INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:CBNZ c:cc? q:q? _ args:(rs32 comma rel)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('BRANCH INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
CBNZ
    = _* op:"cbnz"i {return createNode(TYPE.CBNZ, op, '');}
// ************************************************** Compare y Rama si es Cero (CBZ) ************************************************** \\
cbz_inst
    = _* op:CBZ c:cc? q:q? _ args:(rs64 comma rel)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('BRANCH INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:CBZ c:cc? q:q? _ args:(rs32 comma rel)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('BRANCH INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
CBZ
    = _* op:"cbz"i {return createNode(TYPE.CBZ, op, '');}
// ************************************************** Retorno ************************************************** \\
ret_inst
    = _* op:RET c:cc? q:q? _ a:(rs64 / rs32)?
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('BRANCH INSTRUCTION'); ins.addChild(n);
    if(args){const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChild(a); ins.addChild(arg);} return ins;}
RET
    = _* op:"ret"i {return createNode(TYPE.RET, op, '');}
// **************************************************  Test bit y Rama si no es cero (TBNZ) ************************************************** \\
tbnz_inst
    = _* op:TBNZ c:cc? q:q? _ args:(rs64 comma imm comma rel)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('BRANCH INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:TBNZ c:cc? q:q? _ args:(rs32 comma imm comma rel)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('BRANCH INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
TBNZ
    = _* op:"tbnz"i {return createNode(TYPE.TBNZ, op, '');}
// ************************************************** Test bit y Rama si es cero (TBZ) ************************************************** \\
tbz_inst
    = _* op:TBZ c:cc? q:q? _ args:(rs64 comma imm comma rel)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('BRANCH INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:TBZ c:cc? q:q? _ args:(rs32 comma imm comma rel)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('BRANCH INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
TBZ
    = _* op:"tbz"i {return createNode(TYPE.TBZ, op, '');}
// ************************************************** ........................... ************************************************** \\
// ************************************************** Instrucciones Condicionales ************************************************** \\
// ************************************************** ........................... ************************************************** \\
condition_inst
    = i:ccmn_inst _* comment? "\n"? {return i;}
    / i:ccmp_inst _* comment? "\n"? {return i;}
    / i:cinc_inst _* comment? "\n"? {return i;}
    / i:cinv_inst _* comment? "\n"? {return i;}
    / i:cneg_inst _* comment? "\n"? {return i;}
    / i:cset_inst _* comment? "\n"? {return i;}
    / i:csetm_inst _* comment? "\n"? {return i;}
    / i:csinc_inst _* comment? "\n"? {return i;}
    / i:csinv_inst _* comment? "\n"? {return i;}
    / i:csneg_inst _* comment? "\n"? {return i;}
// ************************************************** Comparar y Condicionalmente Modificar (CCMN) ************************************************** \\
ccmn_inst
    = _* op:CCMN c:cc? q:q? _ args:(rs64 comma (rs64/ imm) comma imm comma _* cc)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('CONDITIONAL INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:CCMN c:cc? q:q? _ args:(rs32 comma (rs32 / imm) comma imm comma _* cc)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('CONDITIONAL INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
CCMN
    = _* op:"ccmn"i {return createNode(TYPE.CCMN, op, '');}
// ************************************************** Comparar y condicionalmente modificar (CCMP) ************************************************** \\
ccmp_inst
    = _* op:CCMP c:cc? q:q? _ args:(rs64 comma (rs64 / imm) comma imm comma _* cc)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('CONDITIONAL INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:CCMP c:cc? q:q? _ args:(rs32 comma (rs32 / imm) comma imm comma _* cc)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('CONDITIONAL INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
CCMP
    = _* op:"ccmp"i {return createNode(TYPE.CCMP, op, '');}
// ************************************************** Incremento condicional (CINC) ************************************************** \\
cinc_inst
    = _* op:CINC c:cc? q:q? _ args:(rs64 comma rs64 comma _* cc)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('CONDITIONAL INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:CINC c:cc? q:q? _ args:(rs32 comma rs32 comma _* cc)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('CONDITIONAL INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
CINC
    = _* op:"cinc"i {return createNode(TYPE.CINC, op, '');}
// ************************************************** Inversión condicional (CINV) ************************************************** \\
cinv_inst
    = _* op:CINV c:cc? q:q? _ args:(rs64 comma rs64 comma _* cc)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('CONDITIONAL INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:CINV c:cc? q:q? _ args:(rs32 comma rs32 comma _* cc)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('CONDITIONAL INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
CINV
    = _* op:"cinv"i {return createNode(TYPE.CINV, op, '');}
// ************************************************** Negación condicional (CNEG) ************************************************** \\
cneg_inst
    = _* op:CNEG c:cc? q:q? _ args:(rs64 comma rs64 comma _* cc)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('CONDITIONAL INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:CNEG c:cc? q:q? _ args:(rs32 comma rs32 comma _* cc)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('CONDITIONAL INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
CNEG
    = _* op:"cneg"i {return createNode(TYPE.CNEG, op, '');}
// ************************************************** Selección Condicional (CSEL) ************************************************** \\
csel_inst
    = _* op:CSEL c:cc? q:q? _ args:(rs64 comma rs64 comma rs64 comma _* cc)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('CONDITIONAL INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:CSEL c:cc? q:q? _ args:(rs32 comma rs32 comma rs32 comma _* cc)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('CONDITIONAL INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
CSEL
    = _* op:"csel"i {return createNode(TYPE.CSEL, op, '');}
// ************************************************** Establecer condicional (CSET) ************************************************** \\
cset_inst
    = _* op:CSET c:cc? q:q? _ args:(rs64 comma _* cc)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('CONDITIONAL INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:CSET c:cc? q:q? _ args:(rs32 comma _* cc)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('CONDITIONAL INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
CSET
    = _* op:"cset"i {return createNode(TYPE.CSET, op, '');}
// ************************************************** Establecer a máscara condicional (CSETM) ************************************************** \\
csetm_inst
    = _* op:CSETM c:cc? q:q? _ args:(rs64 comma _* cc)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('CONDITIONAL INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:CSETM c:cc? q:q? _ args:(rs32 comma _* cc)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('CONDITIONAL INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
CSETM
    = _* op:"csetm"i {return createNode(TYPE.CSETM, op, '');}
// ************************************************** Incremento condicional selectivo (CSINC) ************************************************** \\
csinc_inst
    = _* op:CSINC c:cc? q:q? _ args:(rs64 comma rs64 comma rs64 comma _* cc)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('CONDITIONAL INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:CSINC c:cc? q:q? _ args:(rs32 comma rs32 comma rs32 comma _* cc)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('CONDITIONAL INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
CSINC
    = _* op:"csinc"i {return createNode(TYPE.CSINC, op, '');}
// ************************************************** Inversión condicional selectiva (CSINV) ************************************************** \\
csinv_inst
    = _* op:CSINV c:cc? q:q? _ args:(rs64 comma rs64 comma rs64 comma _* cc)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('CONDITIONAL INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:CSINV c:cc? q:q? _ args:(rs32 comma rs32 comma rs32 comma _* cc)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('CONDITIONAL INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
CSINV
    = _* op:"csinv"i {return createNode(TYPE.CSINV, op, '');}
// ************************************************** Negación condicional selectiva (CSNEG) ************************************************** \\
csneg_inst
    = _* op:CSNEG c:cc? q:q? _ args:(rs64 comma rs64 comma rs64 comma _* cc)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('CONDITIONAL INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:CSNEG c:cc? q:q? _ args:(rs32 comma rs32 comma rs32 comma _* cc)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('CONDITIONAL INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
CSNEG
    = _* op:"csneg"i {return createNode(TYPE.CSNEG, op, '');}
// ************************************************** ....................................... ************************************************** \\
// ************************************************** Instrucciones de Carga y Almacenamiento ************************************************** \\
// ************************************************** ....................................... ************************************************** \\
loadstore_inst
    = i:ldp_inst _* comment? "\n"? {return i;}
    / i:ldpsw_inst _* comment? "\n"? {return i;}
    / i:ldur_inst _* comment? "\n"? {return i;}
    / i:ldurbh_inst _* comment? "\n"? {return i;}
    / i:ldursbh_inst _* comment? "\n"? {return i;}
    / i:ldursw_inst _* comment? "\n"? {return i;}
    / i:prfm_inst _* comment? "\n"? {return i;}
    / i:stp_inst _* comment? "\n"? {return i;}
    / i:stur_inst _* comment? "\n"? {return i;}
    / i:sturbh_inst _* comment? "\n"? {return i;}
// ************************************************** Cargar Par de Registros (LDP) ************************************************** \\
ldp_inst
    = _* op:LDP c:cc? q:q? _ args:(rs64 comma rs64 comma addr)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LOAD STORE INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:LDP c:cc? q:q? _ args:(rs32 comma rs32 comma addr)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LOAD STORE INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
LDP
    = _* op:"ldp"i {return createNode(TYPE.LDP, op, '');}
// ************************************************** Cargar Par de Palabras con Signo (LDPSW) ************************************************** \\
ldpsw_inst
    = _* op:LDPSW c:cc? q:q? _ args:(rs64 comma rs64 comma addr)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LOAD STORE INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:LDPSW c:cc? q:q? _ args:(rs32 comma rs32 comma addr)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LOAD STORE INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
LDPSW
    = _* op:"ldpsw"i {return createNode(TYPE.LDPSW, op, '');}
// ************************************************** Cargar Registro (LD{U}R) ************************************************** \\
ldur_inst
    = _* op:LDUR c:cc? q:q? _ args:(rs64 comma addr)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LOAD STORE INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:LDUR c:cc? q:q? _ args:(rs32 comma addr)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LOAD STORE INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
LDUR
    = _* "ld"i "u"i? "r"i /*CASES: LDUR, LDR'*/
    {const op = text().replaceAll(/\s/g, ''); if (op.toLowerCase() === 'ldur'){return createNode(TYPE.LDUR, op, '');} else if (op.toLowerCase() === 'ldr'){return createNode(TYPE.LDR, op, '');}} 
// ************************************************** Cargar Registro Byte, Cargar Registro Media Palabra (LD{U}R{B,H}) ************************************************** \\
ldurbh_inst
    = _* op:LDURBH c:cc? q:q? _ args:(rs64 comma addr)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LOAD STORE INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:LDURBH c:cc? q:q? _ args:(rs32 comma addr)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LOAD STORE INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
LDURBH
    = _* "ld"i "u"i? "r"i ("b"i/ "h"i) /*CASES: LDURB, LDRB, LDURH, LDRH'*/
    {const op = text().replaceAll(/\s/g, ''); if (op.toLowerCase() === 'ldurb'){return createNode(TYPE.LDURB, op, '');} else if (op.toLowerCase() === 'ldrh'){return createNode(TYPE.LDRH, op, '');} 
    else if (op.toLowerCase() === 'ldurh'){return createNode(TYPE.LDURH, op, '');} else if (op.toLowerCase() === 'ldrb'){return createNode(TYPE.LDRB, op, '');}}
// ************************************************** Cargar Registro Byte con Signo, Cargar Registro Media Palabra con Signo (LD{U}RS{B,H}) ************************************************** \\
ldursbh_inst
    = _* op:LDURSBH c:cc? q:q? _ args:(rs64 comma addr)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LOAD STORE INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:LDURSBH c:cc? q:q? _ args:(rs32 comma addr)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LOAD STORE INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
LDURSBH
    = _* "ld"i "u"i? "rs"i ("b"i/ "h"i) /*CASES: LDURSB, LDRSB, LDURSH, LDRSH'*/
    {const op = text().replaceAll(/\s/g, ''); if (op.toLowerCase() === 'ldursb'){return createNode(TYPE.LDURSB, op, '');} else if (op.toLowerCase() === 'ldrsh'){return createNode(TYPE.LDRSH, op, '');} 
    else if (op.toLowerCase() === 'ldursh'){return createNode(TYPE.LDURSH, op, '');} else if (op.toLowerCase() === 'ldrsb'){return createNode(TYPE.LDRSB, op, '');}}
// ************************************************** Cargar Registro Palabra con Signo (LD{U}RSW) ************************************************** \\
ldursw_inst
    = _* op:LDURSW c:cc? q:q? _ args:(rs64 comma addr)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LOAD STORE INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:LDURSW c:cc? q:q? _ args:(rs32 comma addr)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LOAD STORE INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
LDURSW
    = _* "ld"i "u"i? "rsw"i /*CASES: LDURSW, LDRSW'*/
    {const op = text().replaceAll(/\s/g, ''); if (op.toLowerCase() === 'ldursw'){return createNode(TYPE.LDURSW, op, '');} else if (op.toLowerCase() === 'ldrsw'){return createNode(TYPE.LDRSW, op, '');}}
// ************************************************** Precargar Datos (PRFM) ************************************************** \\
prfm_inst
    = _* op:PRFM c:cc? q:q? _ args:prfop
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LOAD STORE INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
PRFM  
    = _* op:"prfm"i {return createNode(TYPE.PRFM, op, '');}
// ************************************************** Almacenar Par de Registros (STP) ************************************************** \\
stp_inst
    = _* op:STP c:cc? q:q? _ args:(rs64 comma rs64 comma addr)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LOAD STORE INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:STP c:cc? q:q? _ args:(rs32 comma rs32 comma addr)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LOAD STORE INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
STP
    = _* op:"stp"i {return createNode(TYPE.STP, op, '');}
// ************************************************** Almacenar Registro (ST{U}R) ************************************************** \\
stur_inst
    = _* op:STUR c:cc? q:q? _ args:((rs64 / rs32) comma addr)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LOAD STORE INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
STUR
    = _* "st"i "u"i? "r"i /*CASES: STUR, STR'*/
    {const op = text().replaceAll(/\s/g, ''); if (op.toLowerCase() === 'stur'){return createNode(TYPE.STUR, op, '');} else if (op.toLowerCase() === 'str'){return createNode(TYPE.STR, op, '');}}
// ************************************************** Almacenar Registro Byte, Almacenar Registro Media Palabra (ST{U}R{B,H}) ************************************************** \\
sturbh_inst
    = _* op:STURBH c:cc? q:q? _ args:(rs64 comma addr)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LOAD STORE INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:STURBH c:cc? q:q? _ args:(rs32 comma addr)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LOAD STORE INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
STURBH
    = _* "st"i "u"i? "r"i ("b"i/ "h"i) /*CASES: STURB, STURH, STRB, STRH'*/
    {const op = text().replaceAll(/\s/g, ''); if (op.toLowerCase() === 'sturb'){return createNode(TYPE.STURB, op, '');} else if (op.toLowerCase() === 'sturh'){return createNode(TYPE.STURH, op, '');} 
    else if (op.toLowerCase() === 'strb'){return createNode(TYPE.STRB, op, '');} else if (op.toLowerCase() === 'strh'){return createNode(TYPE.STRH, op, '');}}
// ************************************************** ...................... ************************************************** \\
// ************************************************** Instrucciones Atómicas ************************************************** \\
// ************************************************** ...................... ************************************************** \\
atomic_inst
    = i:cas_inst _* comment? "\n"? {return i;}
    / i:casbh_inst _* comment? "\n"? {return i;}
    / i:casp_inst _* comment? "\n"? {return i;}
    / i:ldaobh_inst _* comment? "\n"? {return i;}
    / i:ldao_inst _* comment? "\n"? {return i;}
    / i:staobh_inst _* comment? "\n"? {return i;}
    / i:stao_inst _* comment? "\n"? {return i;}
    / i:swpbh_inst _* comment? "\n"? {return i;}
    / i:swp_inst _* comment? "\n"? {return i;}
// ************************************************** Comparar y almacenar condicionalmente (CAS{A}{L}) ************************************************** \\
cas_inst
    = _* op:CAS c:cc? q:q? _ args:(rs64 comma rs64 comma rs64 comma lbracket rs64 rbracket)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ATOMIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:CAS c:cc? q:q? _ args:(rs32 comma rs32 comma rs32 comma lbracket rs64 rbracket)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ATOMIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
CAS
    = _* "cas"i "a"i? "l"i? {return createNode(TYPE.CAS, text().replaceAll(/\s/g, ''), '');}
// ************************************************** Comparar y almacenar condicionalmente extendido (CASP{A}{L}{B,H}) ************************************************** \\
casbh_inst
    = op:CASPBH c:cc? q:q? _ args:(rs32 comma rs32 comma rs32 comma lbracket rs64 rbracket)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ATOMIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
CASPBH
    = _* "casp"i "a"i? "l"i? ("b"i/ "h"i)? {return createNode(TYPE.CASPBH, text().replaceAll(/\s/g, ''), '');}
// ************************************************** Comparar y almacenar condicionalmente con predicción (CAS{A}{L}P) ************************************************** \\
casp_inst
    = _* op:CASP c:cc? q:q? _ args:(rs64 comma rs64 comma rs64 comma rs64 comma lbracket rs64 rbracket)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ATOMIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:CASP c:cc? q:q? _ args:(rs32 comma rs32 comma rs32 comma rs32 comma lbracket rs64 rbracket)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ATOMIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
CASP
    = _* "cas" "a"i? "l"i? "p"i {return createNode(TYPE.CASP, text().replaceAll(/\s/g, ''), '');}
// ************************************************** Carga atómica con operación (LDao{A}{L}{B,H}) ************************************************** \\
ldaobh_inst
    = op:LDAOBH c:cc? q:q? _ args:(rs32 comma rs32 comma lbracket rs64 rbracket)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ATOMIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
LDAOBH
    = _* "ldao"i "a"i? "l"i? ("b"i/ "h"i)? {return createNode(TYPE.LDAOBH, text().replaceAll(/\s/g, ''), '');}
// ************************************************** Carga atómica y opera (LDao{A}{L}) ************************************************** \\
ldao_inst
    = op:LDAO c:cc? q:q? _ args:(rs64 comma rs64 comma lbracket rs64 rbracket)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ATOMIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / op:LDAO c:cc? q:q? _ args:(rs32 comma rs32 comma lbracket rs64 rbracket)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ATOMIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
LDAO
    = _* "ldao"i "a"i? "l"i? {return createNode(TYPE.LDAO, text().replaceAll(/\s/g, ''), '');}
// ************************************************** Almacenamiento atómico con operación (STao{A}{L}{B,H}) ************************************************** \\
staobh_inst
    = op:STAOBH c:cc? q:q? _ args:(rs32 comma rs32 comma lbracket rs64 rbracket)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ATOMIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
STAOBH
    = _* "stao"i "a"i? "l"i? ("b"i/ "h"i)? {return createNode(TYPE.STAOBH, text().replaceAll(/\s/g, ''), '');}
// ************************************************** Almacenamiento atómico y opera (STao{A}{L}) ************************************************** \\
stao_inst
    = op:STAO c:cc? q:q? _ args:(rs64 comma rs64 comma lbracket rs64 rbracket)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ATOMIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / op:STAO c:cc? q:q? _ args:(rs32 comma rs32 comma lbracket rs64 rbracket)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ATOMIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
STAO
    = _* "stao"i "a"i? "l"i? {return createNode(TYPE.STAO, text().replaceAll(/\s/g, ''), '');}
// ************************************************** Intercambio atómico extendido (SWP{A}{L}{B,H}) ************************************************** \\
swpbh_inst
    = op:SWPBH c:cc? q:q? _ args:(rs32 comma rs32 comma rs32 comma lbracket rs64 rbracket)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ATOMIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
SWPBH
    = _* "swp"i "a"i? "l"i? ("b"i/ "h"i)? {return createNode(TYPE.SWPBH, text().replaceAll(/\s/g, ''), '');}
// ************************************************** Intercambio atómico (SWP{A}{L}) ************************************************** \\
swp_inst
    = op:SWP c:cc? q:q? _ args:(rs64 comma rs64 comma rs64 comma lbracket rs64 rbracket)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ATOMIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / op:SWP c:cc? q:q? _ args:(rs32 comma rs32 comma rs32 comma lbracket rs64 rbracket)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ATOMIC INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
SWP
    = _* "swp"i "a"i? "l"i? {return createNode(TYPE.SWP, text().replaceAll(/\s/g, ''), '');}
// ************************************************** ........................... ************************************************** \\
// ************************************************** Instrucciones Atómicas (ao) ************************************************** \\
// ************************************************** ........................... ************************************************** \\
ao_inst
    = i:aadd_inst _* comment? "\n"? {return i;}
    / i:aclr_inst _* comment? "\n"? {return i;}
    / i:aeor_inst _* comment? "\n"? {return i;}
    / i:aset_inst _* comment? "\n"? {return i;}
// ************************************************** Sumar y obtener el máximo condiciona (ADD) ************************************************** \\
aadd_inst
    = _* op:AADD c:cc? q:q? _ args:(lbracket rs64 rbracket plus (rs64 / rs32))
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ATOMIC OPERATION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
AADD
    = _* op:"add"i {return createNode(TYPE.AADD, op, '');}
// ************************************************** Limpiar y obtener el mínimo condicional (CLR) ************************************************** \\
aclr_inst
    = _* op:ACLR c:cc? q:q? _ args:(lbracket rs64 rbracket y neg (rs64 / rs32))
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ATOMIC OPERATION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
ACLR
    = _* op:"clr"i {return createNode(TYPE.ACLR, op, '');}
// ************************************************** Operación XOR y obtener el máximo sin signo condicional (EOR) ************************************************** \\
aeor_inst
    = _* op:AEOR c:cc? q:q? _ args:(lbracket rs64 rbracket xor (rs64 / rs32))
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ATOMIC OPERATION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
AEOR
    = _* op:"eor"i {return createNode(TYPE.AEOR, op, '');}
// ************************************************** Establecer (SET) ************************************************** \\
aset_inst
    = _* op:ASET c:cc? q:q? _ args:(lbracket rs64 rbracket o (rs64 / rs32))
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('ATOMIC OPERATION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
ASET
    = _* op:"set"i {return createNode(TYPE.ASET, op, '');}
// ************************************************** ..................................... ************************************************** \\
// ************************************************** Instrucciones de Suma de Comprobación ************************************************** \\
// ************************************************** ..................................... ************************************************** \\
cheksum_inst
    = i:crc32_inst _* comment? "\n"? {return i;}
    / i:crc32w_inst _* comment? "\n"? {return i;}
    / i:crc32x_inst _* comment? "\n"? {return i;}
    / i:crc32c_inst _* comment? "\n"? {return i;}
    / i:crc32cw_inst _* comment? "\n"? {return i;}
    / i:crc32cx_inst _* comment? "\n"? {return i;}
// ************************************************** Cálculo de la suma de Comprobación (CRC32{B,H}) ************************************************** \\
crc32_inst
    = _* op:CRC32 c:cc? q:q? _ args:(rs32 comma rs32 comma rs32)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('CHECKSUM INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
CRC32
    = _* "crc32"i ("b"i / "h"i)? /*CASES: CRC32, CRC32B, CRC32H*/
    {const op = text().replaceAll(/\s/g, ''); if(op.toLowerCase() === 'crc32') {return createNode(TYPE.CRC32, op, '');} else if(op.toLowerCase() === 'crc32b')
    {return createNode(TYPE.CRC32B, op, '');} else {return createNode(TYPE.CRC32H, op, '');}}
// ************************************************** Cálculo de la suma de Comprobación con Palabra (CRC32W) ************************************************** \\
crc32w_inst
    = _* op:CRC32W c:cc? q:q? _ args:(rs32 comma rs32 comma rs32)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('CHECKSUM INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
CRC32W
    = _* op:"crc32w"i {return createNode(TYPE.CRC32W, op, '');}
// ************************************************** Cálculo de la suma de Comprobación Extendido (CRC32X) ************************************************** \\
crc32x_inst
    = _* op:CRC32X c:cc? q:q? _ args:(rs32 comma rs32 comma rs64)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('CHECKSUM INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
CRC32X
    = _* op:"crc32x"i {return createNode(TYPE.CRC32X, op, '');}
// ************************************************** Cálculo de la suma de Comprobación C (CRC32C{B,H}) ************************************************** \\
crc32c_inst
    = _* op:CRC32C c:cc? q:q? _ args:(rs32 comma rs32 comma rs32)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('CHECKSUM INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
CRC32C
    = _* "crc32c"i ("b"i / "h"i)? /*CASES: CRC32C, CRC32CB, CRC32CH*/
    {const op = text().replaceAll(/\s/g, ''); if(op.toLowerCase() === 'crc32c') {return createNode(TYPE.CRC32C, op, '');} else if(op.toLowerCase() === 'crc32cb') 
    {return createNode(TYPE.CRC32CB, op, '');} else {return createNode(TYPE.CRC32CH, op, '');}}
// ************************************************** Cálculo de la suma de Comprobación con Palabra (CRC32CW) ************************************************** \\
crc32cw_inst
    = _* op:CRC32CW c:cc? q:q? _ args:(rs32 comma rs32 comma rs32)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('CHECKSUM INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
CRC32CW
    = _* op:"crc32cw"i {return createNode(TYPE.CRC32CW, op, '');}
// ************************************************** Cálculo de la suma de Comprobación Extendido C (CRC32CX) ************************************************** \\
crc32cx_inst
    = _* op:CRC32CX c:cc? q:q? _ args:(rs32 comma rs32 comma rs64)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('CHECKSUM INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
CRC32CX
    = _* op:"crc32cx"i {return createNode(TYPE.CRC32CX, op, '');}
// ************************************************** .................................................... ************************************************** \\
// ************************************************** Instrucciones de Carga y Almacenamiento con Atributo ************************************************** \\
// ************************************************** .................................................... ************************************************** \\
loadstoreattr_inst
    = i:ldaxr_inst _* comment? "\n"? {return i;}
    / i:ldaxp_inst _* comment? "\n"? {return i;}
    / i:ldaxrbh_inst _* comment? "\n"? {return i;}
    / i:ldaxr_inst _* comment? "\n"? {return i;}
    / i:ldaxrbh_inst _* comment? "\n"? {return i;}
    / i:ldnp_inst _* comment? "\n"? {return i;}
    / i:ldtr_inst _* comment? "\n"? {return i;}
    / i:ldtrbh_inst _* comment? "\n"? {return i;}
    / i:ldtrsbh_inst _* comment? "\n"? {return i;}
    / i:ldtrsw_inst _* comment? "\n"? {return i;}
    / i:stlr_inst _* comment? "\n"? {return i;}
    / i:stlrbh_inst _* comment? "\n"? {return i;}
    / i:stlxp_inst _* comment? "\n"? {return i;}
    / i:stlxr_inst _* comment? "\n"? {return i;}
    / i:stlxrbh_inst _* comment? "\n"? {return i;}
    / i:stnp_inst _* comment? "\n"? {return i;}
    / i:sttr_inst _* comment? "\n"? {return i;}
    / i:sttrbh_inst _* comment? "\n"? {return i;}
// ************************************************** Carga exclusiva con atributos (LD{A}XP) ************************************************** \\
ldaxp_inst
    = _* op:LDAXP c:cc? q:q? _ args:(rs64 comma rs64 comma lbracket rs64 rbracket)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LS WITH ATT INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:LDAXP c:cc? q:q? _ args:(rs32 comma rs32 comma lbracket rs64 rbracket)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LS WITH ATT INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
LDAXP
    = _* "ld"i "a"i? "xp"i /*CASES: LDAXP, LDXP*/
    {const op = text().replaceAll(/\s/g, ''); if(op.toLowerCase() === 'ldaxp') {return createNode(TYPE.LDAXP, op, '');} else {return createNode(TYPE.LDXP, op, '');}}
// ************************************************** Carga exclusiva con registro extendido (LD{A}{X}R) ************************************************** \\
ldaxr_inst
    = _* op:LDAXR c:cc? q:q? _ args:((rs64 / rs32) comma lbracket rs64 rbracket)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LS WITH ATT INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
LDAXR
    = _* "ld"i "a"i? "x"i? "r"i /*CASES: LDR, LDAR, LDAXR, LDAXR*/
    {const op = text().replaceAll(/\s/g, ''); if(op.toLowerCase() === 'ldr') {return createNode(TYPE.LDR, op, '');} else if(op.toLowerCase() === 'ldar') {return createNode(TYPE.LDAR, op, '');} 
    else if(op.toLowerCase() === 'ldaxr') {return createNode(TYPE.LDAXR, op, '');} else {return createNode(TYPE.LDAXR, op, '');}}
// ************************************************** Carga exclusiva con registro extendido byte/media palabra (LD{A}{X}R{B,H}) ************************************************** \\
ldaxrbh_inst
    = _* op:LDAXRBH c:cc? q:q? _ args:(rs32 comma lbracket rs64 rbracket)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LS WITH ATT INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
LDAXRBH
    = _* "ld"i "a"i? "x"i? "r"i ("b"i/ "h"i)? /*CASES: LDAXRB, LDAXRH, LDRB, LDRH, LDR*/
    {const op = text().replaceAll(/\s/g, ''); if(op.toLowerCase() === 'ldaxrb') {return createNode(TYPE.LDAXRB, op, '');} else if(op.toLowerCase() === 'ldaxrh') {return createNode(TYPE.LDAXRH, op, '');} 
    else if(op.toLowerCase() === 'ldrb') {return createNode(TYPE.LDRB, op, '');} else if(op.toLowerCase() === 'ldrh') {return createNode(TYPE.LDRH, op, '');} else {return createNode(TYPE.LDR, op, '');}}
// ************************************************** Carga no post-incrementada (LDNP) ************************************************** \\
ldnp_inst
    = _* op:LDNP c:cc? q:q? _ args:(rs64 comma rs64 comma addr)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LS WITH ATT INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:LDNP c:cc? q:q? _ args:(rs32 comma rs32 comma addr)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LS WITH ATT INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
LDNP
    = _* op:"ldnp"i {return createNode(TYPE.LDNP, op, '');}
// ************************************************** Carga con traducción (LDTR) ************************************************** \\
ldtr_inst
    = _* op:LDTR c:cc? q:q? _ args:((rs64 / rs32) comma addr)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LS WITH ATT INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
LDTR
    = _* op:"ldtr"i {return createNode(TYPE.LDTR, op, '');}
// ************************************************** Carga con traducción byte/media palabra (LDTR{B,H}) ************************************************** \\
ldtrbh_inst
    = _* op:LDTRBH c:cc? q:q? _ args:(rs32 comma addr)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LS WITH ATT INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
LDTRBH
    = _* "ldtr"i ("b"i/ "h"i)? /*CASES: LDTRB, LDTRH, LDTR*/
    {const op = text().replaceAll(/\s/g, ''); if(op.toLowerCase() === 'ldtrb') {return createNode(TYPE.LDTRB, op, '');} else if (op.toLowerCase() === 'ldtrh') {return createNode(TYPE.LDTRH, op, '');} 
    else {return createNode(TYPE.LDTR, op, '');}}
// ************************************************** Carga con traducción y signo byte/media palabra (LDTRS{B,H}) ************************************************** \\
ldtrsbh_inst
    = _* op:LDTRSBH c:cc? q:q? _ args:((rs64 / rs32) comma addr)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LS WITH ATT INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
LDTRSBH
    = _* "ldtrs"i ("b"i/ "h"i)? /*CASES: LDTRSB, LDTRSH, LDTRS*/
    {const op = text().replaceAll(/\s/g, ''); if(op.toLowerCase() === 'ldtrsb') {return createNode(TYPE.LDTRSB, op, '');} else if (op.toLowerCase() === 'ldtrsh') {return createNode(TYPE.LDTRSH, op, '');} 
    else {return createNode(TYPE.LDTRS, op, '');}}

// ************************************************** Carga con traducción y signo palabra (LDTRSW) ************************************************** \\
ldtrsw_inst
    = _* op:LDTRSW c:cc? q:q? _ args:(rs64 comma addr)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LS WITH ATT INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
LDTRSW
    = _* op:"ldtrsw"i {return createNode(TYPE.LDTRSW, op, '');}
// ************************************************** Almacenamiento con registro de lectura exclusiva (STLR) ************************************************** \\
stlr_inst
    = _* op:STLR c:cc? q:q? _ args:((rs64 / rs32) comma lbracket rs64 rbracket)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LS WITH ATT INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
STLR
    = _* op:"stlr"i {return createNode(TYPE.STLR, op, '');}
// ************************************************** Almacenamiento con registro de lectura exclusiva byte/media palabra (STLR{B,H}) ************************************************** \\
stlrbh_inst
    = _* op:STLRBH c:cc? q:q? _ args:(rs32 comma lbracket rs64 rbracket)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LS WITH ATT INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
STLRBH
    = _* "stlr"i ("b"i/ "h"i)? /*CASES: STLRB, STLRH, STLR*/
    {const op = text().replaceAll(/\s/g, ''); if(op.toLowerCase() === 'stlrb') {return createNode(TYPE.STLRB, op, '');} else if (op.toLowerCase() === 'stlrh') {return createNode(TYPE.STLRH, op, '');} 
    else {return createNode(TYPE.STLR, op, '');}}
// ************************************************** Almacenamiento exclusivo con atributos (ST{L}XP) ************************************************** \\
stlxp_inst
    = _* op:STLXP c:cc? q:q? _ args:(rs32 comma rs64 comma rs64 comma lbracket rs64 rbracket)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LS WITH ATT INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:STLXP c:cc? q:q? _ args:(rs32 comma rs32 comma rs32 comma lbracket rs64 rbracket)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LS WITH ATT INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
STLXP
    = _* "st"i "l"i? "xp"i /*CASES: STLXP, STXP*/
    {const op = text().replaceAll(/\s/g, ''); if(op.toLowerCase() === 'stlxp') {return createNode(TYPE.STLXP, op, '');} else {return createNode(TYPE.STXP, op, '');}}
// ************************************************** Almacenamiento exclusivo con registro extendido (ST{L}XR) ************************************************** \\
stlxr_inst
    = _* op:STLXR c:cc? q:q? _ args:(rs32 comma (rs64 / rs32) comma lbracket rs64 rbracket)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LS WITH ATT INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
STLXR
    = _* "st"i "l"i? "xr"i /*CASES: STLXR, STXR*/
    {const op = text().replaceAll(/\s/g, ''); if(op.toLowerCase() === 'stlxr') {return createNode(TYPE.STLXR, op, '');} else {return createNode(TYPE.STXR, op, '');}}
// ************************************************** Almacenamiento exclusivo con registro extendido byte/media palabra (ST{L}XR{B,H}) ************************************************** \\
stlxrbh_inst
    = _* op:STLXRBH c:cc? q:q? _ args:(rs32 comma rs32 comma lbracket rs64 rbracket)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LS WITH ATT INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
STLXRBH
    = _* "st"i "l"i? "xr"i ("b"i/ "h"i) /*CASES: STLXRB, STLXRH, STXRB, STXRH*/
    {const op = text().replaceAll(/\s/g, ''); if(op.toLowerCase() === 'stlxrb') {return createNode(TYPE.STLXRB, op, '');} else if(op.toLowerCase() === 'stlxrh') {return createNode(TYPE.STLXRH, op, '');}
    else if(op.toLowerCase() === 'stxrb') {return createNode(TYPE.STXRB, op, '');} else {return createNode(TYPE.STXRH, op, '');}}
// ************************************************** Almacenamiento no post-incrementado (STNP) ************************************************** \\
stnp_inst
    = _* op:STNP c:cc? q:q? _ args:(rs64 comma rs64 comma addr)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LS WITH ATT INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:STNP c:cc? q:q? _ args:(rs32 comma rs32 comma addr)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LS WITH ATT INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
STNP
    = _* op:"stnp"i {return createNode(TYPE.STNP, op, '');}
// ************************************************** Almacenamiento con traducción (STTR) ************************************************** \\
sttr_inst
    = _* op:STTR c:cc? q:q? _ args:((rs64 / rs32) comma addr)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LS WITH ATT INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
STTR
    = _* op:"sttr"i {return createNode(TYPE.STTR, op, '');}
// ************************************************** Almacenamiento con traducción byte/media palabra (STTR{B,H}) ************************************************** \\
sttrbh_inst
    = _* op:STTRBH c:cc? q:q? _ args:(rs32 comma addr)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('LS WITH ATT INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
STTRBH
    = _* "sttr"i ("b"i/ "h"i) /*CASES: STTRB, STTRH, STTR*/
    {const op = text().replaceAll(/\s/g, ''); if(op.toLowerCase() === 'sttrb') {return createNode(TYPE.STTRB, op, '');} else if (op.toLowerCase() === 'sttrh') {return createNode(TYPE.STTRH, op, '');} 
    else {return createNode(TYPE.STTR, op, '');}}
// ************************************************** ........................ ************************************************** \\
// ************************************************** Instrucciones de Sistema ************************************************** \\
// ************************************************** ........................ ************************************************** \\
sys_inst
    = i:at_inst _* comment? "\n"? {return i;}
    / i:brk_inst _* comment? "\n"? {return i;}
    / i:clrex_inst _* comment? "\n"? {return i;}
    / i:dmb_inst _* comment? "\n"? {return i;}
    / i:dsb_inst _* comment? "\n"? {return i;}
    / i:eret_inst _* comment? "\n"? {return i;}
    / i:hvc_inst _* comment? "\n"? {return i;}
    / i:isb_inst _* comment? "\n"? {return i;}
    / i:mrs_inst _* comment? "\n"? {return i;}
    / i:msr_inst _* comment? "\n"? {return i;}
    / i:nop_inst _* comment? "\n"? {return i;}
    / i:sev_inst _* comment? "\n"? {return i;}
    / i:sevl_inst _* comment? "\n"? {return i;}
    / i:smc_inst _* comment? "\n"? {return i;}
    / i:svc_inst _* comment? "\n"? {return i;}
    / i:wfe_inst _* comment? "\n"? {return i;}
    / i:wfi_inst _* comment? "\n"? {return i;}
    / i:yield_inst _* comment? "\n"? {return i;}
// ************************************************** Atómico (AT) ************************************************** \\
at_inst
    = _* op:AT c:cc? q:q? _ args:(atsy comma rs64)
    {const n = createNode(TYPE.AT, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('SYS INSTRUCTION'); ins.addChild(n);
    const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
AT
    = _* op:"at"i {return createNode(TYPE.AT, op, '');}
// ************************************************** Punto de ruptura (BRK) ************************************************** \\
brk_inst
    = _* op:BRK c:cc? q:q? _ arg:imm
    {const n = createNode(TYPE.BRK,'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('SYS INSTRUCTION'); ins.addChild(n);
    const args = createNode(TYPE.ARGS, 'arg', ''); args.addChild(arg); ins.addChild(args); return ins;}
BRK
    = _* op:"brk"i {return createNode(TYPE.BRK, op, '');}
// ************************************************** Limpiar excepciones (CLREX {#i4}) ************************************************** \\
clrex_inst
    = _* op:CLREX c:cc? q:q? arg:imm?
    {const n = createNode(TYPE.CLREX, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('SYS INSTRUCTION'); ins.addChild(n);
    if(arg){const args = createNode(TYPE.ARGS, 'arg', ''); args.addChild(arg); ins.addChild(args);} return ins;}
CLREX
    = _* op:"clrex"i {return createNode(TYPE.CLREX, op, '');}
// ************************************************** Barrera de memoria de dominio (DMB) ************************************************** \\
dmb_inst
    = _* op:DMB c:cc? q:q? _ arg:barrierop
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('SYS INSTRUCTION'); ins.addChild(n);
    const args = createNode(TYPE.ARGS, 'arg', ''); args.addChild(arg); ins.addChild(args); return ins;}
DMB
    = _* op:"dmb"i {return createNode(TYPE.DMB, op, '');}
// ************************************************** Barrera de memoria de dominio (DSB) ************************************************** \\
dsb_inst
    = _* op:DSB c:cc? q:q? _ arg:barrierop
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('SYS INSTRUCTION'); ins.addChild(n);
    const args = createNode(TYPE.ARGS, 'arg', ''); args.addChild(arg); ins.addChild(args); return ins;}
DSB
    = _* op:"dsb"i {return createNode(TYPE.DSB, op, '');}
// ************************************************** Retorno de excepción (ERET) ************************************************** \\
eret_inst
    = _* op:ERET c:cc? q:q?
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('SYS INSTRUCTION'); ins.addChild(n); return ins;}
ERET
    = _* op:"eret"i {return createNode(TYPE.ERET, op, '');}
// ************************************************** Llamada hipervisor (HVC #16) ************************************************** \\
hvc_inst
    = _* op:HVC c:cc? q:q? arg:imm
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('SYS INSTRUCTION'); ins.addChild(n);
     const args = createNode(TYPE.ARGS, 'arg', ''); args.addChild(arg); ins.addChild(args); return ins;}
HVC
    = _* op:"hvc"i {return createNode(TYPE.HVC, op, '');}
// ************************************************** Barrera de sincronización de instrucciones (ISB {SY}) ************************************************** \\
isb_inst
    = _* op:ISB c:cc? q:q? arg:sy?
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('SYS INSTRUCTION'); ins.addChild(n);
    if(arg){const args = createNode(TYPE.ARGS, 'arg', '');  args.addChild(arg); ins.addChild(args);}  return ins;}
ISB
    = _* op:"isb"i {return createNode(TYPE.ISB, op, '');}
// ************************************************** Leer registro del sistema (MRS Xd, sysreg) ************************************************** \\
mrs_inst
    = _* op:MRS c:cc? q:q? _ args:(rs64 comma sysreg)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('SYS INSTRUCTION'); ins.addChild(n);
     const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
MRS
    = _* op:"mrs"i {return createNode(TYPE.MRS, op, '');}
// ************************************************** Escribir registro del sistema (MSR sysreg, Xn) ************************************************** \\
msr_inst
    = _* op:MSR c:cc? q:q? _ args:(sysregM comma imm)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('SYS INSTRUCTION'); ins.addChild(n);
     const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
    / _* op:MSR c:cc? q:q? _ args:(sysreg comma rs64)
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('SYS INSTRUCTION'); ins.addChild(n);
     const arg = createNode(TYPE.ARGS, 'args', ''); arg.addChildren_Values(args); ins.addChild(arg); return ins;}
MSR
    = _* op:"msr"i {return createNode(TYPE.MSR, op, '');}
// ************************************************** No operación (NOP) ************************************************** \\
nop_inst
    = _* op:NOP c:cc? q:q?
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('SYS INSTRUCTION'); ins.addChild(n); return ins;}
NOP
    = _* op:"nop"i {return createNode(TYPE.NOP, op, '');}
// ************************************************** Despertar evento (SEV) ************************************************** \\
sev_inst
    = _* op:SEV c:cc? q:q?
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('SYS INSTRUCTION'); ins.addChild(n); return ins;}
SEV
    = _* op:"sev"i {return createNode(TYPE.SEV, op, '');}
// ************************************************** SDespertar evento con retardo (SEVL) ************************************************** \\
sevl_inst
    = _* op:SEVL c:cc? q:q? 
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('SYS INSTRUCTION'); ins.addChild(n); return ins;}
SEVL
    = _* op:"sevl"i {return createNode(TYPE.SEVL, op, '');}
// ************************************************** Llamada segura al sistema (SMC #i16) ************************************************** \\
smc_inst
    = _* op:SMC c:cc? q:q? arg:imm
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('SYS INSTRUCTION'); ins.addChild(n);
     const args = createNode(TYPE.ARGS, 'arg', ''); args.addChild(arg); ins.addChild(args); return ins;}
SMC
    = _* op:"smc"i {return createNode(TYPE.SMC, op, '');}
// ************************************************** Llamada al supervisor (SVC) ************************************************** \\
svc_inst
    = _* op:SVC c:cc? q:q? arg:imm
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('SYS INSTRUCTION'); ins.addChild(n);
     const args = createNode(TYPE.ARGS, 'arg', ''); args.addChild(arg); ins.addChild(args); return ins;}
SVC
    = _* op:"svc"i {return createNode(TYPE.SVC, op, '');}
// ************************************************** Espera para evento (WFE) ************************************************** \\
wfe_inst
    = _* op:WFE c:cc? q:q?
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('SYS INSTRUCTION'); ins.addChild(n); return ins;}
WFE
    = _* op:"wfe"i {return createNode(TYPE.WFE, op, '');}
// ************************************************** Espera para interrupción (WFI) ************************************************** \\
wfi_inst
    = _* op:WFI c:cc? q:q?
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('SYS INSTRUCTION'); ins.addChild(n); return ins;}
WFI
    = _* op:"wfi"i {return createNode(TYPE.WFI, op, '');}
// ************************************************** Ceder (YIELD) ************************************************** \\
yield_inst
    = _* op:YIELD c:cc? q:q? 
    {const n = createNode(TYPE.OP, 'op', ''); n.addChild(op); if(c){n.addChild(c);} if(q){n.addChild(q)} const ins = createInstNode('SYS INSTRUCTION'); ins.addChild(n); return ins;}
YIELD
    = _* op:"yield"i {return createNode(TYPE.YIELD, op, '');}
// ************************************************** SH ************************************************** \\
sh
    = _* op:shift _* h:"#"i? i:imm {const n = createNode(TYPE.SH, 'sh', ''); n.addChild(op); if(h){const nh = createNode(TYPE.NUMERAL, h, ''); n.addChild(nh);} n.addChild(i); return n;}
// ************************************************** Operando 2 Aritmético ************************************************** \\    
op2_arithmetic
    = op:shift_op {const n = createNode(TYPE.OP2A, 'op2', ''); n.addChild(op); return n;}
    / op:extend_op {const n = createNode(TYPE.OP2A, 'op2', ''); n.addChild(op); return n;}
    / op:extend_xtx {const n = createNode(TYPE.OP2A, 'op2', ''); n.addChild(op); return n;}
// ************************************************** Operando 2 Lógico ************************************************** \\
op2_logic
    = op:shift_op {const n = createNode(TYPE.OP2L, 'op2', ''); n.addChild(op); return n;}
    / op:shift_ror_op {const n = createNode(TYPE.OP2L, 'op2', ''); n.addChild(op); return n;}

// ************************************************** Mask ************************************************** \\
mask
    = i:imm {const n = createNode(TYPE.MASK, 'mask', ''); n.addChild(i); return n;}
// ************************************************** ADDR ************************************************** \\
addr 
    = _* lbracket list:(rs64 comma (shift_op / extend_xtx_op / extend_op /rs64)) rbracket {const n = createNode(TYPE.ADDR, 'addr', ''); n.addChildren_Values(list); return n;}
    / _* list:(lbracket rs64 rbracket comma imm) {const n = createNode(TYPE.ADDR, 'addr', ''); n.addChildren_Values(list); return n;}
    / _* lbracket list:(rs64 (comma imm)? rbracket excl?) {const n = createNode(TYPE.ADDR, 'addr', ''); n.addChildren_Values(list); return n;}
    / _* rl:rel {const n = createNode(TYPE.ADDR, 'addr', ''); n.addChild(rl); return n;}
// ************************************************** OPERACIONES ************************************************** \\
shift_op "Operacion de Desplazamiento"
    = r:(rs64 / rs32) comma op:shift i:imm {const n = createNode(TYPE.OPSHIFT, 'Shift', ''); n.addChild(r); n.addChild(op); n.addChild(i); return n;}
shift_ror_op "Operacion de Rotación"
    = r:(rs64 / rs32) comma op:shift_ror i:imm {const n = createNode(TYPE.OPSHIFT, 'Shift', ''); n.addChild(r); n.addChild(op); n.addChild(i); return n;}
extend_op "Operacion de Extensión"
    = r:rs32 comma op:extend i:imm {const n = createNode(TYPE.OPEXTEND, 'Extend', ''); n.addChild(r); n.addChild(op); n.addChild(i); return n;}
extend_xtx_op "Operacion de Extensión"
    = r:rs64 comma op:extend_xtx i:imm {const n = createNode(TYPE.OPEXTEND, 'Extend', ''); n.addChild(r); n.addChild(op); n.addChild(i); return n;}
// ************************************************** Desplazamiento Relativo ************************************************** \\
rel
    = rl:constant {const n = createNode(TYPE.REL, 'rel', ''); n.addChild(rl); return n;}
    / rl:imm {const n = createNode(TYPE.REL, 'rel', ''); n.addChild(rl); return n;}
// ************************************************** PRFOP ************************************************** \\
prfop
    = _* "pldl1keep"i {return createNode(TYPE.PRFOP,text().replaceAll(/\s/g, ''), '');} // Prefetch to L1 cache and keep
    / _* "pld1strm"i {return createNode(TYPE.PRFOP,text().replaceAll(/\s/g, ''), '');} // Prefetch to L1 cache and stream
    / _* "pld2keep"i {return createNode(TYPE.PRFOP,text().replaceAll(/\s/g, ''), '');} // Prefetch to L2 cache and keep
    / _* "pld2strm"i {return createNode(TYPE.PRFOP,text().replaceAll(/\s/g, ''), '');} // Prefetch to L2 cache and stream
    / _* "pldl3keep"i {return createNode(TYPE.PRFOP,text().replaceAll(/\s/g, ''), '');} // Prefetch to L3 cache and keep
    / _* "pld3strm"i {return createNode(TYPE.PRFOP,text().replaceAll(/\s/g, ''), '');} // Prefetch to L3 cache and stream
    / _* "pstl1keep"i {return createNode(TYPE.PRFOP,text().replaceAll(/\s/g, ''), '');} // Prefetch to L1 cache and keep
    / _* "pst1strm"i {return createNode(TYPE.PRFOP,text().replaceAll(/\s/g, ''), '');} // Prefetch to L1 cache and stream
    / _* "pstl2keep"i {return createNode(TYPE.PRFOP,text().replaceAll(/\s/g, ''), '');} // Prefetch to L2 cache and keep
    / _* "pst2strm"i {return createNode(TYPE.PRFOP,text().replaceAll(/\s/g, ''), '');} // Prefetch to L2 cache and stream
    / _* "pstl3keep"i {return createNode(TYPE.PRFOP,text().replaceAll(/\s/g, ''), '');} // Prefetch to L3 cache and keep
    / _* "pst3strm"i {return createNode(TYPE.PRFOP,text().replaceAll(/\s/g, ''), '');} // Prefetch to L3 cache and stream
    / _* "pli"i {return createNode(TYPE.PRFOP,text().replaceAll(/\s/g, ''), '');} // Prefetch to instruction cache
// ************************************************** BARRIEROP ************************************************** \\
barrierop
    = _* "osh"i _* (comma _* "ld"i / comma _* "st"i)? {return createNode(TYPE.BARRIEROP, text().replaceAll(/\s/g, ''), '');} // Outer Shareable, All/Load/Store
    / _* "nsh"i _* (comma _* "ld"i / comma _* "st"i)? {return createNode(TYPE.BARRIEROP, text().replaceAll(/\s/g, ''), '');} // Non-shareable, All/Load/Store
    / _* "ish"i _* (comma _* "ld"i / comma _* "st"i)? {return createNode(TYPE.BARRIEROP, text().replaceAll(/\s/g, ''), '');} // Inner Shareable, All/Load/Store
    / _* "ld"i {return createNode(TYPE.BARRIEROP, text().replaceAll(/\s/g, ''), '');} // Full system, Load
    / _* "st"i {return createNode(TYPE.BARRIEROP, text().replaceAll(/\s/g, ''), '');} // Full system, Store
    / _* "sy"i {return createNode(TYPE.BARRIEROP, text().replaceAll(/\s/g, ''), '');} // Full system

// ************************************************** Tipos de Desplazamiento y Rotaciones ************************************************** \\
shift
    = _* "lsl"i {return createNode(TYPE.SHIFT, text().replaceAll(/\s/g, ''), '');} // Logical Shift Left
    / _* "lsr"i {return createNode(TYPE.SHIFT, text().replaceAll(/\s/g, ''), '');} // Logical Shift Right
    / _* "asr"i {return createNode(TYPE.SHIFT, text().replaceAll(/\s/g, ''), '');} // Arithmetic Shift Right
shift_ror
    = _* "ror"i {return createNode(TYPE.SHIFT, text().replaceAll(/\s/g, ''), '');} // Rotate Right
shift_rrx
    = _* "rrx"i {return createNode(TYPE.SHIFT, text().replaceAll(/\s/g, ''), '');} // Rotate Right Extended
// ************************************************** Tipos de Extensión ************************************************** \\
extend
    = _* "uxtb"i {return createNode(TYPE.EXTEND, text().replaceAll(/\s/g, ''), '');} // Unsigned Extend Byte
    / _* "uxth"i {return createNode(TYPE.EXTEND, text().replaceAll(/\s/g, ''), '');} // Unsigned Extend Halfword
    / _* "uxtw"i {return createNode(TYPE.EXTEND, text().replaceAll(/\s/g, ''), '');} // Unsigned Extend Word
    / _* "sxtb"i {return createNode(TYPE.EXTEND, text().replaceAll(/\s/g, ''), '');} // Signed Extend Byte
    / _* "sxth"i {return createNode(TYPE.EXTEND, text().replaceAll(/\s/g, ''), '');} // Signed Extend Halfword
    / _* "sxtw"i {return createNode(TYPE.EXTEND, text().replaceAll(/\s/g, ''), '');} // Signed Extend Word
extend_xtx
    = _* "sxtx"i {return createNode(TYPE.EXTEND, text().replaceAll(/\s/g, ''), '');} // Signed Extend Doubleword
    / _* "uxtx"i {return createNode(TYPE.EXTEND, text().replaceAll(/\s/g, ''), '');} // Unsigned Extend Doubleword
// ************************************************** Registros y Registros Especiales ************************************************** \\
rs64
    = r:r64 {return r;}
    / r:sp {return r;}
    / r:xzr {return r;}
    / r:pc {return r;}
    / r:spsr_el {return r;}
    / r:elr_el {return r;}
    / r:sp_el {return r;}
    / r:sps_el {return r;}
    / r:currentel {return r;}
    / r:daif {return r;}
    / r:nzcv {return r;}
    / r:fpcr {return r;}
    / r:fpsr {return r;}
rs32
    = r:r32 {return r;}
    / r:wsp {return r;}
    / r:wzr {return r;}
// ************************************************** Registros de propósito general 64 bits ************************************************** \\
r64 "Registro_64_Bits"
    = _* "x"i ("30" / [12][0-9] / [0-9]) {return new Register(loc?.line, loc?.column, "x"+int, 64);}
// ************************************************** Registros de propósito general 32 bits ************************************************** \\
r32 "Registro_32_Bits"
    = _* "w"i ("30" / [12][0-9] / [0-9]) {return new Register(loc?.line, loc?.column, "w"+int, 32);}
//  ************************************************** Apuntador de Pila ************************************************** \\
sp "Apuntador_Pila"
    = _* "sp"i {return createNode(TYPE.SP64, text().replaceAll(/\s/g, ''), '');}
wsp "Apuntador_Pila"
    = _* "wsp"i {return createNode(TYPE.SP32, text().replaceAll(/\s/g, ''), '');}
// ************************************************** Zero Register ************************************************** \\
xzr "Zero_Register"
    = _* "xzr"i {return createNode(TYPE.ZR64, text().replaceAll(/\s/g, ''), '');}
wzr "Zero_Register"
    = _* "wzr"i {return createNode(TYPE.ZR32, text().replaceAll(/\s/g, ''), '');}
// ************************************************** Program Counter ************************************************** \\
pc "Program_Counter"
    = _* "pc"i {return createNode(TYPE.PC, text().replaceAll(/\s/g, ''), '');}
// ************************************************** sysreg ************************************************** \\
sysreg
    = r:sps_el {return r;}
    / r:elr_el {return r;}
    / r:spsr_el {return r;}
    / r:sp_el {return r;}
    / r:currentel {return r;}
    / r:daif {return r;}
    / r:nzcv {return r;}
    / r:fpcr {return r;}
    / r:fpsr {return r;}
    / r:pmcr {return r;}
    / r:pmcntenset {return r;}
    / r:pmcntenclr {return r;}
    / r:pmcnten {return r;}
    / r:pmovsclr {return r;}
    / r:pmswinc {return r;}
    / r:pmselr {return r;}
    / r:pmceid0 {return r;}
    / r:pmceid1 {return r;}
    / r:pmceid {return r;}
    / r:pmccntr {return r;}
    / r:pmxevtyper {return r;}
    / r:pmxevcntr {return r;}
    / r:pmuserenr {return r;}
    / r:pmovsset {return r;}
    / r:pmintenset {return r;}
    / r:pmintenclr {return r;}
    / r:pmevcntr {return r;}
    / r:pmevtyper {return r;}
    / r:pmccfiltr {return r;}
sysregM
    = r:daifset {return r;}
    / r:daifclr {return r;}
    / r:spsel {return r;}

// ************************************************** Registros con propósito especial ************************************************** \\
atsy
    = "s1"i "2"i? "e"i [0-3]? ("r"i / "w"i)? {return createNode(TYPE.SYSREG, text().replaceAll(/\s/g, ''), '');}
sy
    = _* "sy"i {return createNode(TYPE.SY, text().replaceAll(/\s/g, ''), ''); return n;}
spsr_el "Saved_Program_Status_Register_For_Exception_Level"
    = _* "spsr_el"i [1-3] {return createNode(TYPE.SYSREG, text().replaceAll(/\s/g, ''), '');}
elr_el "Exception_Link_Register_For_Exception_Level"
    = _* "elr_el"i [1-3] {return createNode(TYPE.SYSREG, text().replaceAll(/\s/g, ''), '');}
sp_el "Stack_Pointer_For_Exception_Level"
    = _* "sp_el"i [0-2] {return createNode(TYPE.SYSREG, text().replaceAll(/\s/g, ''), '');}
sps_el "SP_Selection" 
    = _* "spsel"i [0-3] {return createNode(TYPE.SYSREG, text().replaceAll(/\s/g, ''), '');}
currentel "Current_Exception_Level"
    = _* "currentel"i {return createNode(TYPE.SYSREG, text().replaceAll(/\s/g, ''), '');}
daif "Interrupt_Mask_Bits"
    = _* "daif"i {return createNode(TYPE.SYSREG, text().replaceAll(/\s/g, ''), '');}
nzcv "Condition_Flag_Register"
    = _* "nzcv"i {return createNode(TYPE.SYSREG, text().replaceAll(/\s/g, ''), '');}
fpcr "Floating_Point_Control_Register"
    = _* "fpcr"i {return createNode(TYPE.SYSREG, text().replaceAll(/\s/g, ''), '');}
fpsr "Floating_Point_Status_Register"
    = _* "fpsr"i {return createNode(TYPE.SYSREG, text().replaceAll(/\s/g, ''), '');}
// ************************************************** Registros de monitores de rendimiento ************************************************** \\
pmcr "Performance_Monitoring_Control"
    = _* "pmcr_el0"i {return createNode(TYPE.SYSREG, text().replaceAll(/\s/g, ''), '');}
pmcntenset "Performance_Monitoring_Count_Enable_Set"
    = _* "pmcntenset_el0"i {return createNode(TYPE.SYSREG, text().replaceAll(/\s/g, ''), '');}
pmcntenclr "Performance_Monitoring_Count_Enable_Clear"
    = _* "pmcntenclr_el0"i {return createNode(TYPE.SYSREG, text().replaceAll(/\s/g, ''), '');}
pmcnten "Performance_Monitoring_Count_Enable"
    = _* "pmcnten_el0"i {return createNode(TYPE.SYSREG, text().replaceAll(/\s/g, ''), '');}
pmovsclr "Performance_Monitoring_Overflow_Status_Clear"
    = _* "pmovsclr_el0"i {return createNode(TYPE.SYSREG, text().replaceAll(/\s/g, ''), '');}
pmswinc "Performance_Monitoring_Software_Increment"
    = _* "pmswinc_el0"i {return createNode(TYPE.SYSREG, text().replaceAll(/\s/g, ''), '');}
pmselr "Performance_Monitoring_Select"
    = _* "pmselr_el0"i {return createNode(TYPE.SYSREG, text().replaceAll(/\s/g, ''), '');}
pmceid0 "Performance_Monitoring_Event_Identifier_0"
    = _* "pmceid0_el0"i {return createNode(TYPE.SYSREG, text().replaceAll(/\s/g, ''), '');}
pmceid1 "Performance_Monitoring_Event_Identifier_1"
    = _* "pmceid1_el0"i {return createNode(TYPE.SYSREG, text().replaceAll(/\s/g, ''), '');}
pmceid "Performance_Monitoring_Counter_Event_Type"
    = _* "pmceid_el0"i {return createNode(TYPE.SYSREG, text().replaceAll(/\s/g, ''), '');}
pmccntr "Performance_Monitoring_Counter"
    = _* "pmccntr_el0"i {return createNode(TYPE.SYSREG, text().replaceAll(/\s/g, ''), '');}
pmxevtyper "Performance_Monitoring_Event_Type"
    = _* "pmxevtyper_el0"i {return createNode(TYPE.SYSREG, text().replaceAll(/\s/g, ''), '');}
pmxevcntr "Performance_Monitoring_Event_Count"
    = _* "pmxevcntr_el0"i {return createNode(TYPE.SYSREG, text().replaceAll(/\s/g, ''), '');}
pmuserenr "Performance_Monitoring_User_Enable"
    = _* "pmuserenr_el0"i {return createNode(TYPE.SYSREG, text().replaceAll(/\s/g, ''), '');}
pmovsset "Performance_Monitoring_Overflow_Status_Set"
    = _* "pmovsset_el0"i {return createNode(TYPE.SYSREG, text().replaceAll(/\s/g, ''), '');}
pmintenset "Performance_Monitoring_Interrupt_Enable_Set"
    = _* "pmintenset_el0"i {return createNode(TYPE.SYSREG, text().replaceAll(/\s/g, ''), '');}
pmintenclr "Performance_Monitoring_Interrupt_Enable_Clear"
    = _* "pmintenclr_el0"i {return createNode(TYPE.SYSREG, text().replaceAll(/\s/g, ''), '');}
pmevcntr "Performance_Monitoring_Event_Count"
    = _* "pmevcntr"i ( [30]/ [1-2][0-9] / [0-9])? "_el0"i {return createNode(TYPE.SYSREG, text().replaceAll(/\s/g, ''), '');}
pmevtyper "Performance_Monitoring_Event_Type"
    = _* "pmevtyper"i ( [30]/ [1-2][0-9] / [0-9])? "_el0"i {return createNode(TYPE.SYSREG, text().replaceAll(/\s/g, ''), '');}
pmccfiltr "Performance_Monitoring_Cycle_Counter_Filter"
    = _* "pmccfiltr_el0"i {return createNode(TYPE.SYSREG, text(), '');}
daifset "Interrupt_Mask_Bits_Set"
    = _* "daifset"i {return createNode(TYPE.SYSREG, text().replaceAll(/\s/g, ''), '');}
daifclr "Interrupt_Mask_Bits_Clear"
    = _* "daifclr"i {return createNode(TYPE.SYSREG, text().replaceAll(/\s/g, ''), '');}
spsel "Stack_Pointer_Selection"
    = _* "spsel"i {return createNode(TYPE.SYSREG, text().replaceAll(/\s/g, ''), '');}
// ************************************************** Códigos Condicionales (cc) ************************************************** \\
cc "Códigos_Condicionales"
    = "eq"i {return createNode(TYPE.CC, text(), '');}// Equal
    / "ne"i {return createNode(TYPE.CC, text(), '');}// Not Equal
    / "cs"i {return createNode(TYPE.CC, text(), '');}// Carry Set, Unsigned Higher or Same
    / "hs"i {return createNode(TYPE.CC, text(), '');}// Carry Set, Unsigned Higher or Same
    / "cc"i {return createNode(TYPE.CC, text(), '');}// Carry Clear, Unsigned Lower
    / "lo"i {return createNode(TYPE.CC, text(), '');}// Carry Clear, Unsigned Lower
    / "mi"i {return createNode(TYPE.CC, text(), '');}// Minus, Negative
    / "pl"i {return createNode(TYPE.CC, text(), '');}// Plus, Positive or Zero
    / "vs"i {return createNode(TYPE.CC, text(), '');}// Overflow
    / "vc"i {return createNode(TYPE.CC, text(), '');}// No Overflow
    / "hi"i {return createNode(TYPE.CC, text(), '');}// Unsigned Higher
    / "ls"i {return createNode(TYPE.CC, text(), '');}// Unsigned Lower or Same
    / "ge"i {return createNode(TYPE.CC, text(), '');}// Signed Greater or Equal
    / "lt"i {return createNode(TYPE.CC, text(), '');}// Signed Less Than
    / "gt"i {return createNode(TYPE.CC, text(), '');}// Signed Greater Than
    / "le"i {return createNode(TYPE.CC, text(), '');}// Signed Less or Equal
    / "al"i {return createNode(TYPE.CC, text(), '');} // Always
// ************************************************** Sufijo de Condición (q) ************************************************** \\
q "Sufijo_Condición"
    = ".N"i {return createNode(TYPE.Q, text(), '');} // Meaning narrow
    / ".W"i {return createNode(TYPE.Q, text(), '');} // Meaning wide 
// ************************************************** Valor Inmediato************************************************** \\
imm
    = i:iident {return i;} 
    / i:ichar {return i;}
    / i:ibin {return i;}
    / i:ihex {return i;}
    / i:ioct {return i;}
    / i:iint {return i;}
iint "Inmediato Entero"
    = _* h:"#"i? s:("+"/"-")? v:int {let val = v; if(s) val*=-1; return new Immediate(loc?.line, loc?.column, val, type.INT);}
ihex "Inmediato Hexadecimal"
    = _* h:"#"i? v:hex {return new Immediate(loc?.line, loc?.column, v, type.HEXA);}
ioct "Inmediato Octal"
    = _* h:"#"i? v:oct {return new Immediate(loc?.line, loc?.column, v, type.OCTAL);}
ibin "Inmediato Binario"
    = _* h:"#"i? v:bin {return new Immediate(loc?.line, loc?.column, v, type.BIN);}
ichar "Inmediato Caracter"
    = _* h:"#"i? v:char {return new Immediate(loc?.line, loc?.column, v, type.CHAR);}
iident "Inmediato Identificador"
    = _* h:"#"i? v:identifier {return new Immediate(loc?.line, loc?.column, h, s);}
// ************************************************** Constante ************************************************** \\
constant "Constante"
    = _* e:"="? i:identifier {return new VarAccess(loc?.line, loc?.column, i);}
// ************************************************** Label ************************************************** \\
label "Label"
    = _* ([a-zA-Z_] [a-zA-Z0-9_]*) _* ":" {let val = text().replaceAll(/\s/g, ''); return val;}
// ************************************************** Identificador ************************************************** \\
identifier "Identificador"
    = _* [a-zA-Z_] [a-zA-Z0-9_]* {let val = text(); return val;}
// ************************************************** String ************************************************** \\
string "String"
    = _* "\"" [^"]* "\"" {let val = text().replaceAll(/\s/g, ''); return val;}
// ************************************************** Char ************************************************** \\
char "Char"
    = _* "'" [^'] "'" {let val = text().replaceAll(/\s/g, ''); return val;}
// ************************************************** Octal ************************************************** \\
oct "Octal"
    = _* "0o" [0-7]+ {let val = text().replaceAll(/\s/g, ''); return val;}
// ************************************************** Hexadecimal ************************************************** \\
hex "Hexadecimal"
    = _* "0x" [0-9a-fA-F]+ {let val = text().replaceAll(/\s/g, ''); return val;}
// ************************************************** Binario ************************************************** \\
bin "Binario"
    = _* "0b" [01]+ {let val = text().replaceAll(/\s/g, ''); return val}
// ************************************************** Entero ************************************************** \\
int "Entero"
    = _* [0-9]+ {let val = text().replaceAll(/\s/g, ''); return parseInt(text);}
// ************************************************** Línea en blanco ************************************************** \\
blank_line "Linea En Blanco"
    = _* comment? "\n" _* {return createNode(TYPE.BLANK, text(), '');}
// ************************************************** Comentarios ************************************************** \\
comment "Comentario"
    = c:lcomment {return c;}
    / c:mcomment {return c;}
lcomment "Comentario de Línea"
    = _* ("//" [^\n]*) {return null;}
    / _* (";" [^\n]*) {return null;}
mcomment "Comentario Multilínea"
    = _* "/*" ([^*] / [*]+ [^*/])* "*/"+ {return null;}
// ************************************************** Xor ************************************************** \\
xor "Xor"
    = _* s:"⊕"i {return createNode(TYPE.XOR, s, '');}
// ************************************************** Negación ************************************************** \\
neg "Negación"
    = _* s:"∼"i {return createNode(TYPE.NEG, s, '');}
// ************************************************** O ************************************************** \\
o "O"
    = _* s:"|"i {return createNode(TYPE.O, s, '');}
// ************************************************** Y ************************************************** \\
y "Y"
    = _* s:"&"i {return createNode(TYPE.Y, s, '');}
// ************************************************** Mas ************************************************** \\
plus "Mas"
    = _* s:"+"i {return createNode(TYPE.PLUS, s, '');}
// ************************************************** Llave Izq ************************************************** \\
lbracket "Llave Izq"
    = _* s:"["i {return createNode(TYPE.LB, s, '');}
// ************************************************** Llave Der ************************************************** \\
rbracket "Llave Der"
    = _* s:"]"i {return createNode(TYPE.RB, s, '');}
// ************************************************** Exclamación ************************************************** \\
excl "Exclamación"
    = _* s:"!"i {return createNode(TYPE.EXCLAMATION, s, '');}
// ************************************************** Coma ************************************************** \\
comma "Coma"
    = _* s:","{return createNode(TYPE.COMMA, s, '');}
// ************************************************** Espacios en blanco ************************************************** \\
_ "Espacio en blanco"
    = [ \t]+ {return null;}
// ************************************************** EOI ************************************************** \\
EOI "Fin de la Entrada"
    = _* !.
// ************************************************** Error ************************************************** \\
error "Error"
    = [^ "\n"]+ "\n"?  {console.log(text()); return text();}