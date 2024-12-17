module fetch_decode_latch(clk, rst, data_hazard, disableIFIDWrite, instr_mem_done, data_mem_stall, rst_d, PC_f, PC_d, instruction_f, instruction_d, instr_mem_align_err_f, instr_mem_align_err_d);

    input wire clk, rst;
    input wire data_hazard, disableIFIDWrite, instr_mem_done, data_mem_stall;
    input wire [15:0] PC_f, instruction_f;
    input wire instr_mem_align_err_f;
    output wire rst_d;
    output wire [15:0] PC_d, instruction_d;
    output wire instr_mem_align_err_d;

    wire [15:0] instruction_fd_int1, instruction_fd_int2, instruction_fd_int2_prev;
    wire instr_mem_align_err_fd_int, data_hazard_prev;
    // wire [15:0] PC_fd_int;

    register #(.REGISTER_WIDTH(1)) iRST_LATCH_FD(.clk(clk), .rst(1'b0), .writeEn(1'b1), .writeData(rst), .readData(rst_d));
    
    register iPC_LATCH_FD(.clk(clk), .rst(rst), .writeEn(~disableIFIDWrite), .writeData(PC_f), .readData(PC_d));
    // assign PC_d = (disableIFIDWrite) ? PC_d : PC_fd_int;

    assign instruction_fd_int1 = (rst) ? 16'h0800 :                  // reset to nop so halt isn't asserted early
                                (instr_mem_done) ? instruction_f :  // only proceed with next instruction when instruction is fetched from instr_mem
                                16'h0800;                           // if not done (i.e. stalling), default to nop
    register iINSTRUCTION_LATCH_FD1(.clk(clk), .rst(rst), .writeEn(~disableIFIDWrite), .writeData(instruction_fd_int1), .readData(instruction_d));

    // register iINSTRUCTION_LATCH_FD2(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(instruction_fd_int2), .readData(instruction_fd_int2_prev));
    // register #(.REGISTER_WIDTH(1)) iDATA_HAZARD_REV(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(data_hazard), .readData(data_hazard_prev));
    
    // assign instruction_d =  (data_hazard | data_mem_stall) ? 16'h0800 : 
    //                         (data_hazard_prev & instruction_fd_int2_prev != 16'h0800) ? instruction_fd_int2_prev :
    //                         instruction_fd_int2;

    // assign instr_mem_align_err_fd_int = (disableIFIDWrite) ? 1'b0 : instr_mem_align_err_f;
    register #(.REGISTER_WIDTH(1)) iINSTR_MEM_ALIGN_ERR_FD(.clk(clk), .rst(1'b0), .writeEn(~disableIFIDWrite), .writeData(instr_mem_align_err_f), .readData(instr_mem_align_err_d));

endmodule