`ifndef DATA_WIDTH;
	`define DATA_WIDTH 8
`endif

`ifndef DEPTH
	`define DEPTH 8
`endif

`ifndef PTR_WIDTH
	`define PTR_WIDTH 3
`endif

`timescale 1ns/1ps

interface sync_fifo_intf;
  
  logic clk, rst;
  logic [`DATA_WIDTH-1:0] data_in, data_out;
  logic wr_en, rd_en;
  logic full, empty;
  
endinterface

class transaction;
  
  rand bit [`DATA_WIDTH-1:0] data_in;
  rand bit wr_en, rd_en;
  
  constraint wr_rd_cons {
    wr_en^rd_en == 1'b1;
  }
  
  constraint data_cons {
    data_in inside {[1:15]};
  }
  
endclass

module tb;
  
  sync_fifo_intf intf();
  
  sync_fifo DUT (.clk(intf.clk), .rst(intf.rst), .data_in(intf.data_in), .wr_en(intf.wr_en), .rd_en(intf.rd_en), .full(full), .empty(empty), .data_out(intf.data_out));
  
  transaction trans;
  
  initial begin
    intf.clk <= 0;
  end
  
  always #5 intf.clk <= ~intf.clk;
  
  reg [`DATA_WIDTH-1:0] temp_data;
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
  
  task reset();
    intf.rst <= 1'b1;
    intf.wr_en <= 1'b0;
    intf.rd_en <= 1'b0;
    intf.data_in <= 0;
    temp_data <= 0;
    repeat(10) @(posedge intf.clk);
    $display("-------------");
    $display("RESET COMPLETE");
    intf.rst <= 1'b0;
  endtask
  
  task write(transaction trans);
    $display("PUSHING INTO THE FIFO");
    @(posedge intf.clk);
    intf.wr_en <= trans.wr_en;
    intf.data_in <= trans.data_in;
    @(posedge intf.clk);
    intf.wr_en <= 1'b0;
    if(intf.full) begin
      $display("FIFO IS FULL");
    end
    else begin
      $display("WRITTEN INTO FIFO: %0d", intf.data_in);
    end
    @(posedge intf.clk);
  endtask
  
  task read(transaction trans);
    $display("READING FROM FIFO");
    @(posedge intf.clk);
    intf.rd_en <= trans.rd_en;
    @(posedge intf.clk);
    intf.rd_en <= 1'b0;
    if(intf.empty) begin
      $display("FIFO IS EMPTY");
    end
    else if(!intf.empty)begin
      temp_data = intf.data_out;
      $display("DATA READ: %0d", temp_data);
    end
    @(posedge intf.clk);
  endtask
  
  task run();
    trans = new();
    assert(trans.randomize()) else $error("RANDOMIZATION FAILED");
    if(trans.wr_en) begin
      write(trans);
    end
    else begin
      read(trans);
    end
  endtask
  
  initial begin
    reset();
    repeat(15) run();
    $finish();
  end
  
endmodule
