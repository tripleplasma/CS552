/* $Author: karu $ */
/* $LastChangedDate: 2009-04-24 09:28:13 -0500 (Fri, 24 Apr 2009) $ */
/* $Rev: 77 $ */

`default_nettype none
module mem_system(/*AUTOARG*/
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

   // cache controller signals
   // cache inputs
   reg cache_en, cache_comp, cache_read, cache_write;
   wire force_disable;
   reg [15:0] cache_data_in, cache_addr;

   // cache outputs
   wire cache_hit, cache_valid, cache_dirty;
   wire real_hit, victimize;
   wire [4:0] actual_tag;
   wire [15:0] cache_data_out;

   // 4-bank memory inputs
   reg mem_write, mem_read;
   reg [15:0] mem_data_in, mem_addr;

   // 4-bank memory outputs
   wire mem_stall;
   wire [3:0] mem_busy;
   wire [15:0] mem_data_out;

   // err signals
   wire cache_err, mem_err; // controller_err


   assign force_disable = mem_stall;
   // wire mem_to_cache = ((mem_addr[2:1] == 2'b00 & ~mem_busy[0]) | 
   //                      (mem_addr[2:1] == 2'b01 & ~mem_busy[1]) | 
   //                      (mem_addr[2:1] == 2'b10 & ~mem_busy[2]) | 
   //                      (mem_addr[2:1] == 2'b11 & ~mem_busy[3])) ? 1'b1 : 1'b0;

   // assign cache_addr = Addr; // () ? : ; maybe
   // assign cache_data_in = (mem_to_cache) ? mem_data_out : DataIn;
   // assign cache_read = Rd;
   // assign cache_write = mem_to_cache | Wr;
   // assign cache_en = (cache_read | cache_write) & (~force_disable);
   // assign cache_comp = (cache_read | cache_write) & (~victimize) & (~mem_to_cache);

   /* data_mem = 1, inst_mem = 0 *
    * needed for cache parameter */
   parameter memtype = 0;
   cache #(0 + memtype) c0(// Outputs
                          .tag_out              (actual_tag),
                          .data_out             (cache_data_out),
                          .hit                  (cache_hit),
                          .dirty                (cache_dirty),
                          .valid                (cache_valid),
                          .err                  (cache_err),
                          // Inputs
                          .enable               (cache_en),
                          .clk                  (clk),
                          .rst                  (rst),
                          .createdump           (createdump),
                          .tag_in               (cache_addr[15:11]),
                          .index                (cache_addr[10:3]),
                          .offset               (cache_addr[2:0]),
                          .data_in              (cache_data_in),
                          .comp                 (cache_comp),
                          .write                (cache_write),
                          .valid_in             (1'b1)); // maybe

   // assign real_hit = cache_valid & cache_hit;
   // assign victimize = (~cache_hit) & cache_dirty;
    
   // assign mem_addr = (victimize) ? {actual_tag, cache_addr[10:0]} : cache_addr;
   // assign mem_data_in = cache_data_out; // (victimize) ? cache_data_out : ;
   // assign mem_write = victimize;
   // assign mem_read = ~real_hit;

   four_bank_mem mem(// Outputs
                     .data_out          (mem_data_out),
                     .stall             (mem_stall),
                     .busy              (mem_busy),
                     .err               (mem_err),
                     // Inputs
                     .clk               (clk),
                     .rst               (rst),
                     .createdump        (createdump),
                     .addr              (mem_addr),
                     .data_in           (mem_data_in),
                     .wr                (mem_write),
                     .rd                (mem_read));

   // 000 Comp 001 ACCESS_READ 010 DIRTY 011 CACHE_WRITEBACK 100 MEM_READ
   // TODO can use localparems for states
   reg [3:0] cache_state;
   reg [3:0] nxt_cache_state;
   // reg done_rdy, stall_rdy;

   /// OUTPUT FLOPS ///
   // State flop
   //dff state_ff[3:0](.d(nxt_cache_state), .q(cache_state), .rst(rst), .clk(clk));
   // Done flop
   //dff done_ff(.d(done_rdy), .q(Done), .rst(rst), .clk(clk));
   // Stall flop
   //dff stall_ff(.d(stall_rdy), .q(Stall), .rst(rst), .clk(clk));
   // Cache hit flop
   //dff cacheHit_ff(.d(cache_hit & cache_valid), .q(CacheHit), .rst(rst), .clk(clk));
   // Data out flop
   //dff dataOut_ff[15:0](.d(cache_data_out), .q(DataOut), .rst(rst), .clk(clk));
   // err flop
   //dff err_ff(.d(mem_err | cache_err), .q(err), .rst(rst), .clk(clk));

   always @(*) begin
      // Set default values
      // cache controller signals
      // cache inputs
      cache_en = 1'b0;
      cache_comp = 1'b0;
      cache_read = Rd;
      cache_write = Wr;
      cache_data_in = DataIn;
      cache_addr = Addr;

      // Top outops
      Stall = 1'b0;
      // TODO Done won't be asserted for 1 cycle, may be less
      Done = 1'b0;
      CacheHit = cache_hit & cache_valid;
      DataOut = cache_data_out;
      err = mem_err | cache_err;

      cache_state = nxt_cache_state;
   
      // cache outputs
      // wire cache_hit, cache_valid, cache_dirty;
      // wire real_hit, victimize;
      // wire [4:0] actual_tag;
      // wire [15:0] cache_data_out;
   
      // 4-bank memory inputs
      mem_write = 1'b0;
      mem_read = 1'b0;
      mem_data_in = cache_data_out;
      mem_addr = cache_addr;
   
      // 4-bank memory outputs
      // wire mem_stall;
      // wire [3:0] mem_busy;
      // wire [15:0] mem_data_out;

      // State machine
      case (cache_state)
         // Do cache comparison read or write, also IDLE
         3'b000: begin
            cache_en = Rd | Wr;
            cache_comp = Rd | Wr;
            if (Rd | Wr) begin
               // Access to see if hit
               nxt_cache_state = 3'b001;
            end
         end

         3'b001: begin
            // Miss so need to do access read
            if (~cache_hit | ~cache_valid) begin
               cache_en = 1'b1;
               cache_comp = 1'b0;
               cache_write = 1'b0;
               cache_read = 1'b1;
               // Keep cache address the same
               Stall = 1'b1;
               cache_addr = cache_addr;
               nxt_cache_state = 3'b010;
            end else begin
               // Hit so done and can take in new input
               Done = 1'b1;
               nxt_cache_state = 3'b000;
            end
         end
          
         3'b010: begin
            // Keep cache address the same
            Stall = 1'b1;
            cache_addr = cache_addr;
            if (cache_dirty) begin
               // Dirty so do memory writeback
               mem_addr = {actual_tag, cache_addr[10:0]};
               mem_write = 1'b1;
               nxt_cache_state = 3'b011;
            end else begin
               // Not dirty so can do mem read
               mem_addr = cache_addr;
               mem_read = 1'b1;
               nxt_cache_state = 3'b100;
            end

         end

         3'b011: begin
            // Keep cache address the same
            Stall = 1'b1;
            cache_addr = cache_addr;
            // Finished writeback when mem no longer busy
            if (~|mem_busy) begin
               mem_read = 1'b1;
               nxt_cache_state = 3'b100;
            end
         end

         3'b100: begin
            // Keep cache address the same
            Stall = 1'b1;
            cache_addr = cache_addr;
            // Finished read when mem no longer busy
            if (~|mem_busy) begin
               // Can now do access write
               cache_en = 1'b1;
               cache_comp = 1'b0;
               cache_write = 1'b1;
               cache_read = 1'b0;
               cache_data_in = mem_data_out;
               Done = 1'b1;
               nxt_cache_state = 3'b000;
            end
         end

         default: nxt_cache_state = 3'b000;
      endcase
    end
   
   // Module Outputs
   //always @(*) begin
   //   DataOut = (real_hit) ? cache_data_out : mem_data_out;
   //   Done = real_hit | mem_to_cache;
   //   Stall = mem_stall;
   //   CacheHit = real_hit;
   //   err = cache_err | mem_err; // | controller_err;
   //end

   
endmodule // mem_system
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :9:
