class Generator {

    constructor() {
        this.code = '';
        this.quadruples = [];
        this.temporal = 0;
    }

    newTemp() {
        let temp = this.temporal;
        this.temporal++;
        return 't' + temp;
    }

    addQuadruple(op, arg1, arg2, arg3, res) {
        let quad = new Quadruples();
        quad.setOperator(op);
        quad.setArg1(arg1);
        quad.setArg2(arg2);
        quad.setArg3(arg3);
        quad.setResult(res);
        this.quadruples.push(quad);
    }

    getQuadruples(){
        return this.quadruples;
    }


}