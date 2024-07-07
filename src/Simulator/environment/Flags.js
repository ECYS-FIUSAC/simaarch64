let flags = {
    N: 0, // Negative flag
    Z: 0, // Zero flag
    C: 0, // Carry flag
    V: 0  // Overflow flag
};

function updateFlags(result, rn, rm, instruction) {
    flags.N = (result < 0) ? 1 : 0;
    flags.Z = (result === 0) ? 1 : 0;

    switch (instruction) {
        case 'ADDS':
        case 'ADC':
            updateCarryAndOverflowForAdd(result, rn, rm);
            break;
        case 'SUBS':
        case 'SBC':
        case 'CMP':
            updateCarryAndOverflowForSub(result, rn, rm);
            break;
        case 'ANDS':
        case 'EORS':
        case 'ORRS':
            break;
        case 'LSLS':
            updateCarryForShift(result, rn, rm, 'LSL');
            break;
        case 'LSRS':
            updateCarryForShift(result, rn, rm, 'LSR');
            break;
        case 'ASRS':
            updateCarryForShift(result, rn, rm, 'ASR');
            break;
    }
}

function updateCarryAndOverflowForAdd(result, rn, rm) {
    flags.C = (result >>> 32) & 1; // El bit de acarreo es el bit 33 (usando >>> para obtener un valor sin signo)
    flags.V = (((rn ^ rm) & 0x80000000) === 0 && ((rn ^ result) & 0x80000000) !== 0) ? 1 : 0;
}

function updateCarryAndOverflowForSub(result, rn, rm) {
    flags.C = (rn >= rm) ? 1 : 0;
    flags.V = (((rn ^ rm) & 0x80000000) !== 0 && ((rn ^ result) & 0x80000000) !== 0) ? 1 : 0;
}

function updateCarryForShift(result, rn, rm, shiftType) {
    switch (shiftType) {
        case 'LSL':
            flags.C = (rn >>> (32 - rm)) & 1;
            break;
        case 'LSR':
            flags.C = (rn >>> (rm - 1)) & 1;
            break;
        case 'ASR':
            flags.C = (rn >>> (rm - 1)) & 1;
            break;
    }
}
