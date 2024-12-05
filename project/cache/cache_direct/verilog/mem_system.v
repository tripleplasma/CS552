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

   /* data_mem = 1, inst_mem = 0 *
    * needed for cache parameter */
   reg [2:0] cache_offset;
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
                          .offset               (cache_offset),
                          .data_in              (cache_data_in),
                          .comp                 (cache_comp),
                          .write                (cache_write),
                          .valid_in             (1'b1)); // maybe

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

   wire [4:0] cache_state;
   reg [4:0] nxt_state;

   // State flop
   dff state_ff[4:0](.d(nxt_state), .q(cache_state), .rst(rst), .clk(clk));
   
   // reg hadCacheHit;
   always @(cache_state or Rd or Wr or cache_hit or cache_valid or cache_dirty) begin
      // Set default values
      // cache controller signals
      
      cache_en = 1'b0;
      cache_comp = 1'b0;
      cache_read = Rd;
      cache_write = Wr;
      cache_data_in = DataIn;
      cache_addr = Addr;
      cache_offset = cache_addr[2:0];

      // Top outops
      Done = 1'b0;
      Stall = (Rd | Wr) & ~Done;
      DataOut = cache_data_out;
      CacheHit = 1'b0;
      // hadCacheHit = 1'b0;
      err = cache_err | mem_err;
   
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
         5'b00000: begin
            if (Rd | Wr) begin
               // Go to Comp State
               nxt_state = 5'b00001;
            end
         end

         // Read or write comparisson
         5'b00001: begin
            // Access to see if hit
            cache_en = 1'b1;
            cache_comp = 1'b1;
            nxt_state = ~(cache_hit & cache_valid) ? 5'b00011 : 5'b00010;
         end

         //Cache Hit State
         5'b00010: begin
            // Miss so need to do access read
            if (~cache_hit | ~cache_valid) begin
               nxt_state = 5'b00011;
            end else begin
               // Hit so done
               Done = 1'b1;
               CacheHit = 1'b1;
               if (Wr | Rd) begin
                  // Go to Idle state
                  nxt_state = 5'b00001;
               end else begin
                  // Go to comp
                  nxt_state = 5'b00000;
               end
            end
         end

         // Cache Miss - Access read to cache, returns the tag and data_out from that index and word-offset in the cache
         5'b00011: begin
            cache_en = 1'b1;
            cache_comp = 1'b0;
            cache_read = 1'b1;
            cache_write = 1'b0;

            //Check if the cacheline was dirty before writing new words into cacheline
            if (cache_dirty & cache_valid) begin
               nxt_state = 5'b00100;
            end else begin
               nxt_state = 5'b10100;
            end
         end
         
         //========================== START OF EVICTS ==========================

         5'b10100: begin
            mem_read = 1'b1;
            mem_addr = {cache_addr[15:3], 3'b000}; //Since we're putting all four words into the cache line anyways, it doesn't matter which offset we do first
            nxt_state = 5'b00101;
         end

         // Mem read cycle 1
         5'b00101: begin
            // Queue the write of Word1 from memory into the cacheline
            mem_read = 1'b1;
            mem_addr = {cache_addr[15:3], 3'b010};

            nxt_state = 5'b00111;
         end

         // Mem read cycle 2
         5'b00111: begin
            // Queue the write of Word2 from memory into the cacheline
            mem_read = 1'b1;
            mem_addr = {cache_addr[15:3], 3'b100};

            // Write Word0 from memory into cacheline
            cache_offset = 3'b000;
            cache_en = 1'b1;
            cache_comp = 1'b0;
            cache_read = 1'b0;
            cache_write = 1'b1;
            cache_data_in = mem_data_out;

            nxt_state = 5'b01100;
         end

         // Mem read cycle 3
         5'b01100: begin
            // Queue the write of Word3 from memory into the cacheline
            mem_read = 1'b1;
            mem_addr = {cache_addr[15:3], 3'b110};

            // Write Word1 from memory into cacheline
            cache_offset = 3'b010;
            cache_en = 1'b1;
            cache_comp = 1'b0;
            cache_read = 1'b0;
            cache_write = 1'b1;
            cache_data_in = mem_data_out;

            nxt_state = 5'b10000;
         end

         // Mem read cycle 4
         5'b10000: begin
            // Write Word2 from memory into cacheline
            cache_offset = 3'b100;
            cache_en = 1'b1;
            cache_comp = 1'b0;
            cache_read = 1'b0;
            cache_write = 1'b1;
            cache_data_in = mem_data_out;
            nxt_state = 5'b10001;
         end

         // Mem read cycle 5
         5'b10001: begin
            // Write Word3 from memory into cacheline
            cache_offset = 3'b110;
            cache_en = 1'b1;
            cache_comp = 1'b0;
            cache_read = 1'b0;
            cache_write = 1'b1;
            cache_data_in = mem_data_out;

            // Completed Victimization, go to pre-done state
            nxt_state = Wr ? 5'b10010 : 5'b01110;
         end

         //After we finish evicting and replacing everything, actually do the write to cache since we were writing Word3 in the previous state
         5'b10010: begin
            cache_en = 1'b1;
            cache_comp = 1'b0;
            nxt_state = 5'b01110;
         end

         //========================== END OF EVICTS ==========================
         //========================== START OF WRITEBACK WITH DIRTY ==========================
         5'b00100: begin
            mem_write = 1'b1;
            mem_addr = {actual_tag, cache_addr[10:3], 3'b000};
            nxt_state = 5'b01000;
         end

         // Mem write cycle 1
         5'b01000: begin
            mem_write = 1'b1;
            mem_addr = {actual_tag, cache_addr[10:3], 3'b010};
            nxt_state = 5'b01001;
         end

         // Mem write cycle 2
         5'b01001: begin
            mem_write = 1'b1;
            mem_addr = {actual_tag, cache_addr[10:3], 3'b100};
            nxt_state = 5'b01010;
         end

         // Mem write cycle 3
         5'b01010: begin
            mem_write = 1'b1;
            mem_addr = {actual_tag, cache_addr[10:3], 3'b110};
            nxt_state = 5'b01110;
         end
         //========================== END OF WRITEBACK WITH DIRTY ==========================

         // Done with cache miss, do comp read or write. This ensures that it hits after everything is in the cache
         5'b01110: begin
            cache_en = 1'b1;
            cache_comp = 1'b1;
            // Assert done next
            // nxt_state = 5'b01111;
            // CacheHit = hadCacheHit;
            Done = 1'b1;
            if (Wr | Rd) begin
               // Go to Idle state
               nxt_state = 5'b00001;
            end else begin
               // Go to comp
               nxt_state = 5'b00000;
            end
         end

         // Cache miss done
         // 5'b01111: begin
         //    Done = 1'b1;
         //    if (Wr | Rd) begin
         //       // Go to Idle state
         //       nxt_state = 5'b00001;
         //    end else begin
         //       // Go to comp
         //       nxt_state = 5'b00000;
         //    end
         // end

         default: nxt_state = 5'b00000;
      endcase
    end

   
endmodule // mem_system
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :9: