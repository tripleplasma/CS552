/* $Author: karu $ */
/* $LastChangedDate: 2009-04-24 09:28:13 -0500 (Fri, 24 Apr 2009) $ */
/* $Rev: 77 $ */

`default_nettype none
module mem_system_other(/*AUTOARG*/
   // Outputs
   DataOut, Done, Stall, CacheHit, err,
   // Inputs
   Addr, DataIn, Rd, Wr, createdump, clk, rst
   );
   
   input wire [15:0] Addr;
   input wire [15:0] DataIn;
   input wire        Rd;
   input wire        Wr;
   input wire        createdump;
   input wire        clk;
   input wire        rst;
   
   output reg [15:0] DataOut;
   output reg        Done;
   output reg        Stall;
   output reg        CacheHit;
   output reg        err;

   // cache 0 signals
   reg cache_en_0, comp, cache_write, valid_in;
   reg [15:0] cache_data_in;
   reg [2:0] offset;
   wire hit_0, dirty_0, valid_0, cache_err_0;
   wire [4:0] tag_out_0;
   wire [15:0] cache_data_out_0;

   // cache 1 signals
   reg cache_en_1;
   wire hit_1, dirty_1, valid_1, cache_err_1;
   wire [4:0] tag_out_1;
   wire [15:0] cache_data_out_1;

   // mem signals
   wire stall, mem_err;
   wire [3:0] busy;
   wire [15:0] mem_data_out;
   reg [15:0] mem_addr, mem_data_in;
   reg mem_wr, mem_rd;

   /* data_mem = 1, inst_mem = 0 *
    * needed for cache parameter */
   parameter memtype = 0;
   cache #(0 + memtype) c0(// Outputs
                          .tag_out              (tag_out_0),
                          .data_out             (cache_data_out_0),
                          .hit                  (hit_0),
                          .dirty                (dirty_0),
                          .valid                (valid_0),
                          .err                  (cache_err_0),
                          // Inputs
                          .enable               (cache_en_0),
                          .clk                  (clk),
                          .rst                  (rst),
                          .createdump           (createdump),
                          .tag_in               (Addr[15:11]),
                          .index                (Addr[10:3]),
                          .offset               (offset),
                          .data_in              (cache_data_in),
                          .comp                 (comp),
                          .write                (cache_write),
                          .valid_in             (valid_in));
   cache #(2 + memtype) c1(// Outputs
                          .tag_out              (tag_out_1),
                          .data_out             (cache_data_out_1),
                          .hit                  (hit_1),
                          .dirty                (dirty_1),
                          .valid                (valid_1),
                          .err                  (cache_err_1),
                          // Inputs
                          .enable               (cache_en_1),
                          .clk                  (clk),
                          .rst                  (rst),
                          .createdump           (createdump),
                          .tag_in               (Addr[15:11]),
                          .index                (Addr[10:3]),
                          .offset               (offset),
                          .data_in              (cache_data_in),
                          .comp                 (comp),
                          .write                (cache_write),
                          .valid_in             (valid_in));

   four_bank_mem mem(// Outputs
                     .data_out          (mem_data_out),
                     .stall             (stall),
                     .busy              (busy),
                     .err               (mem_err),
                     // Inputs
                     .clk               (clk),
                     .rst               (rst),
                     .createdump        (createdump),
                     .addr              (mem_addr),
                     .data_in           (mem_data_in),
                     .wr                (mem_wr),
                     .rd                (mem_rd));
   
   // your code here
   
   // FSM signals
   wire [2:0]  next_state, state;
   wire [2:0]  state_0_logic, 
               state_1_logic, 
               state_2_logic, 
               state_3_logic, 
               state_4_logic, 
               state_5_logic, 
               state_6_logic,
               state_7_logic;

   // capture signals & regs
   reg capture_Wr, word_cnt_inc, flip_victimway;
   wire Wr_q, victimway;
   wire [2:0] word_cnt_q;

   // victimway reg
   dff victimway_ff (.q(victimway), .d(rst ? 1'b1 : flip_victimway ? ~victimway : victimway), .clk(clk), .rst(1'b0));

   // cache install logic on miss
   // choosing between using pseduo replacement policy or invalid line
   reg capture_cache_install;
   wire cache_install, cache_install_q;
   assign cache_install = (valid_0 & valid_1) ? victimway : ~valid_1 & valid_0;
   dff cache_install_ff (.q(cache_install_q), .d(capture_cache_install ? cache_install : cache_install_q), .clk(clk), .rst(rst));

   // choosing which tag_out & data_out for mem write & cache read
   wire [4:0] tag_out_valid;
   wire [15:0] cache_data_out_valid;
   assign tag_out_valid = cache_install_q ? tag_out_1 : tag_out_0;
   assign cache_data_out_valid = cache_install_q ? cache_data_out_1 : cache_data_out_0;

   // choosing which cache to check for state transitions
   wire mem_wr_logic;
   assign mem_wr_logic = cache_install ? (cache_en_1 & ~hit_1 & valid_1 & dirty_1) : (cache_en_0 & ~hit_0 & valid_0 & dirty_0);
   wire mem_rd_logic;
   assign mem_rd_logic = cache_install ? (cache_en_1 & (~valid_1 | (~hit_1 & valid_1 & ~dirty_1))) : (cache_en_0 & (~valid_0 | (~hit_0 & valid_0 & ~dirty_0)));

   // next state logic
   assign state_0_logic =  ((cache_en_0 & hit_0 & valid_0) | (cache_en_1 & hit_1 & valid_1)) ? 3'b001 : // go to cache hit state
                           (mem_wr_logic) ? 3'b010 : // go to mem write state
                           (mem_rd_logic) ? 3'b011 : // go to mem read state
                           3'b000;
   assign state_1_logic =  3'b000; // go back to start on cache hit
   assign state_2_logic = (word_cnt_q == 3'b110) ? 3'b011 : 3'b010;
   assign state_3_logic = (word_cnt_q == 3'b110) ? 3'b101 : 3'b011;
   assign state_4_logic = 3'b000; // UNUSED
   assign state_5_logic = (word_cnt_q == 3'b110) ? 3'b110 : 3'b101;
   assign state_6_logic = 3'b000;
   assign state_7_logic = 3'b000; // UNUSED

   assign next_state =  (state == 3'b000) ? state_0_logic :
                        (state == 3'b001) ? state_1_logic :
                        (state == 3'b010) ? state_2_logic :
                        (state == 3'b011) ? state_3_logic :
                        (state == 3'b100) ? state_4_logic : // UNUSED
                        (state == 3'b101) ? state_5_logic :
                        (state == 3'b110) ? state_6_logic :
                        (state == 3'b111) ? state_7_logic : // UNUSED
                        state;

   // transition to next state each clock cycle
   dff state_ff [2:0] (.q(state), .d(next_state), .clk(clk), .rst(rst));

   // flop signals for next states
   wire [15:0] cache_hit_out, cache_hit_out_q, mem_data_out_q, mem_data_out_q2;
   assign cache_hit_out = (cache_en_0 & hit_0 & valid_0) ? cache_data_out_0 : cache_data_out_1;
   dff cache_data_out_ff [15:0] (.q(cache_hit_out_q), .d(cache_hit_out), .clk(clk), .rst(rst));
   dff wr_ff (.q(Wr_q), .d(capture_Wr ? Wr : Wr_q), .clk(clk), .rst(rst));
   
   // count what word we are currently reading/writing
   wire [3:0] word_cnt_sum;
   fulladder4 word_cnt_FA (.A({1'b0, word_cnt_q}), .B(4'b0010), .Cin(1'b0), .S(word_cnt_sum), .Cout());
   dff word_cnt_ff [2:0] (.q(word_cnt_q), .d(word_cnt_inc ? word_cnt_sum[2:0] : word_cnt_q), .clk(clk), .rst(rst));

   // mem_data_out ffs to stagger them for cache writes
   dff mem_data_out_ff [15:0] (.q(mem_data_out_q), .d(mem_data_out), .clk(clk), .rst(rst));
   dff mem_data_out_ff_2 [15:0] (.q(mem_data_out_q2), .d(mem_data_out_q), .clk(clk), .rst(rst));

   // state signals
   always @(*) begin
      cache_en_0 = 0;
      cache_en_1 = 0;
      cache_data_in = 0;
      comp = 0;
      cache_write = 0;
      valid_in = 0;
      mem_addr = 0;
      mem_data_in = 0;
      mem_wr = 0;
      mem_rd = 0;
      DataOut = 0;
      Done = 0;
      Stall = 0;
      CacheHit = 0;
      err = 0;
      capture_Wr = 0;
      word_cnt_inc = 0;
      offset = 0;
      capture_cache_install = 0;
      flip_victimway = 0;
      case (state)
         3'b000: begin // CACHE READ/WRITE
            offset = Addr[2:0];
            cache_en_0 = Rd | Wr;
            cache_en_1 = Rd | Wr;
            cache_data_in = DataIn;
            comp = 1;
            cache_write = Wr;
            capture_Wr = 1;
            capture_cache_install = 1;
            err = cache_err_0 | cache_err_1;
         end
         3'b001: begin // CACHE HIT
            Done = 1;
            Stall = 1;
            DataOut = cache_hit_out_q;
            CacheHit = 1;
            flip_victimway = 1;
         end
         3'b010: begin // WRITING DIRTY CACHE LINE TO MEM
            cache_en_0 = ~cache_install_q;
            cache_en_1 = cache_install_q;
            offset = word_cnt_q;
            mem_wr = 1;
            mem_data_in = cache_data_out_valid;
            mem_addr = {tag_out_valid, Addr[10:3], word_cnt_q};
            word_cnt_inc = 1;
            Stall = 1;
            err = cache_err_0 | cache_err_1 | mem_err;
         end
         3'b011: begin // READING MISSED CACHE LINE FROM MEMORY
            mem_rd = 1;
            mem_addr = {Addr[15:3], word_cnt_q};
            Stall = 1;
            word_cnt_inc = 1;
            err = mem_err;
         end
         3'b100: begin // CURRENTLY UNUSED
            Stall = 1;
         end
         3'b101: begin // WRITING MISSED CACHE LINE INTO CACHE
            cache_en_0 = ~cache_install_q;
            cache_en_1 = cache_install_q;
            cache_write = 1;
            cache_data_in = mem_data_out_q2;
            valid_in = 1;
            Stall = 1;
            word_cnt_inc = 1;
            offset = word_cnt_q;
            err = cache_err_0 | cache_err_1;
         end
         3'b110: begin // WRITE INTO CACHE LINE ON CACHE WRITE MISS OR JUST READ CACHE
            Done = 1;
            flip_victimway = 1;
            comp = 1;
            cache_en_0 = ~cache_install_q;
            cache_en_1 = cache_install_q;
            cache_write = Wr_q;
            cache_data_in = DataIn;
            DataOut = cache_data_out_valid;
            Stall = 1;
            offset = Addr[2:0];
            err = cache_err_0 | cache_err_1;
         end
         3'b111: begin // CURRENTLY UNUSED
            Stall = 1;
         end
      endcase
   end

endmodule // mem_system
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :9: