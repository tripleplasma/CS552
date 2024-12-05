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

   wire [4:0] cache_state, nxt_cache_state;
   reg [4:0] nxt_state;
   assign nxt_cache_state = nxt_state;
   
   wire cache_hit_ff, cache_valid_ff, cache_dirty_ff;
   wire [15:0]mem_data_out_ff;

   wire [15:0]data_in_ff;
   dff dataIn_ff[15:0](.d(DataIn), .q(data_in_ff), .rst(rst), .clk(clk));

   wire [15:0]addr_ff;
   dff address_ff[15:0](.d(Addr), .q(addr_ff), .rst(rst), .clk(clk));

   wire rd_ff, wr_ff;
   dff write_ff(.d(Wr), .q(wr_ff), .rst(rst), .clk(clk));
   dff read_ff(.d(Rd), .q(rd_ff), .rst(rst), .clk(clk));

   // State flop
   dff state_ff[4:0](.d(nxt_cache_state), .q(cache_state), .rst(rst), .clk(clk));
   dff data_ff[15:0](.d(mem_data_out), .q(mem_data_out_ff), .rst(rst), .clk(clk));

   // Cache output flops
   dff hit_ff (.d(cache_hit), .q(cache_hit_ff), .rst(rst), .clk(clk));
   dff valid_ff (.d(cache_valid), .q(cache_valid_ff), .rst(rst), .clk(clk));
   dff dirty_ff (.d(cache_dirty), .q(cache_dirty_ff), .rst(rst), .clk(clk));

   always @(cache_state or Rd or Wr) begin
      // Set default values
      // cache controller signals
      
      cache_en = 1'b0;
      cache_comp = 1'b0;
      cache_read = Rd;
      cache_write = Wr;
      cache_data_in = data_in_ff;
      cache_addr = addr_ff;
      cache_offset = cache_addr[2:0];

      // Top outops
      Done = 1'b0;
      Stall = (Rd | Wr) & ~Done;
      DataOut = cache_data_out;
      CacheHit = 1'b0;
      err = cache_err | mem_err;
   
      // cache outputs
      // wire cache_hit, cache_valid, cache_dirty;
      // wire [4:0] actual_tag;
      // wire [15:0] cache_data_out;
   
      // 4-bank memory inputs
      mem_write = 1'b0;
      mem_read = 1'b0;
      mem_data_in = cache_data_out;
      mem_addr = cache_addr;

      // Default next_state to current state
      nxt_state = cache_state;
   
      // 4-bank memory outputs
      // wire mem_stall;
      // wire [3:0] mem_busy;
      // wire [15:0] mem_data_out;

      // State machine
      case (cache_state)
         // IDLE
         5'b00000: begin
            if (Rd | Wr) begin
               // Go to Comp State
               nxt_state = 5'b00001;
            end
         end

         // Read or write comparison
         5'b00001: begin
            // Access to see if hit
            cache_en = 1'b1;
            cache_comp = 1'b1;
            // nxt_state = 5'b00010;

            // Miss so need to do access read
            if (~cache_hit_ff | ~cache_valid_ff) begin
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

         // Check if Hit state
         // 5'b0010: begin
         //    // Miss so need to do access read
         //    if (~cache_hit_ff | ~cache_valid_ff) begin
         //       nxt_state = 5'b00011;
         //    end else begin
         //       // Hit so done
         //       Done = 1'b1;
         //       CacheHit = 1'b1;
         //       if (Wr | Rd) begin
         //          // Go to Idle state
         //          nxt_state = 5'b00001;
         //       end else begin
         //          // Go to comp
         //          nxt_state = 5'b00000;
         //       end
         //    end
         // end

         // Access read to cache
         5'b00011: begin
            cache_en = 1'b1;
            cache_comp = 1'b0;
            cache_read = 1'b1;
            cache_write = 1'b0;
            nxt_state = 5'b00100;
            // if (cache_dirty_ff & cache_valid_ff) begin
               cache_offset = 3'b000;
            // end
         end

         // Check if dirty state
         5'b00100: begin
            // Dirty so need to do writeback
            if (cache_dirty_ff & cache_valid_ff) begin
               cache_en = 1'b1;
               cache_comp = 1'b0;
               cache_read = 1'b1;
               cache_write = 1'b0;
               cache_offset = 3'b010;

               mem_write = 1'b1;
               mem_addr = {actual_tag, cache_addr[10:3], 3'b000};
               nxt_state = 5'b01000;
            end else begin
               // Not dirty so can do mem read
               mem_read = 1'b1;
               mem_addr = {cache_addr[15:3], 3'b000}; //Since we're putting all four words into the cache line anyways, it doesn't matter which offset we do first
               nxt_state = 5'b00101;
            end
         end

         // Mem read cycle 1
         5'b00101: begin
            //Read the second word for the cache line
            mem_read = 1'b1;
            mem_addr = {cache_addr[15:3], 3'b010};

            nxt_state = 5'b00111;
         end

         // Mem read cycle 2
         5'b00111: begin
            //Read the third word for the cache line
            mem_read = 1'b1;
            mem_addr = {cache_addr[15:3], 3'b100};

            cache_offset = 3'b000;
            cache_en = 1'b1;
            cache_comp = 1'b0;
            cache_read = 1'b0;
            cache_write = 1'b1;
            cache_data_in = mem_data_out;

            // Do access write to cache next
            nxt_state = 5'b01100;
         end

         // Mem write cycle 1
         5'b01000: begin
            cache_en = 1'b1;
            cache_comp = 1'b0;
            cache_read = 1'b1;
            cache_write = 1'b0;
            cache_offset = 3'b100;

            mem_write = 1'b1;
            mem_addr = {actual_tag, cache_addr[10:3], 3'b010};
            nxt_state = 5'b01001;
         end

         // Mem write cycle 2
         5'b01001: begin
            cache_en = 1'b1;
            cache_comp = 1'b0;
            cache_read = 1'b1;
            cache_write = 1'b0;
            cache_offset = 3'b110;
            
            mem_write = 1'b1;
            mem_addr = {actual_tag, cache_addr[10:3], 3'b100};
            nxt_state = 5'b01010;
         end

         // Mem write cycle 3
         5'b01010: begin
            mem_write = 1'b1;
            mem_addr = {actual_tag, cache_addr[10:3], 3'b110};
            nxt_state = 5'b01011;
         end

         // Mem write finished, start read
         5'b01011: begin
            mem_read = 1'b1;
            mem_addr = {cache_addr[15:3], 3'b000}; //Since we're putting all four words into the cache line anyways, it doesn't matter which offset we do first
            nxt_state = 5'b00101;
         end

         // Extra write cycle
         // 5'b01101: begin
         //    // Now do mem read
         //    mem_read = 1'b1;
         //    nxt_state = 5'b00100;
         // end

         // Access write to cache
         5'b01100: begin
            //Read the fourth word for the cache line
            mem_read = 1'b1;
            mem_addr = {cache_addr[15:3], 3'b110};

            cache_offset = 3'b010;
            cache_en = 1'b1;
            cache_comp = 1'b0;
            cache_read = 1'b0;
            cache_write = 1'b1;
            cache_data_in = mem_data_out;

            // nxt_state = 5'b01110;
            nxt_state = 5'b10000;
         end

         //TODO: Add 3 more states simply to write the values of the three other words into the cache
         5'b10000: begin
            cache_offset = 3'b100;
            cache_en = 1'b1;
            cache_comp = 1'b0;
            cache_read = 1'b0;
            cache_write = 1'b1;
            cache_data_in = mem_data_out;
            nxt_state = 5'b10001;
         end

         5'b10001: begin
            cache_offset = 3'b110;
            cache_en = 1'b1;
            cache_comp = 1'b0;
            cache_read = 1'b0;
            cache_write = 1'b1;
            cache_data_in = mem_data_out;
            nxt_state = 5'b01110;
         end

         // Done with cache miss, do comp read or write
         5'b01110: begin
            cache_en = 1'b1;
            cache_comp = 1'b1;
            // Assert done next
            nxt_state = 5'b01111;
         end

         // Cache miss done
         5'b01111: begin
            //By here, the cache_out will be the correct value
            Done = 1'b1;
            if (Wr | Rd) begin
               // Go to Idle state
               nxt_state = 5'b00001;
            end else begin
               // Go to comp
               nxt_state = 5'b00000;
            end
         end

         default: nxt_state = 5'b00000;
      endcase
    end

   
endmodule // mem_system
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :9: