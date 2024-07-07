
init 
    = ins:instructions {return new Root(ins); console.log("CONTENIDO INS") ;console.log(ins);} 
    
instructions "instructions"
    = ins:instruction* {return ins}  

instruction "instruction"
    =   glob:GLOBAL      __* { return glob}  
    / _ vr:variables     __* { return [...vr]}
    / _ lbl:label        __* { return lbl}
    / _ op:operate       __* {return op} 
    / _ j:jump           __* {return j}
    / _ chk:checksum_instructions __* {return chk}
    / _ sec:initSection  __*  { return sec}
    / _ comment          __*  { return}

GLOBAL "global"
    = __? text:("global"i / ".global"i / ".globl"i) id:id { 
        const loc = location()?.start;
        return new SystemCall(loc?.line, loc?.column, text, id)
    } 

initSection
	= ".section"i _ sec:sections {
        const loc = location()?.start;
        return new Section(loc?.line, loc?.column, sec)
    }
    / sec:sections { 
        const loc = location()?.start;
        return new Section(loc?.line, loc?.column, sec)
        }

sections
	= ".data"    {return "data";}
    / ".text"    {return "text";}
    / ".bss"     {return "bss";}
    / ".rodata"  {return "rodate";}
    / ".init"    {return "init";}
    / ".plt"     {return "plt";}
    / ".got"     {return "got";}
    / ".debug"   {return "debug";}
    / ".reldata" {return "reldata";}
    / "." id:id  {return id;}

jump "jump"
    = j:"BLR "i rn:numericalRegister
    {
        const loc = location()?.start;
        return new Jump(loc?.line, loc?.column, j, rn, null, null, 4)
    }
    / j:("BLT"i / "B.LT"i) ids:id
    {
        const loc = location()?.start;
        return new Jump(loc?.line, loc?.column, j, ids, null, null, 5)
    }
    / j:("BLS"i / "B.LS"i) ids:id
    {
        const loc = location()?.start;
        return new Jump(loc?.line, loc?.column, j, ids, null, null, 5)
    }
    / j:("BLO"i / "B.LO"i) ids:id
    {
        const loc = location()?.start;
        return new Jump(loc?.line, loc?.column, j, ids, null, null, 5)
    }
    / j:("BLE"i / "B.LE"i) ids:id
    {
        const loc = location()?.start;
        return new Jump(loc?.line, loc?.column, j, ids, null, null, 5)
    }
    / j:"BL "i ids:id
    {
        const loc = location()?.start;
        return new Jump(loc?.line, loc?.column, j, ids, null, null, 5)
    }
    / j:"BR "i rn:numericalRegister
    {
        const loc = location()?.start;
        return new Jump(loc?.line, loc?.column, j, rn, null, null, 4)
    }
    / j:"B"i  "."? ext:(condicional_codes)? _ ids:id
    {
        let b = j
        if(ext) b += ext 
        const loc = location()?.start;
        return new Jump(loc?.line, loc?.column, b, ids, null, null, 5)
    }
    / j:"CBNZ "i rn:numericalRegister comma ids:id
    {
        const loc = location()?.start;
        return new Jump(loc?.line, loc?.column, j, rn, null, ids, 4)
    }
    / j:"CBZ "i rn:numericalRegister comma ids:id
    {
        const loc = location()?.start;
        return new Jump(loc?.line, loc?.column, j, rn, null, ids, 4)
    }
    / j:"RET"i rn:(numericalRegister)?
    {
        const loc = location()?.start;
        return new Jump(loc?.line, loc?.column, j,rn,null, null, 1)
    }
    / j:"TBNZ "i rn:numericalRegister comma inm:inmediate comma ids:id
    {
        const loc = location()?.start;
        return new Jump(loc?.line, loc?.column, j, rn, inm, ids, 4)
    }
    / j:"TBZ "i rn:numericalRegister comma inm:inmediate comma ids:id
    {
        const loc = location()?.start;
        return new Jump(loc?.line, loc?.column, j, rn, inm, ids, 4)
    
    }

condicional_codes
    = "LT"i {return "LT"}
    / "LS"i {return "LS"}
    / "LE"i  {return "LE"}
    / "EQ"i {return "EQ"}
    / "NE"i {return "NE"}
    / "GT"i {return "GT"}
    / "CS"i {return "CS"}
    / "HS"i {return "HS"}
    / "CC"i {return "CC"}
    / "LO"i {return "LO"}
    / "MI"i {return "MI"}
    / "PL"i {return "PL"}
    / "VS"i {return "VS"}
    / "VC"i {return "VC"}
    / "HI"i {return "HI"}
    / "GE"i {return "GE"}
    / "LE"i {return "LE"}
    / "AL"i {return "AL"}

label "label"
    = label:id colon
    {
        const loc = location()?.start;
        return new Label(loc?.line, loc?.column, label)
    } 

operate "operate"
    = arith:arithmetic {return arith}
    / move:movement
    / load:load_sotre
    / log:logical
    / shift:shift_rotate
    / s:system_instructions
    / conditional
    / atomic
    / bit_manipulacion
    / atomic

arithmetic "arithmetic"
    = op:("ADD "i / "ADDS "i) rd:numericalRegister comma rn:numericalRegister comma op2:simple_operand {
        const loc = location()?.start;
        return new Operation(loc?.line, loc?.column, op, rn, op2, null, rd, 1)
    }
    / op:("ADC "i / "ADCS "i) rd:numericalRegister comma rn:numericalRegister comma rm:simple_operand{
        const loc = location()?.start;
        return new Operation(loc?.line, loc?.column, op, rn, rm, null, rd, 1)
    }
    / op:"ADRP "i xd:numericalRegister comma rel:id{
        const loc = location()?.start;
        return new Operation(loc?.line, loc?.column, op, rel, null, null, xd, 2)
    }
    / op:"ADR "i xd:numericalRegister comma rel:id{
        const loc = location()?.start;
        return new Operation(loc?.line, loc?.column, op, rel, null, null, xd, 2)
    }
    / op:"CMN "i rd:numericalRegister comma op2:simple_operand{
        const loc = location()?.start;
        return new Operation(loc?.line, loc?.column, op, rd, op2, null, null, 1)
    }
    / op:"CMP "i  rd:numericalRegister comma op2:simple_operand{
        const loc = location()?.start;
        return new Operation(loc?.line, loc?.column, op, rd, op2, null, null, 1)
    }
    / op:"MADD "i rd:numericalRegister comma rn:numericalRegister comma rm:numericalRegister comma ra:numericalRegister{
        const loc = location()?.start;
        return new Operation(loc?.line, loc?.column, op, rn, rm, ra, rd, 4)
    }
    / op:"MNEG "i rd:numericalRegister comma rn:numericalRegister comma rm:numericalRegister{
        const loc = location()?.start;
        return new Operation(loc?.line, loc?.column, op, rn, rm, null, rd, 4)
    }
    / op:"MSUB "i rd:numericalRegister comma rn:numericalRegister comma rm:numericalRegister comma ra:numericalRegister{
        const loc = location()?.start;
        return new Operation(loc?.line, loc?.column, op, rn, rm, ra, rd, 4)
    }
    / op:"MUL "i  rd:numericalRegister comma rn:numericalRegister comma rm:numericalRegister{
        const loc = location()?.start;
        return new Operation(loc?.line, loc?.column, op, rn, rm, null, rd, 4)
    }
    / op:("NEG "i / "NEGS "i) rd:numericalRegister comma op2:simple_operand{
        const loc = location()?.start;
        return new Operation(loc?.line, loc?.column, op, op2, null, null, rd, 3)
    }
    / op:("NGC "i / "NGCS "i) rd:numericalRegister comma rm:numericalRegister{
        const loc = location()?.start;
        return new Operation(loc?.line, loc?.column, op, rm, null, null, rd, 4)
    }
    / op:("SBC "i / "SBCS "i) rd:numericalRegister comma rn:numericalRegister comma rm:numericalRegister{
        const loc = location()?.start;
        return new Operation(loc?.line, loc?.column, op, rn, rm, null, rd, 4)
    }
    / op:"SDIV "i rd:numericalRegister comma rn:numericalRegister comma rm:numericalRegister{
        const loc = location()?.start;
        return new Operation(loc?.line, loc?.column, op, rn, rm, null, rd, 4)
    }
    / op:"SMADDL "i rd:numericalRegister comma wn:numericalRegister comma wm:numericalRegister comma xa:numericalRegister{
        const loc = location()?.start;
        return new Operation(loc?.line, loc?.column, op, wn, wm, xa, rd, 4)
    }
    / op:"SMNEGL "i rd:numericalRegister comma wn:numericalRegister comma wm:numericalRegister{
        const loc = location()?.start;
        return new Operation(loc?.line, loc?.column, op, wn, wm, null, rd, 4)
    }
    / op:"SMSUBL "i rd:numericalRegister comma wn:numericalRegister comma wm:numericalRegister comma xa:numericalRegister{
        const loc = location()?.start;
        return new Operation(loc?.line, loc?.column, op, wn, wm, xa, rd, 4)
    }
    / op:"SMULH "i xd:numericalRegister comma xn:numericalRegister comma xm:numericalRegister{
        const loc = location()?.start;
        return new Operation(loc?.line, loc?.column, op, xn, xm, null, xd, 4)
    }
    / op:"SMULL "i xd:numericalRegister comma xn:numericalRegister comma xm:numericalRegister{
        const loc = location()?.start;
        return new Operation(loc?.line, loc?.column, op, xn, xm, null, xd, 4)
    }
    / op:("SUB "i / "SUBS "i)  rd:numericalRegister comma rn:numericalRegister comma op2:simple_operand{
        const loc = location()?.start;
        return new Operation(loc?.line, loc?.column, op, rn, op2, null, rd, 1)
    }
    / op:"UDIV "i rd:numericalRegister comma rn:numericalRegister comma rm:numericalRegister{
        const loc = location()?.start;
        return new Operation(loc?.line, loc?.column, op, rn, rm, null, rd, 4)
    }
    / op:"UMADDL "i xd:numericalRegister comma wn:numericalRegister comma wm:numericalRegister comma xa:numericalRegister{
        const loc = location()?.start;
        return new Operation(loc?.line, loc?.column, op, wn, wm, xa, xd, 4)
    }
    / op:"UMNEGL "i xd:numericalRegister comma wn:numericalRegister comma wm:numericalRegister{
        const loc = location()?.start;
        return new Operation(loc?.line, loc?.column, op, wn, wm, null, xd, 4)
    }
    / op:"UMSUBL "i xd:numericalRegister comma wn:numericalRegister comma wm:numericalRegister comma xa:numericalRegister{
        const loc = location()?.start;
        return new Operation(loc?.line, loc?.column, op, wn, wm, xa, xd, 4)
    }
    / op:"UMULH "i xd:numericalRegister comma wn:numericalRegister comma wm:numericalRegister{
        const loc = location()?.start;
        return new Operation(loc?.line, loc?.column, op, wn, wm, null, xd, 4)
    }
    / op:"UMULL "i xd:numericalRegister comma wn:numericalRegister comma wm:numericalRegister{
        const loc = location()?.start;
        return new Operation(loc?.line, loc?.column, op, wn, wm, null, xd, 4)
    }

