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
   reg cache_en, cache_comp, cache_write;
   reg [15:0] cache_data_in, cache_addr;

   // cache outputs
   wire cache_hit, cache_valid, cache_dirty;
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

   wire [3:0] cache_state, nxt_cache_state;
   reg [3:0] nxt_state;
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
   dff state_ff[3:0](.d(nxt_cache_state), .q(cache_state), .rst(rst), .clk(clk));
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
      cache_write = Wr;
      cache_data_in = DataIn;
      cache_addr = Addr;
      cache_offset = cache_addr[2:0];

      // Top outputs
      Done = 1'b0;
      Stall = (Rd | Wr) & ~Done;
      DataOut = cache_data_out;
      CacheHit = 1'b0;
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
         4'b0000: begin
            cache_en = (Rd | Wr);
            cache_comp = (Rd | Wr);
            nxt_state = (Rd | Wr) ? 4'b0010 : 4'b0000;
         end

         // Read or write comparison
         4'b0001: begin
            // Access to see if hit
            cache_en = 1'b1;
            cache_comp = 1'b1;
            nxt_state = 4'b0010;
         end

         // Check if Hit state
         4'b0010: begin
            // Miss so need to do access read
            cache_en = (~cache_hit_ff | ~cache_valid_ff) ? 1'b1 : cache_en;
            //cache_comp = 1'b0 by default
            cache_write = (~cache_hit_ff | ~cache_valid_ff) ? 1'b0 : cache_write;
            cache_offset = (~cache_hit_ff | ~cache_valid_ff) ? 3'b000 : cache_offset;

            //Hit so done
            Done = (cache_hit_ff & cache_valid_ff);
            CacheHit = (cache_hit_ff & cache_valid_ff);

            nxt_state = (~cache_hit_ff | ~cache_valid_ff) ? 4'b0011 : ((Wr | Rd) ? 4'b0001 : 4'b0000);
         end

         // Check if dirty state
         4'b0011: begin
            // Dirty so need to do writeback
            cache_en = (cache_dirty_ff & cache_valid_ff) ? 1'b1 : cache_en;
            //cache_comp = 1'b0 by default
            cache_write = (cache_dirty_ff & cache_valid_ff) ? 1'b0 : cache_write;
            cache_offset = (cache_dirty_ff & cache_valid_ff) ? 3'b010 : cache_offset;
            mem_write = (cache_dirty_ff & cache_valid_ff) ? 1'b1 : mem_write;
            mem_addr = (cache_dirty_ff & cache_valid_ff) ? {actual_tag, cache_addr[10:3], 3'b000} : {cache_addr[15:3], 3'b000};

            mem_read = ~(cache_dirty_ff & cache_valid_ff) ? 1'b1 : mem_read;

            nxt_state = (cache_dirty_ff & cache_valid_ff) ? 4'b0100 : 4'b1000;
         end

         // Mem write cycle 1
         4'b0100: begin
            cache_en = 1'b1;
            cache_comp = 1'b0;
            cache_write = 1'b0;
            cache_offset = 3'b100;

            mem_write = 1'b1;
            mem_addr = {actual_tag, cache_addr[10:3], 3'b010};
            nxt_state = 4'b0101;
         end

         // Mem write cycle 2
         4'b0101: begin
            cache_en = 1'b1;
            cache_comp = 1'b0;
            cache_write = 1'b0;
            cache_offset = 3'b110;
            
            mem_write = 1'b1;
            mem_addr = {actual_tag, cache_addr[10:3], 3'b100};
            nxt_state = 4'b0110;
         end

         // Mem write cycle 3
         4'b0110: begin
            mem_write = 1'b1;
            mem_addr = {actual_tag, cache_addr[10:3], 3'b110};
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
            cache_en = 1'b1;
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
            cache_en = 1'b1;
            cache_comp = 1'b0;
            cache_write = 1'b1;
            cache_data_in = mem_data_out;

            nxt_state = 4'b1011;
         end

         4'b1011: begin
            cache_offset = 3'b100;
            cache_en = 1'b1;
            cache_comp = 1'b0;
            cache_write = 1'b1;
            cache_data_in = mem_data_out;
            nxt_state = 4'b1100;
         end

         4'b1100: begin
            cache_offset = 3'b110;
            cache_en = 1'b1;
            cache_comp = 1'b0;
            cache_write = 1'b1;
            cache_data_in = mem_data_out;
            nxt_state = 4'b1101;
         end

         // Done with cache miss, do comp read or write
         4'b1101: begin
            cache_en = 1'b1;
            cache_comp = 1'b1;
            // Assert done next
            nxt_state = 4'b1110;
         end

         // Cache miss done
         4'b1110: begin
            //By here, the cache_out will be the correct value
            Done = 1'b1;

            cache_en = (Wr | Rd) ? 1'b1 : cache_en;
            cache_comp = (Wr | Rd) ? 1'b1 : cache_comp;
            
            nxt_state = (Wr | Rd) ? 4'b0010 : 4'b0000;
         end

         default: nxt_state = 4'b0000;
      endcase
    end

   
endmodule // mem_system
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :9: