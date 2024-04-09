interface alu_if ();

  logic[15:0] operand_a;
  logic[15:0] operand_b;
  logic[3:0] operation;
  logic[31:0] result;
  logic[31:0] status;

    modport dut (
    input operand_a,
    input operand_b,
    input operation,
    output result,
    output status
    );

    modport driver (
    output operand_a,
    output operand_b,
    output operation,
    input result,
    input status
    );

    modport monitor (
    input operand_a,
    input operand_b,
    input operation,
    input result,
    input status
    );
endinterface : alu_if


module alu (alu_if i);

  localparam logic[3:0]
  OP_ADD = 0,
  OP_SUBTRACT = 1,
  OP_MULTIPLY = 2,
  OP_DIVIDE = 3;
  
  localparam int unsigned
  	STATUS_OKAY = 0,
  	STATUS_DIV_BY_ZERO = 1,
    STATUS_OP_ERR = 2;
  
  always_comb begin
    i.dut.result = 0;
    i.dut.status = 0;
    case (i.dut.operation)
      OP_ADD : begin
        i.dut.result = i.dut.operand_a + i.dut.operand_b;
   		i.dut.status[STATUS_OKAY] = 1;
      end
      
      OP_SUBTRACT : begin
        i.dut.result = i.dut.operand_a - i.dut.operand_b;
   		i.dut.status[STATUS_OKAY] = 1;
      end
      
      OP_MULTIPLY : begin
        i.dut.result = i.dut.operand_a * i.dut.operand_b;
   		i.dut.status[STATUS_OKAY] = 1;
      end
      
      OP_DIVIDE : begin
        if (i.dut.operand_b != 0) begin
          i.dut.result = i.dut.operand_a / i.dut.operand_b;
   		  i.dut.status[STATUS_OKAY] = 1;
        end
        else begin
          i.dut.result = 0;
          i.dut.status[STATUS_DIV_BY_ZERO] = 1;
        end
      end
      
      default : begin

        i.dut.result = -1;
        i.dut.status[STATUS_OP_ERR] = 1;
      end
        
    endcase
  end
endmodule : alu
