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
   reg cache_en_0, cache_en_1;
   reg cache_comp, cache_write;
   reg [15:0] cache_data_in, cache_addr;

   // cache outputs
   wire cache_hit_0, cache_valid_0, cache_dirty_0;
   wire cache_hit_1, cache_valid_1, cache_dirty_1;
   wire [4:0] actual_tag_0;
   wire [4:0] actual_tag_1;
   wire [15:0] cache_data_out_0;
   wire [15:0] cache_data_out_1;
   wire [15:0] cache_data_out;

   // 4-bank memory inputs
   reg mem_write, mem_read;
   reg [15:0] mem_data_in, mem_addr;

   // 4-bank memory outputs
   wire mem_stall;
   wire [3:0] mem_busy;
   wire [15:0] mem_data_out;

   // err signals
   wire cache_err_0, cache_err_1, mem_err; // controller_err

   reg [2:0] cache_offset;

   //NOTE: cache0 and cache1 are apart of the same SET, thus it is arbitrary which cache the data_in gets place into.
   // Because it doesn't matter (jk, they tell us which cache to send each addr to in the writeup) which cache we write to, 
   // we have to search both caches for the best one to evict
   parameter memtype = 0;
   cache #(0 + memtype) c0(// Outputs
                          .tag_out              (actual_tag_0),
                          .data_out             (cache_data_out_0),
                          .hit                  (cache_hit_0),
                          .dirty                (cache_dirty_0),
                          .valid                (cache_valid_0),
                          .err                  (cache_err_0),
                          // Inputs
                          .enable               (cache_en_0),
                          .clk                  (clk),
                          .rst                  (rst),
                          .createdump           (createdump),
                          .tag_in               (cache_addr[15:11]),
                          .index                (cache_addr[10:3]),
                          .offset               (cache_offset),
                          .data_in              (cache_data_in),
                          .comp                 (cache_comp),
                          .write                (cache_write),
                          .valid_in             (1'b1)); // maybe


   cache #(2 + memtype) c1(// Outputs
                          .tag_out              (actual_tag_1),
                          .data_out             (cache_data_out_1),
                          .hit                  (cache_hit_1),
                          .dirty                (cache_dirty_1),
                          .valid                (cache_valid_1),
                          .err                  (cache_err_1),
                          // Inputs
                          .enable               (cache_en_1),
                          .clk                  (clk),
                          .rst                  (rst),
                          .createdump           (createdump),
                          .tag_in               (cache_addr[15:11]),
                          .index                (cache_addr[10:3]),
                          .offset               (cache_offset),
                          .data_in              (cache_data_in),
                          .comp                 (cache_comp),
                          .write                (cache_write),
                          .valid_in             (1'b1));

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

   wire [3:0] cache_state, nxt_cache_state;
   reg [3:0] nxt_state;
   assign nxt_cache_state = nxt_state;
   
   wire cache_hit_0_ff, cache_valid_0_ff, cache_dirty_0_ff;
   wire cache_hit_1_ff, cache_valid_1_ff, cache_dirty_1_ff;

   wire [15:0]mem_data_out_ff;

   wire [15:0]data_in_ff;
   dff dataIn_ff[15:0](.d(DataIn), .q(data_in_ff), .rst(rst), .clk(clk));

   wire [15:0]addr_ff;
   dff address_ff[15:0](.d(Addr), .q(addr_ff), .rst(rst), .clk(clk));

   wire rd_ff, wr_ff;
   dff write_ff(.d(Wr), .q(wr_ff), .rst(rst), .clk(clk));
   dff read_ff(.d(Rd), .q(rd_ff), .rst(rst), .clk(clk));

   // State flop
   dff state_ff[3:0](.d(nxt_cache_state), .q(cache_state), .rst(rst), .clk(clk));
   dff data_ff[15:0](.d(mem_data_out), .q(mem_data_out_ff), .rst(rst), .clk(clk));

   // Cache output flops
   dff hit0_ff (.d(cache_hit_0), .q(cache_hit_0_ff), .rst(rst), .clk(clk));
   dff valid0_ff (.d(cache_valid_0), .q(cache_valid_0_ff), .rst(rst), .clk(clk));
   dff dirty0_ff (.d(cache_dirty_0), .q(cache_dirty_0_ff), .rst(rst), .clk(clk));

   dff hit1_ff (.d(cache_hit_1), .q(cache_hit_1_ff), .rst(rst), .clk(clk));
   dff valid1_ff (.d(cache_valid_1), .q(cache_valid_1_ff), .rst(rst), .clk(clk));
   dff dirty1_ff (.d(cache_dirty_1), .q(cache_dirty_1_ff), .rst(rst), .clk(clk));

   wire [15:0] cache_data_out_ff;

   //TODO: Don't invert on these conditions
   // - instructions that do not read or write cache
   // - invalid instructions
   // - instructions that are squashed due to branch misprediction (not for cache demo, worry about for integrating with pipeline)
   wire victimway, victimway_ff;
   reg toggle_victimway;
   assign victimway = (rst) ? 1'b0 : 
                     (toggle_victimway) ? ~victimway_ff : victimway_ff;

   dff iVICTIMWAY_ff(.d(victimway), .q(victimway_ff), .clk(clk), .rst(1'b0));

   wire real_hit_0, real_hit_1, real_hit;
   reg victimize_cache_0, victimize_cache_1;

   assign real_hit_0 = (cache_hit_0_ff & cache_valid_0_ff);
   assign real_hit_1 = (cache_hit_1_ff & cache_valid_1_ff);
   assign real_hit = real_hit_0 | real_hit_1;

   wire writeback, writeback_0, writeback_1;
   assign writeback_0 = cache_dirty_0_ff & cache_valid_0_ff;
   assign writeback_1 = cache_dirty_1_ff & cache_valid_1_ff;
   assign writeback = writeback_0 | writeback_1;

   assign cache_data_out = ((real_hit_1) | (victimize_cache_1 & ~(real_hit))) ? cache_data_out_1 : 
                           ((real_hit_0) | (victimize_cache_0 & ~(real_hit))) ? cache_data_out_0 :
                           cache_data_out_ff;
   dff cache_data_out_dff[15:0](.d(cache_data_out), .q(cache_data_out_ff), .rst(rst), .clk(clk));

   always @(cache_state or Rd or Wr) begin
      // Set default values
      // cache controller signals
      cache_en_0 = 1'b0;
      cache_en_1 = 1'b0;
      cache_comp = 1'b0;
      cache_write = Wr;
      cache_data_in = DataIn;
      cache_addr = Addr;
      cache_offset = cache_addr[2:0];

      victimize_cache_0 = victimize_cache_0;
      victimize_cache_1 = victimize_cache_1;
      toggle_victimway = 1'b0;

      // Top outputs
      Stall = (Rd | Wr) & ~Done;
      Done = 1'b0;
      DataOut = cache_data_out;
      CacheHit = 1'b0;
      err = cache_err_0 | cache_err_1 | mem_err;
   
      // 4-bank memory inputs
      mem_write = 1'b0;
      mem_read = 1'b0;
      mem_data_in = cache_data_out;
      mem_addr = cache_addr;

      // Default next_state to current state
      nxt_state = cache_state;
   
      // State machine
      case (cache_state)
         // IDLE
         4'b0000: begin
            cache_en_0 = (Rd | Wr);
            cache_en_1 = (Rd | Wr);
            cache_comp = (Rd | Wr);
            nxt_state = (Rd | Wr);
            nxt_state = (Rd | Wr) ? 4'b0010 : 4'b0000;
         end

         // Read or write comparison
         4'b0001: begin
            // Access to see if hit
            cache_en_0 = 1'b1;
            cache_en_1 = 1'b1;
            cache_comp = 1'b1;
            nxt_state = 4'b0010;
         end

         // Check if Hit state
         4'b0010: begin
            victimize_cache_0 = (~real_hit & 
                                 (~cache_valid_0_ff | 
                                 (cache_valid_0_ff & cache_valid_1_ff & victimway_ff))) ? 1'b1 : 1'b0;
            victimize_cache_1 = (~real_hit & 
                                 ((~cache_valid_1_ff & cache_valid_0_ff) | 
                                 (cache_valid_0_ff & cache_valid_1_ff & ~victimway_ff))) ? 1'b1 : 1'b0;
            // Miss so need to do access read
            cache_en_0 = (victimize_cache_0) ? 1'b1 : cache_en_0;
            cache_en_1 = (victimize_cache_1) ? 1'b1 : cache_en_1;
            //cache_comp = 1'b0 by default

            cache_write = (~real_hit) ? 1'b0 : cache_write;
            cache_offset = (~real_hit) ? 3'b000 : cache_offset;

            //Hit so done
            Done = real_hit;
            toggle_victimway = real_hit;
            CacheHit = real_hit;

            nxt_state = (~real_hit) ? 4'b0011 : ((Wr | Rd) ? 4'b0001 : 4'b0000);
         end

         // Check if dirty state
         4'b0011: begin
            // Dirty so need to do writeback
            cache_en_0 = (writeback_0 & victimize_cache_0) ? 1'b1 : cache_en_0;
            cache_en_1 = (writeback_1 & victimize_cache_1) ? 1'b1 : cache_en_1;
            //cache_comp = 1'b0 by default
            cache_write = (writeback) ? 1'b0 : cache_write;
            cache_offset = (writeback) ? 3'b010 : cache_offset;
            mem_write = (writeback) ? 1'b1 : mem_write;
            mem_addr = (writeback_0 & victimize_cache_0) ? {actual_tag_0, cache_addr[10:3], 3'b000} : 
                        (writeback_1 & victimize_cache_1) ? {actual_tag_1, cache_addr[10:3], 3'b000} :
                                                            {cache_addr[15:3], 3'b000};

            mem_read = ~(writeback) ? 1'b1 : mem_read;

            nxt_state = (writeback) ? 4'b0100 : 4'b1000;
         end

         // Mem write cycle 1
         4'b0100: begin
            cache_en_0 = (victimize_cache_0) ? 1'b1 : 1'b0;
            cache_en_1 = (victimize_cache_1) ? 1'b1 : 1'b0;
            cache_comp = 1'b0;
            cache_write = 1'b0;
            cache_offset = 3'b100;

            mem_write = 1'b1;
            mem_addr = (victimize_cache_0) ? {actual_tag_0, cache_addr[10:3], 3'b010} : 
                        (victimize_cache_1) ? {actual_tag_1, cache_addr[10:3], 3'b010} :
                                                            {cache_addr[15:3], 3'b010};
            nxt_state = 4'b0101;
         end

         // Mem write cycle 2
         4'b0101: begin
            cache_en_0 = (victimize_cache_0) ? 1'b1 : 1'b0;
            cache_en_1 = (victimize_cache_1) ? 1'b1 : 1'b0;
            cache_comp = 1'b0;
            cache_write = 1'b0;
            cache_offset = 3'b110;
            
            mem_write = 1'b1;
            mem_addr = (victimize_cache_0) ? {actual_tag_0, cache_addr[10:3], 3'b100} : 
                        (victimize_cache_1) ? {actual_tag_1, cache_addr[10:3], 3'b100} :
                                                            {cache_addr[15:3], 3'b100};
            nxt_state = 4'b0110;
         end

         // Mem write cycle 3
         4'b0110: begin
            mem_write = 1'b1;
            mem_addr = (victimize_cache_0) ? {actual_tag_0, cache_addr[10:3], 3'b110} : 
                        (victimize_cache_1) ? {actual_tag_1, cache_addr[10:3], 3'b110} :
                                                            {cache_addr[15:3], 3'b110};
            nxt_state = 4'b0111;
         end

         // Mem write finished, start read
         4'b0111: begin
            mem_read = 1'b1;
            mem_addr = {cache_addr[15:3], 3'b000};
            nxt_state = 4'b1000;
         end

         // Mem read cycle 1
         4'b1000: begin
            //Read the second word for the cache line
            mem_read = 1'b1;
            mem_addr = {cache_addr[15:3], 3'b010};

            nxt_state = 4'b1001;
         end

         // Mem read cycle 2
         4'b1001: begin
            //Read the third word for the cache line
            mem_read = 1'b1;
            mem_addr = {cache_addr[15:3], 3'b100};

            cache_offset = 3'b000;
            cache_en_0 = (victimize_cache_0) ? 1'b1 : 1'b0;
            cache_en_1 = (victimize_cache_1) ? 1'b1 : 1'b0;
            cache_comp = 1'b0;
            cache_write = 1'b1;
            cache_data_in = mem_data_out;

            // Do access write to cache next
            nxt_state = 4'b1010;
         end

         // Access write to cache
         4'b1010: begin
            //Read the fourth word for the cache line
            mem_read = 1'b1;
            mem_addr = {cache_addr[15:3], 3'b110};

            cache_offset = 3'b010;
            cache_en_0 = (victimize_cache_0) ? 1'b1 : 1'b0;
            cache_en_1 = (victimize_cache_1) ? 1'b1 : 1'b0;
            cache_comp = 1'b0;
            cache_write = 1'b1;
            cache_data_in = mem_data_out;

            nxt_state = 4'b1011;
         end

         4'b1011: begin
            cache_offset = 3'b100;
            cache_en_0 = (victimize_cache_0) ? 1'b1 : 1'b0;
            cache_en_1 = (victimize_cache_1) ? 1'b1 : 1'b0;
            cache_comp = 1'b0;
            cache_write = 1'b1;
            cache_data_in = mem_data_out;
            nxt_state = 4'b1100;
         end

         4'b1100: begin
            cache_offset = 3'b110;
            cache_en_0 = (victimize_cache_0) ? 1'b1 : 1'b0;
            cache_en_1 = (victimize_cache_1) ? 1'b1 : 1'b0;
            cache_comp = 1'b0;
            cache_write = 1'b1;
            cache_data_in = mem_data_out;
            nxt_state = 4'b1101;
         end

         // Done with cache miss, do comp read or write
         4'b1101: begin
            cache_en_0 = 1'b1;
            cache_en_1 = 1'b1;
            cache_comp = 1'b1;
            // Assert done next
            nxt_state = 4'b1110;
         end

         // Cache miss done
         4'b1110: begin
            //By here, the cache_out will be the correct value
            Done = 1'b1;
            toggle_victimway = 1'b1;

            cache_en_0 = (Wr | Rd) ? 1'b1 : cache_en_0;
            cache_en_1 = (Wr | Rd) ? 1'b1 : cache_en_1;
            cache_comp = (Wr | Rd) ? 1'b1 : cache_comp;
            
            nxt_state = (Wr | Rd) ? 4'b0010 : 4'b0000;
         end

         default: nxt_state = 4'b0000;
      endcase
    end

   
endmodule // mem_system
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :9: