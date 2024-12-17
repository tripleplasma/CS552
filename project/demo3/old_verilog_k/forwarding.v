module forwarding(
    input  wire         r_type,
    input  wire [2:0]   write_reg_ex_mem,
    input  wire [2:0]   write_reg_mem_wb,
    input  wire [2:0]   RegisterRs_id_ex,
    input  wire [2:0]   RegisterRt_id_ex,
    input  wire         write_en_ex_mem,
    input  wire         write_en_mem_wb,
    output wire [1:0]   ForwardA,
    output wire [1:0]   ForwardB
);

assign ForwardA = (write_en_ex_mem & (write_reg_ex_mem == RegisterRs_id_ex)) ? 2'b10 :
                  (write_en_mem_wb & (write_reg_mem_wb == RegisterRs_id_ex)) ? 2'b01 : 2'b00;

assign ForwardB = (r_type & write_en_ex_mem & (write_reg_ex_mem == RegisterRt_id_ex)) ? 2'b10 :
                  (r_type & write_en_mem_wb & (write_reg_mem_wb == RegisterRt_id_ex)) ? 2'b01 : 2'b00;

endmodule