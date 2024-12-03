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
   // wire real_hit, victimize;
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

   wire [3:0] cache_state;
   reg [3:0] nxt_state;
   wire [3:0] nxt_cache_state;
   assign nxt_cache_state = nxt_state;
   
   wire cache_hit_ff, cache_valid_ff, cache_dirty_ff;
   wire [15:0]mem_data_out_ff;

   // State flop
   dff state_ff[3:0](.d(nxt_cache_state), .q(cache_state), .rst(rst), .clk(clk));
   dff data_ff[15:0](.d(mem_data_out), .q(mem_data_out_ff), .rst(rst), .clk(clk));

   // Cache output flops
   dff hit_ff (.d(cache_hit), .q(cache_hit_ff), .rst(rst), .clk(clk));
   dff valid_ff (.d(cache_valid), .q(cache_valid_ff), .rst(rst), .clk(clk));
   dff dirty_ff (.d(cache_dirty), .q(cache_dirty_ff), .rst(rst), .clk(clk));
   
   // not allowed
   // always @(posedge clk or posedge rst) begin
   //   if (rst) begin
   //       Stall <= 1'b0;
   //       Done <= 1'b0;
   //       CacheHit <= 1'b0;
   //       DataOut <= 16'h0000;
   //   end else begin
   //       Stall <= stall_rdy & ~done_rdy;
   //       Done <= done_rdy;
   //       CacheHit <= CacheHit_nxt;
   //       DataOut <= DataOut_nxt;
   //   end
   //end

   always @(cache_state or Rd or Wr) begin
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
      Done = 1'b0;
      Stall = (Rd | Wr) & ~Done;
      DataOut = cache_data_out;
      CacheHit = 1'b0;
      err = cache_err | mem_err;
   
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

      nxt_state = 4'b0000;
   
      // 4-bank memory outputs
      // wire mem_stall;
      // wire [3:0] mem_busy;
      // wire [15:0] mem_data_out;

      // State machine
      case (cache_state)
         // IDLE
         4'b0000: begin
            if (Rd | Wr) begin
               // Go to Comp State
               nxt_state = 4'b0001;
            end
         end

         // Done
         4'b1111: begin
            Done = 1'b1;
            if (Rd | Wr) begin
               // Go to Comp State
               nxt_state = 4'b0001;
            end else begin
               // Go to Idle state
               nxt_state = 4'b0000;
            end
         end

         // Read or write comparisson
         4'b0001: begin
            // Access to see if hit
            cache_en = 1'b1;
            cache_comp = 1'b1;
            nxt_state = 4'b0010;
         end

         // Check if Hit state
         4'b0010: begin
            // Miss so need to do access read
            if (~cache_hit_ff | ~cache_valid_ff) begin
               nxt_state = 4'b0011;
            end else begin
               // Hit so done
               // nxt_state = 4'b1111;
               Done = 1'b1;
               CacheHit = 1'b1;
               if (Rd | Wr) begin
               // Go to Comp State
               nxt_state = 4'b0001;
               end else begin
                  // Go to Idle state
                  nxt_state = 4'b0000;
               end
            end
         end

         // Access read to cache
         4'b0011: begin
            cache_en = 1'b1;
            cache_comp = 1'b0;
            cache_read = 1'b1;
            cache_write = 1'b0;
            nxt_state = 4'b0100;
         end

         // Check if dirty state
         4'b0100: begin
            // Dirty so need to do writeback
            if (cache_dirty_ff & cache_valid_ff) begin
               mem_write = 1'b1;
               nxt_state = 4'b1000;
            end else begin
               // Not dirty so can do mem read
               mem_read = 1'b1;
               nxt_state = 4'b0101;
            end
         end

         // Mem read cycle 1
         4'b0101: begin
            nxt_state = 4'b0111;
         end

         // Mem read cycle 2
         4'b0111: begin
            // Do access write to cache next
            nxt_state = 4'b1100;
         end

         // Mem write cycle 1
         4'b1000: begin
            mem_addr = {actual_tag, cache_addr[10:0]};
            nxt_state = 4'b1001;
         end

         // Mem write cycle 2
         4'b1001: begin
            mem_addr = {actual_tag, cache_addr[10:0]};
            nxt_state = 4'b1010;
         end

         // Mem write cycle 3
         4'b1010: begin
            mem_addr = {actual_tag, cache_addr[10:0]};
            nxt_state = 4'b1011;
         end

         // Mem write cycle 4
         4'b1011: begin
            mem_addr = {actual_tag, cache_addr[10:0]};
            nxt_state = 4'b1101;
         end

         // Extra write cycle
         4'b1101: begin
            // Now do mem read
            mem_read = 1'b1;
            nxt_state = 4'b0101;
         end

         // Access write to cache
         4'b1100: begin
            cache_en = 1'b1;
            cache_comp = 1'b0;
            cache_read = 1'b0;
            cache_write = 1'b1;
            cache_data_in = mem_data_out_ff;
            nxt_state = 4'b1110;
         end

         // Done with cache miss, do read or write
         4'b1110: begin
            cache_en = 1'b1;
            cache_comp = 1'b1;
            nxt_state = 4'b1111;
         end

         default: nxt_state = 4'b0000;
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
