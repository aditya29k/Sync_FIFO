`ifndef DATA_WIDTH 
	`define DATA_WIDTH 8
`endif

`ifndef DEPTH 
	`define DEPTH 8
`endif

`ifndef PTR_WIDTH
	`define PTR_WIDTH 3
`endif

interface intf_fifo;
  
  logic clk, rst;
  logic [`DATA_WIDTH-1:0] data_in;
  logic wr_en, rd_en;
  logic full, empty;
  logic [`DATA_WIDTH-1:0] data_out;
  
endinterface

class transaction;
  
  rand bit [`DATA_WIDTH-1:0] data_in;
  rand bit wr_en, rd_en;
  
endclass

module tb;
  
  intf_fifo intf();
  
  sync_fifo DUT (.clk(intf.clk), .rst(intf.rst), .data_in(intf.data_in), .wr_en(intf.wr_en), .rd_en(intf.rd_en), .full(intf.full), .empty(intf.empty), .data_out(intf.data_out));
  
  transaction trans;
  
  initial begin
    intf.clk <= 1'b0;
  end
  
  always #5 intf.clk <= ~intf.clk;
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
  
  task reset();
    intf.rst <= 1'b1;
    intf.data_in <= 0;
    intf.wr_en <= 1'b0;
    intf.rd_en <= 1'b0;
    repeat(5) @(posedge intf.clk);
    intf.rst <= 1'b0;
    $display("system reset");
  endtask
  
  task write(transaction trans);
    @(posedge intf.clk);
    intf.wr_en <= trans.wr_en;
    intf.data_in <= trans.data_in;
    @(posedge intf.clk);
    intf.wr_en <= 1'b0;
    if(intf.full) $display("FIFO FULL");
    else $display("WRITE DATA: %0d", intf.data_in);
    @(posedge intf.clk);
  endtask
  
  task read(transaction trans);
    @(posedge intf.clk);
    intf.rd_en <= trans.rd_en;
    @(posedge intf.clk);
    intf.rd_en <= 1'b0;
    #1
    if(intf.empty) $display("last data: %0d FIFO EMPTY", intf.data_out);
    else $display("READ DATA: %0d", intf.data_out);
    @(posedge intf.clk);
  endtask
  
  task run();
    trans = new();
    assert(trans.randomize()) else $error("RANDOMIZATION FAILED");
    fork
      if(trans.wr_en) write(trans);
      if(trans.rd_en) read(trans);
    join
  endtask
  
  initial begin
    reset();
    repeat(10) run();
    $finish();
  end
  
endmodule
