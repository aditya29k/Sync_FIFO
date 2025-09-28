`ifndef DATA_WIDTH;
	`define DATA_WIDTH 8
`endif

`ifndef DEPTH
	`define DEPTH 8
`endif

`ifndef PTR_WIDTH
	`define PTR_WIDTH 3
`endif

module sync_fifo(
  input clk, rst,
  input [`DATA_WIDTH-1:0] data_in,
  input wr_en, rd_en,
  output full, empty,
  output reg [`DATA_WIDTH-1:0] data_out
);
  
  reg [`PTR_WIDTH:0] wr_ptr, rd_ptr;
  
  reg [`DATA_WIDTH-1:0] fifo [0:`DEPTH-1];
  integer i;
  
  always@(posedge clk) begin
    
    if(rst) begin
      wr_ptr <= 0;
      rd_ptr <= 0;
      data_out <= 0;
      for(i=0; i<`PTR_WIDTH; i=i+1) begin
        fifo[i] <= 0;
      end
    end
    else begin
      if(wr_en&&!full) begin
        fifo[wr_ptr] <= data_in;
        wr_ptr <= wr_ptr + 1;
      end
      else if(rd_en&&!empty) begin
        data_out <= fifo[rd_ptr];
        rd_ptr <= rd_ptr + 1;
      end
    end
    
  end
  
  assign full = (wr_ptr[`PTR_WIDTH] != rd_ptr[`PTR_WIDTH])&&(wr_ptr[`PTR_WIDTH-1:0] == rd_ptr[`PTR_WIDTH-1:0]);
  assign empty = (wr_ptr == rd_ptr);
  
endmodule