movement "movement"
    = mov:"FMOV "i rd:numericalRegister comma i:(numericalRegister / inmediate)
    {
        const loc = location()?.start;
        return new Movment(loc?.line, loc?.column, mov, rd, i,null)
    }
    / mov:"MOVK "i rd:numericalRegister comma inm:inmediate sh:(comma _ "LSL "i inmediate)?
    {
        const loc = location()?.start;
        return new Movment(loc?.line, loc?.column, mov, rd, inm, sh === undefined ? null : new ShiftRotate(loc?.line, loc?.column, "LSL", null, inm, sh[3],1))
    }
    / mov:"MOVN "i rd:numericalRegister comma inm:inmediate sh:(comma _ "LSL "i inmediate)?
    {
        const loc = location()?.start;
        return new Movment(loc?.line, loc?.column, mov, rd, inm, sh === undefined ? null : new ShiftRotate(loc?.line, loc?.column, "LSL", null, inm, sh[3],1))
    }
    / mov:"MOVZ "i rd:numericalRegister comma inm:inmediate sh:(comma _ "LSL "i inmediate)?
    {
        const loc = location()?.start;
        return new Movment(loc?.line, loc?.column, mov, rd, inm, sh === undefined ? null : new ShiftRotate(loc?.line, loc?.column, "LSL", null, inm, sh[3],1))
    }
    / mov:"MOV "i  rd:numericalRegister comma i:(inmediate)
    {
        const loc = location()?.start;
        return new Movment(loc?.line, loc?.column, mov, rd, i,null)
    
    }
    / mov:"MOV "i  rd:numericalRegister comma i:(numericalRegister)
    {
        const loc = location()?.start;
        return new Movment(loc?.line, loc?.column, mov, rd, i,null)
    
    }

load_sotre "load_sotre"
    = ls:"LDPSW "i xt:numericalRegister comma xt2:numericalRegister  comma add:memory_operand
    {
        const loc = location()?.start;
        return new LoadStore(loc?.line, loc?.column, ls, xt, xt2, null, add)
    }
    / "LD"i b:"U"i? "RSW"i " "  rt:numericalRegister comma add:memory_operand
    {
        let ls = "LD"
        if (b != null && b!= undefined) {
            ls += "U"
        }
        ls += "RSW"
        const loc = location()?.start;
        return new LoadStore(loc?.line, loc?.column, ls, rt, null, null, add)
    }
    / "LD"i a:"U"i? "RS"i b:("B"i / "H"i)? " "  rt:numericalRegister comma add:memory_operand
    {
        let ls = "LD"
        if (a != null && a!= undefined) {
            ls += "U"
        }
        ls += "RS"
        if (b != null && b!= undefined) {
            ls += b
        }
        const loc = location()?.start;
        return new LoadStore(loc?.line, loc?.column, ls, rt, null, null, add)
    }
    / "LD"i a:"U"i? "R"i b:("B"i / "H"i)?  " "  rt:numericalRegister comma add:memory_operand 
    {
        let ls = "LD"
        if (a != null && a!= undefined) {
            ls += "U"
        }
        ls += "R"
        if (b != null && b!= undefined) {
            ls += b
        }
        const loc = location()?.start;
        return new LoadStore(loc?.line, loc?.column, ls, rt, null, null, add)
    }
    / ls:"LDP "i  rt:numericalRegister comma rt2:numericalRegister comma add:memory_operand
    {
        const loc = location()?.start;
        return new LoadStore(loc?.line, loc?.column, ls, rt, rt2, null, add)
    }
    / "LD"i a:"A"i? "XP "i  rt:numericalRegister comma rt2:numericalRegister comma xn:memory_operand
    {
        let ls = "LD"
        if (a != null && a!= undefined) {
            ls += "A"
        }
        ls += "XP"
        const loc = location()?.start;
        return new LoadStore(loc?.line, loc?.column, ls, rt, rt2,null,  xn)
    }
    / "LD"i a:"A"i? b:"X"i? "R"i c:("B"i / "H"i)?  " "  rt:numericalRegister comma xn:memory_operand
    {
        let ls = "LD"
        if (a != null && a!= undefined) {
            ls += "A"
        }
        if (b != null && b!= undefined) {
            ls += "X"
        }
        ls += "R"
        if (c != null && c!= undefined) {
            ls += c
        }
        const loc = location()?.start;
        return new LoadStore(loc?.line, loc?.column, ls, rt, null,null,  xn)
    }
    / ls:"LDNP "i rt:numericalRegister comma rt2:numericalRegister comma xn:memory_operand
    {
        const loc = location()?.start;
        return new LoadStore(loc?.line, loc?.column, "LDNP", rt, rt2,null,  xn)
    }
    / "LDTR"i a:("B"i / "H"i)? " " rt:numericalRegister comma xn:memory_operand
    {
        let ls = "LDTR"
        if (a != null && a!= undefined) {
            ls += a
        }
        const loc = location()?.start;
        return new LoadStore(loc?.line, loc?.column, ls, rt, null,null,  xn)
    }
    / "LDTRS"i a:("B"i / "H"i)? " " rt:numericalRegister comma xn:memory_operand
    {
        let ls = "LDTRS"
        if (a != null && a!= undefined) {
            ls += a
        }
        const loc = location()?.start;
        return new LoadStore(loc?.line, loc?.column, ls, rt, null,null,  xn)
    }
    / ls:"LDTRSW "i xt:numericalRegister comma xn:memory_operand
    {
        const loc = location()?.start;
        return new LoadStore(loc?.line, loc?.column, "LDTRSW", xt, null,null,  xn)
    }
    / ls:"PRFM "i p:prfop comma add:memory_operand
    {
        const loc = location()?.start;
        return new LoadStore(loc?.line, loc?.column, "PRFM", p, null, add)
    }
    / ls:"STP "i  rt:numericalRegister comma rt2:numericalRegister comma add:memory_operand
    {
        const loc = location()?.start;
        return new LoadStore(loc?.line, loc?.column, "STP", rt, rt2, null, add)
    }
    / "ST"i a:"U"i? "R"i  b:("B"i / "H"i)?  " " rt:numericalRegister comma add:memory_operand
    {
        let ls = "ST"
        if (a != null && a!= undefined) {
            ls += "U"
        }
        ls += "R"
        if (b != null && b!= undefined) {
            ls += b
        }
        const loc = location()?.start;
        return new LoadStore(loc?.line, loc?.column, ls, rt, null, null, add)
    }
    / "STLR"i a:("B"i / "H"i)? " " rt:numericalRegister comma xn:memory_operand
    {
        let ls = "STLR"
        if (a != null && a!= undefined) {
            ls += a
        }
        const loc = location()?.start;
        return new LoadStore(loc?.line, loc?.column, ls, rt, null,null,  xn)
    }
    / "ST"i a:"L"i? "XP "i wd:numericalRegister comma rt:numericalRegister comma rt2:numericalRegister comma xn:memory_operand
    {
        let ls = "ST"
        if (a != null && a!= undefined) {
            ls += "L"
        }
        ls += "XP"
        const loc = location()?.start;
        return new LoadStore(loc?.line, loc?.column, ls, wd, rt, rt2,  xn)
    }
    / "ST"i a:"L"i? "XR"i b:("B"i / "H"i)?  " " wd:numericalRegister comma rt:numericalRegister comma xn:memory_operand
    {
        let ls = "ST"
        if (a != null && a!= undefined) {
            ls += "L"
        }
        ls += "XR"
        if (b != null && b!= undefined) {
            ls += b
        }
        const loc = location()?.start;
        return new LoadStore(loc?.line, loc?.column, ls, wd, rt, null,  xn)
    }
    / ls:"STNP "i rt:numericalRegister comma rt2:numericalRegister comma xn:memory_operand
    {
        const loc = location()?.start;
        return new LoadStore(loc?.line, loc?.column, "STNP", rt, rt2,null,  xn)
    }
    / "STTR"i a:("B"i / "H"i)? " " rt:numericalRegister comma xn:memory_operand
    {
        let ls = "STTR"
        if (a != null && a!= undefined) {
            ls += a
        }
        const loc = location()?.start;
        return new LoadStore(loc?.line, loc?.column, ls, rt, null,null,  xn)
    }

logical "logical"
    = log:("AND "i / "ANDS "i) rd:numericalRegister comma rn:numericalRegister comma op2:simple_operand
    {
        const loc = location()?.start;
        return new Logical(loc?.line, loc?.column, log, rd, rn, op2)
    }
    / log:("BIC "i / "BICS "i) rd:numericalRegister comma rn:numericalRegister comma op2:simple_operand
    {
        const loc = location()?.start;
        return new Logical(loc?.line, loc?.column, log, rd, rn, op2)
    }
    / log:"EON "i rd:numericalRegister comma rn:numericalRegister comma op2:simple_operand
    {
        const loc = location()?.start;
        return new Logical(loc?.line, loc?.column, log, rd, rn, op2)
    }
    / log:"EOR "i rd:numericalRegister comma rn:numericalRegister comma rm:simple_operand 
    {
        const loc = location()?.start;
        return new Logical(loc?.line, loc?.column, log, rd, rn, rm)
    }
    / log:"ORR "i rd:numericalRegister comma rn:numericalRegister comma rm:simple_operand
    {
        const loc = location()?.start;
        return new Logical(loc?.line, loc?.column, log, rd, rn, rm)
    }
    / log:"MVN "i rd:numericalRegister comma op2:simple_operand
    {
        const loc = location()?.start;
        return new Logical(loc?.line, loc?.column, log, rd, null, op2 )
    }
    / log:"ORN "i rd:numericalRegister comma rn:numericalRegister comma rm:simple_operand
    {
        const loc = location()?.start;
        return new Logical(loc?.line, loc?.column, log, rd, rn, rm)
    }
    / log:"TST "i rd:numericalRegister comma op2:simple_operand
    {
        const loc = location()?.start;
        return new Logical(loc?.line, loc?.column, log, rd, null, op2)
    
    }

shift_rotate "shift_rotate"
    = sh:"LSL "i rd:numericalRegister comma rn:numericalRegister comma rm:(inmediate)
    {
        const loc = location()?.start;
        return new ShiftRotate(loc?.line, loc?.column, sh, rd, rn, rm, 1)
    }
    / sh:"LSL "i rd:numericalRegister comma rn:numericalRegister comma rm:(numericalRegister)
    {
        const loc = location()?.start;
        return new ShiftRotate(loc?.line, loc?.column, sh, rd, rn, rm, 2)
    }
    / sh:"LSR "i rd:numericalRegister comma rn:numericalRegister comma rm:(inmediate)
    {
        const loc = location()?.start;
        return new ShiftRotate(loc?.line, loc?.column,sh, rd, rn, rm, 1)
    } 
    / sh:"LSR "i rd:numericalRegister comma rn:numericalRegister comma rm:(numericalRegister)
    {
        const loc = location()?.start;
        return new ShiftRotate(loc?.line, loc?.column,sh, rd, rn, rm, 2)
    } 
    / sh:"ASR "i rd:numericalRegister comma rn:numericalRegister comma rm:(inmediate) 
    {
        const loc = location()?.start;
        return new ShiftRotate(loc?.line, loc?.column,sh, rd, rn, rm, 1)
    }
    / sh:"ASR "i rd:numericalRegister comma rn:numericalRegister comma rm:(numericalRegister) 
    {
        const loc = location()?.start;
        return new ShiftRotate(loc?.line, loc?.column,sh, rd, rn, rm, 2)
    }
    / sh:"ROR "i rd:numericalRegister comma rn:numericalRegister comma rm:(inmediate)
    {
        const loc = location()?.start;
        return new ShiftRotate(loc?.line, loc?.column,sh, rd, rn, rm, 1)
    
    }
    / sh:"ROR "i rd:numericalRegister comma rn:numericalRegister comma rm:(numericalRegister)
    {
        const loc = location()?.start;
        return new ShiftRotate(loc?.line, loc?.column,sh, rd, rn, rm, 2)
    
    }

system_instructions "system_instructions"
    = "AT "i "S1"i a:"2"? "E"i b:[0-3]? c:("R"i/ "W"i)? comma rn:numericalRegister
    {
        let sys = "AT"
        let lvl = "S1"
        if (a != null && a!= undefined) {
            lvl += a
        }
        lvl += "E"
        if (b != null && b!= undefined) {
            lvl += b
        }
        if (c != null && c!= undefined) {
            lvl += c
        }
        const loc = location()?.start;
        return new System(loc?.line, loc?.column, sys, lvl, rn, 1)
    }
    / sys:"BRK "i inm:inmediate 
    {
        const loc = location()?.start;
        return new System(loc?.line, loc?.column, sys, inm, null, 2)
    }
    / sys:"CLREX"i  " "? inm:inmediate?
    {
        const loc = location()?.start;
        return new System(loc?.line, loc?.column, sys, inm, null, 2)
    }
    / sys:"DMB "i b_op:barrier_option
    {
        const loc = location()?.start;
        return new System(loc?.line, loc?.column, sys, b_op.option, null, 3)
    }
    / sys:"DSB "i b_op:barrier_option
    {
        const loc = location()?.start;
        return new System(loc?.line, loc?.column, sys,  b_op.option, null, 3)
    }
    / sys:"ERET"i
    {
        const loc = location()?.start;
        return new System(loc?.line, loc?.column, sys, null, null, 0)
    }
    / sys:"HVC "i inm:inmediate
    {
        const loc = location()?.start;
        return new System(loc?.line, loc?.column, sys, inm, null, 2)
    }
    / sys:"ISB"i op:(" SY"i)?
    {
        const loc = location()?.start;
        return new System(loc?.line, loc?.column, sys, op, 0)
    }
    / sys:"MRS "i xt:numericalRegister comma field:special_prupose_register 
    {
        const loc = location()?.start;
        return new System(loc?.line, loc?.column, sys, xt, field, 4)
    }
    / sys:"MSR "i field:special_prupose_register comma xt:(numericalRegister)
    {
        const loc = location()?.start;
        return new System(loc?.line, loc?.column, sys, field, xt, 5)
    }
    / sys:"MSR "i field:special_prupose_register comma xt:(inmediate)
    {
        const loc = location()?.start;
        return new System(loc?.line, loc?.column, sys, field, xt, 6)
    }
    / sys:"NOP"i
    {
        const loc = location()?.start;
        return new System(loc?.line, loc?.column, sys, null, null, 0)
    }
    / sys:"SEV"i
    {
        const loc = location()?.start;
        return new System(loc?.line, loc?.column, sys, null, null, 0)
    }
    / sys:"SEVL"i
    {
        const loc = location()?.start;
        return new System(loc?.line, loc?.column, sys, null, null, 0)
    }
    / sys:"SMC "i inm:inmediate
    {
        const loc = location()?.start;
        return new System(loc?.line, loc?.column, sys, inm, null, 2)
    }
    / sys:"SVC "i inm:inmediate
    {
        const loc = location()?.start;
        return new System(loc?.line, loc?.column, sys, inm, null, 2)
    }
    / sys:"WFE"i
    {
        const loc = location()?.start;
        return new System(loc?.line, loc?.column, sys, null, null, 0)
    }
    / sys:"WFI"i
    {
        const loc = location()?.start;
        return new System(loc?.line, loc?.column, sys, null, null, 0)
    }
    / sys:"YIELD"i
    {
        const loc = location()?.start;
        return new System(loc?.line, loc?.column, sys, null, null, 0)
    }

barrier_option "barrier_option"
    = "OSH"i op:( comma (_"LD"i / _"ST"i))? 
    {
        return {
            option: "OSH",
            operation: op === undefined ? null : op[1]
        }
    }
    / "NSH"i ( comma (_"LD"i / _"ST"i))?
    {
        return {
            option: "NSH",
            operation: op === undefined ? null : op[1]
        }
    }
    / "ISH"i ( comma (_"LD"i / _"ST"i))?
    {
        return {
            option: "ISH",
            operation: op === undefined ? null : op[1]
        }
    }
    / "LD"i
    {
        return {
            option: "LD",
            operation: null
        }
    }
    / "ST"i
    {
        return {
            option: "ST",
            operation: null
        }
    }
    / "SY"i
    {
        return {
            option: "SY",
            operation: null
        }
    }

bit_manipulacion "bit_manipulacion"
    = b:"BFXIL "i rd:numericalRegister comma rn:numericalRegister comma lsb:inmediate comma width:inmediate
    {
        const loc = location()?.start;
        return new BitManipulation(loc?.line, loc?.column, b, rd, rn, lsb, width)
    }
    / b:"BFI "i rd:numericalRegister comma rn:numericalRegister comma lsb:inmediate comma width:inmediate
    {
        const loc = location()?.start;
        return new BitManipulation(loc?.line, loc?.column, b, rd, rn, lsb, width)
    }
    / b:"CLS "i rd:numericalRegister comma rn:numericalRegister
    {
        const loc = location()?.start;
        return new BitManipulation(loc?.line, loc?.column, b, rd, rn, null, null)
    }
    / b:"CLZ "i rd:numericalRegister comma rn:numericalRegister
    {
        const loc = location()?.start;
        return new BitManipulation(loc?.line, loc?.column, b, rd, rn, null, null)
    }
    / b:"EXTR "i rd:numericalRegister comma rn:numericalRegister comma rm:numericalRegister comma lsb:inmediate
    {
        const loc = location()?.start;
        return new BitManipulation(loc?.line, loc?.column, b, rd, rn, rm, lsb)
    }
    / b:"RBIT "i rd:numericalRegister comma rn:numericalRegister
    {
        const loc = location()?.start;
        return new BitManipulation(loc?.line, loc?.column, b, rd, rn, null, null)
    }
    / b:"REV "i rd:numericalRegister comma rn:numericalRegister
    {
        const loc = location()?.start;
        return new BitManipulation(loc?.line, loc?.column, b, rd, rn, null, null)
    }
    / b:"REV16 "i rd:numericalRegister comma rn:numericalRegister
    {
        const loc = location()?.start;
        return new BitManipulation(loc?.line, loc?.column, b, rd, rn, null, null)
    }
    / b:"REV32 "i rd:numericalRegister comma rn:numericalRegister
    {
        const loc = location()?.start;
        return new BitManipulation(loc?.line, loc?.column, b, rd, rn, null, null)
    }
    / a:("S"i / "U"i)? "BFIZ "i rd:numericalRegister comma rn:numericalRegister comma lsb:inmediate comma width:inmediate
    {
        let b = "BFIZ"
        if(a != null && a != undefined) {
            b = a + "BFIZ"
        } else {
            b = "BFIZ"
        }
        const loc = location()?.start;
        return new BitManipulation(loc?.line, loc?.column, b, rd, rn, lsb, width)
    }
    / a:("S"i / "U"i)? "BFX "i rd:numericalRegister comma rn:numericalRegister comma lsb:inmediate comma width:inmediate
    {
        let b = "BFX"
        if(a != null && a != undefined) {
            b = a + "BFX"
        } else {
            b = "BFX"
        }
        const loc = location()?.start;
        return new BitManipulation(loc?.line, loc?.column, b, rd, rn, lsb, width)
    }
    / a:("S"i / "U"i)? "XT"i c:("B"i / "H"i)? " " rd:numericalRegister comma rn:numericalRegister
    {
        let b = "XT"
        if(a != null && a != undefined) {
            b = a + "XT"
        } else {
            b = "XT"
        }
        if(c != null && c != undefined) {
            b += c
        }
        const loc = location()?.start;
        return new BitManipulation(loc?.line, loc?.column, b, rd, rn, null, null)
    }
    / b:"SXTW "i rd:numericalRegister comma rn:numericalRegister
    {
        const loc = location()?.start;
        return new BitManipulation(loc?.line, loc?.column, b, rd, rn, null, null)
    }

atomic "atomic"
    = "CAS"i a:"A"i? b:"L"i? c:("B"i / "H"i)? " " rs:numericalRegister comma rt:numericalRegister comma xn:memory_operand
    {
        let at = "CAS"
        if(a != null && a != undefined) {
            at += a
        }
        if(b != null && b != undefined) {
            at += b
        }
        if(c != null && c != undefined) {
            at += c
        }
        const loc = location()?.start;
        return new Atomic(loc?.line, loc?.column, at, rs, rt, null, null, xn)
    }
    / "CAS"i a:"A"i? b:"L"i? "P"i " "  rs:numericalRegister comma rs2:numericalRegister comma rt:numericalRegister comma rt2:numericalRegister comma xn:memory_operand
    {
        let at = "CAS"
        if(a != null && a != undefined) {
            at += a
        }
        if(b != null && b != undefined) {
            at += b
        }
        at += "P"
        const loc = location()?.start;
        return new Atomic(loc?.line, loc?.column, at, rs, rs2, rt, rt2, xn)
    }
    / "LDao"i a:"A"i? b:"L"i? c:("B"i / "H"i)? " "  rs:numericalRegister comma rt:numericalRegister comma xn:memory_operand
    {
        let at = "LDao"
        if(a != null && a != undefined) {
            at += a
        }
        if(b != null && b != undefined) {
            at += b
        }
        if(c != null && c != undefined) {
            at += c
        }
        const loc = location()?.start;
        return new Atomic(loc?.line, loc?.column, at, rs, rt, null, null, xn)
    }
    / "STao"i a:"A"i? b:"L"i? c:("B"i / "H"i)? " " rs:numericalRegister comma xn:memory_operand
    {
        let at = "STao"
        if(a != null && a != undefined) {
            at += a
        }
        if(b != null && b != undefined) {
            at += b
        }
        if(c != null && c != undefined) {
            at += c
        }
        const loc = location()?.start;
        return new Atomic(loc?.line, loc?.column, at, rs, null, null, null, xn)
    }
    / "SWP"i a:"A"i? b:"L"i? c:("B"i / "H"i)? " " rs:numericalRegister comma rt:numericalRegister comma xn:memory_operand
    {
        let at = "SWP"
        if(a != null && a != undefined) {
            at += a
        }
        if(b != null && b != undefined) {
            at += b
        }
        if(c != null && c != undefined) {
            at += c
        }
        const loc = location()?.start;
        return new Atomic(loc?.line, loc?.column, at, rs, rt, null, null, xn)
    
    }

conditional "conditional"
    = con:"CCMN "i rn:numericalRegister comma op2:(inmediate) comma inm:inmediate comma _ cond:condicional_codes
    {
        const loc = location()?.start;
        return new Conditional(loc?.line, loc?.column, con, rn, op2, inm, cond, 1)
    }
    / con:"CCMN "i rn:numericalRegister comma op2:(numericalRegister) comma inm:inmediate comma _ cond:condicional_codes
    {
        const loc = location()?.start;
        return new Conditional(loc?.line, loc?.column, con, rn, op2, inm, cond, 2)
    }
    / con:"CCMP "i rn:numericalRegister comma op2:(inmediate) comma inm:inmediate comma _ cond:condicional_codes
    {
        const loc = location()?.start;
        return new Conditional(loc?.line, loc?.column, con, rn, op2, inm, cond, 1)
    }
    / con:"CCMP "i rn:numericalRegister comma op2:(numericalRegister) comma inm:inmediate comma _ cond:condicional_codes
    {
        const loc = location()?.start;
        return new Conditional(loc?.line, loc?.column, con, rn, op2, inm, cond, 0)
    }
    / con:"CINC "i rd:numericalRegister comma rn:numericalRegister comma _ cond:condicional_codes
    {
        const loc = location()?.start;
        return new Conditional(loc?.line, loc?.column, con, rd, rn, null, cond, 0)
    }
    / con:"CINV "i rd:numericalRegister comma rn:numericalRegister comma _ cond:condicional_codes
    {
        const loc = location()?.start;
        return new Conditional(loc?.line, loc?.column, con, rd, rn, null, cond, 0)
    }
    / con:"CNEG "i rd:numericalRegister comma rn:numericalRegister comma _ cond:condicional_codes
    {
        const loc = location()?.start;
        return new Conditional(loc?.line, loc?.column, con, rd, rn, null, cond, 0)
    }
    / con:"CSEL "i rd:numericalRegister comma rn:numericalRegister comma _ rm:numericalRegister comma _ cond:condicional_codes
    {
        const loc = location()?.start;
        return new Conditional(loc?.line, loc?.column, con, rd, rn, rm, cond, 3)
    }
    / con:"CSETM "i rd:numericalRegister comma _ cond:condicional_codes
    {
        const loc = location()?.start;
        return new Conditional(loc?.line, loc?.column, con, rd, null, null, cond, 0)
    }
    / con:"CSET "i rd:numericalRegister comma _ cond:condicional_codes
    {
        const loc = location()?.start;
        return new Conditional(loc?.line, loc?.column, con, rd, null, null, cond, 0)
    }
    / con:"CSINC "i rd:numericalRegister comma rn:numericalRegister comma rm:numericalRegister comma _ cond:condicional_codes
    {
        const loc = location()?.start;
        return new Conditional(loc?.line, loc?.column, con, rd, rn, rm, cond, 3)
    }
    / con:"CSINV "i rd:numericalRegister comma rn:numericalRegister comma rm:numericalRegister comma _ cond:condicional_codes
    {
        const loc = location()?.start;
        return new Conditional(loc?.line, loc?.column, con, rd, rn, rm, cond, 3)
    }
    / con:"CSNEG "i rd:numericalRegister comma rn:numericalRegister comma rm:numericalRegister comma _ cond:condicional_codes
    {
        const loc = location()?.start;
        return new Conditional(loc?.line, loc?.column, con, rd, rn, rm, cond, 3)
    }

checksum_instructions "checksum_instructions"
    = "CRC32"i a:("B"i / "H"i)? " " rd:numericalRegister comma rn:numericalRegister comma rm:numericalRegister
    {
        let ch = "CRC32"
        if(a != null && a != undefined) {
            ch += a
        }
        const loc = location()?.start;
        return new CheckSum(loc?.line, loc?.column, ch, rd, rn, rm)
    }
    / "CRC32"i a:("W"i / "X"i) " " rd:numericalRegister comma rn:numericalRegister comma rm:numericalRegister
    {
        let ch = "CRC32"
        if(a != null && a != undefined) {
            ch += a
        }
        const loc = location()?.start;
        return new CheckSum(loc?.line, loc?.column, ch, rd, rn, rm)
    }
    / "CRC32C"i a:(("B"i/"H"i)/ "W" / "X")? " " rd:numericalRegister comma rn:numericalRegister comma rm:numericalRegister
    {
        let ch = "CRC32C"
        if(a != null && a != undefined) {
            let b = a.replace(",", "")
            ch += b
        }
        const loc = location()?.start;
        return new CheckSum(loc?.line, loc?.column, ch, rd, rn, rm)
    }

simple_operand "simple_operand"
    = reg:numericalRegister (comma)? op:(operands)? 
    {
        return reg
    }
    / inm:inmediate         { return inm;}

operands "operands"
    = _ op:("LSL "i / "LSR "i / "ASR "i / "ROR "i) inm:inmediate {return op + " " + inm}
    / _ a:("S"i/"U"i)? b:("XTB"i / "XTH"i / "XTW"i / "XTX"i) _? c:(inmediate)? {return a + b + (c ? c : "")} 

memory_operand "memory_operand"
    = _ "[" addr:adderssing_Extension _"]"
    {
        let loc = location()?.start;
        return new AccessMemory(loc?.line, loc?.column, addr[0], addr[1], addr[2], addr[3])
    }
    /_ "[" addr:adderssing_simple _"]" inm:(comma inmediate)?
    {
        let offset=null;
        let type = false;
        if(addr[1] != null && addr[1] != undefined){
            offset = addr[1];
            type = false;
        }else{
            if(inm != undefined && inm != null){
                offset = inm[1];
                type = true;
            }
        }
        let loc = location()?.start;
        return new AccessMemory(loc?.line, loc?.column, addr[0], offset, null, null, null, type)
    }
    /_ "[" addr:adderssing_simple _"]" (_ "!")?
    {
        let loc = location()?.start;
        return new AccessMemory(loc?.line, loc?.column, addr[0], addr[1], null, null,"!",addr[1]=== null ? true : fals)
    }

    / _ "=" id:id
    {
        let loc = location()?.start;
        return new AccessMemory(loc?.line, loc?.column, id, null, null,null, "=")
    }
    / _ id:id
    {
        let loc = location()?.start;
        return new AccessMemory(loc?.line, loc?.column, id, null, null)
    }

adderssing_simple
    = xn:generalPurposeRegister comma inm:inmediate
    {
        return [xn, inm]
    }
    / xn:generalPurposeRegister
    {   
        return [xn, null]
    }
    / _ "SP"i comma inm:inmediate
    {
        return [["SP",64], inm]
    }
    / _ "SP"i
    {
        return [["SP",64], null]
    }

adderssing_Extension "adderssing"
    = xn:generalPurposeRegister comma wm:generalPurposeRegister comma _ op:"SXTX"i inm:inmediate? 
    {
        let loc = location()?.start;
        let temp = new BitManipulation(loc?.line, loc?.column, op, xn, wm, null, null)
        return [xn, wm, temp , inm]
    }
    / xn:generalPurposeRegister comma wm:generalPurposeRegister comma _ op:(("S"i/"U"i)? "XTW"i) inm:inmediate?
    {
        let loc = location()?.start;
        let temp = new BitManipulation(loc?.line, loc?.column, op, xn, wm, null, null)
        return [xn, wm, temp, inm]
    }
    / xn:generalPurposeRegister comma xm:generalPurposeRegister comma _ op:"LSL "i inm:inmediate
    {
        let loc = location()?.start;
        let temp = new ShiftRotate(loc?.line, loc?.column, op, xn, xm, inm)
        return [xn, xm, temp, inm]
    }


prfop "prfop"
    = _ "P" a:("LD"i / "LI"i / "ST"i)? "L"i b:([123])? c:("KEEP"i / "STRM"i)?{
        let ins = "P";
        if(a != null && a != undefined){
            ins += a;
        }
        ins += "L";
        if(b != null && b != undefined){
            ins += b;
        }
        if(c != null && c != undefined){
            ins += c;
        }
        return ins;
    }

/* Lexical rules */

comma "comma"
    = _","

newLine "newLine"
    = _"\n"

_ "whitespace"
    = [ \t\u00A0\uFEFF]* {return }

__ "unused"
    = ([ \t\r\n\f]+)/comment {return }

s 
    = " " {return null;}

hash "hash"
    = _"#"

id "id"
    = _ [a-zA-Z_][a-zA-Z0-9_]* { return text();}

slash "slash"
    = _"/"

semicolon "semicolon"
    = _";"

comment "comment"
	= [/][*][^*]*[*]+([^/*][^*]*[*]+)*[/] {return null;}
    / slash slash [^\n]*                  {return null;}
    / semicolon [^\n]*                    {return null;}

colon "colon"
    = _":"
    
variable_posible
    = ".word"  {return "word"}
    / ".half"  {return "half"}
    / ".byte"  {return "byte"}
    / ".asciz" {return "asciz"}
    / ".ascii" {return "ascii"}
    / ".skip"  {return "skip"}
    / ".float" {return "float"}
    / ".quad"  {return "quad"}
    / ".space" {return "space"}

variables "variables"
    = vari:variable+ {return vari}

variable "variable"
    = nom:id colon __* tipo:variable_posible _ val:( string / inmediate) {
        const loc = location()?.start;
        return new Variable(loc?.line, loc?.column, tipo, nom, val)
    
    }

numericalRegister "numericalRegister"
    = _ "XZR"i 
    {
        let loc = location()?.start;
        return new Register(loc?.line, loc?.column, "XZR");
    }
    / x:generalPurposeRegister
    {
        let loc = location()?.start;
        return new Register(loc?.line, loc?.column, x[0],x[1]);
    }
    / d:floatingPointRegister
    {
        let loc = location()?.start;
        return new Register(loc?.line, loc?.column, d,64);
    }
    / _ "SP"i
    {
        let loc = location()?.start;
        return new Register(loc?.line, loc?.column, "SP",64);
    
    }


generalPurposeRegister "generalPurposeRegister"
    = _"x" int:integer { return ["x"+int, 64] ;}
    / _"w" int:integer { return ["w"+int, 32] ;}

floatingPointRegister "floatingPointRegister"
    = _"d" int:integer  { return "d" + int }
    / _"s" int:integer  { return "s" + int }

number "number"
    = float:real  {return float;}
    / int:integer {return int;}
    

integer "integer"
    = "-"?[0-9]+   {return parseInt(text());}

real "real" 
    = "-"?[0-9]+ "." [0-9]+ {return parseFloat(text());}

char "char"  
    = "\'"(!"\'" .)+"\'" { return text().slice(1, -1);}

inmediate "inmediate"
    = (hash)? _ base:"0b" binary:[01]+{
        let binario = binary.join("");
        let numero = base + binario;
        let loc = location()?.start;
        return new Inmediate(loc?.line, loc?.column, numero,Type.BIN);
        // return numero;
    }
    / (hash)? _ base:"0x" number:[0-9a-fA-F]+{
        let hexa = number.join("");
        let numero = base + hexa;
        let loc = location()?.start;
        return new Inmediate(loc?.line, loc?.column, numero,Type.HEX);
        // return numero;
    }
    / number:( (hash number) / _ number){ 
        let cadena = number.join("");
        cadena = cadena.replace(/,/g, "");
        let loc = location()?.start;
        return new Inmediate(loc?.line, loc?.column, cadena,Type.INT);
        // return cadena;
        }
    / char:(( hash char) / _ char){
        let cadena = char.join("");
        cadena = cadena.replace(/,/g, "");
        let loc = location()?.start;
        return new Inmediate(loc?.line, loc?.column, cadena,Type.CHAR);
        // return cadena;
    }
    
special_prupose_register "special_prupose_register"
    = _"LR"i {return "LR";}
    / _"MSP"i {return "MSP";}
    / _ "PSP"i {return "PSP";}
    / _ a:"SPSR_EL"i b:([123])? {
        let ins = "SPSR_EL";
    
        if(b != null && b != undefined){
            ins += b;
        }
        return ins;
        }
    / _ "ELR_EL"i b:([123])? {
        let ins = "ELR_EL";

        if(b != null && b != undefined){
            ins += b;
        }
        return ins;
        
    }
    / _ "SP_EL"i b:([012])? {
        let ins = "SP_EL";

        if(b != null && b != undefined){
            ins += b;
        }
        return ins;
    }
    / _ "SPSel"i {return "SPSel";}
    / _ "DAIFSet"i {return "DAIFSet";}
    / _ "DAIFClr"i {return "DAIFClr";}
    / _ "DAIF"i {return "DAIF";}
    / _ "NZCV"i {return "NZCV";}
    / _ "FPCR"i {return "FPCR";}
    / _ "FPSR"i {return "FPSR";}
    / _ "CURRENT_EL"i {return "CURRENT_EL"; }


string "string" 
    = "\""  (!"\"" .)* "\"" 
    { 
        let value =  text().slice(1, -1);
        let loc = location()?.start;
        return new Inmediate(loc?.line, loc?.column, value,Type.STRING);
    }