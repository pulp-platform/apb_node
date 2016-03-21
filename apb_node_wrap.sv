// Copyright 2016 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the “License”); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// =============================================================================== //
// Engineer:       Davide Rossi - davide.rossi@unibo.it                            //
//                                                                                 //
// Design Name:    APB NODE WRAPPER                                                //
// Module Name:    APB_BUS                                                         //
// Project Name:   PULP                                                            //
// Language:       SystemVerilog                                                   //
//                                                                                 //
// Description:    This component implements a wrapper for a configurable APB node //
//                                                                                 //
// =============================================================================== //

module apb_node_wrap
  #(
    parameter NB_MASTER = 8,
    parameter APB_DATA_WIDTH = 32,
    parameter APB_ADDR_WIDTH = 32
    )
   (
    input logic                                      clk_i,
    input logic                                      rst_ni,
    
    // SLAVE PORT
    APB_BUS.Slave                                    apb_slave,
    
    // MASTER PORTS
    APB_BUS.Master                                   apb_masters[NB_MASTER-1:0],
    
    // CONFIGURATION PORT
    input  logic [NB_MASTER-1:0][APB_ADDR_WIDTH-1:0] start_addr_i,
    input  logic [NB_MASTER-1:0][APB_ADDR_WIDTH-1:0] end_addr_i
    );
   
   genvar 			       i;
   
   logic [NB_MASTER-1:0] 	       PENABLE;
   logic [NB_MASTER-1:0] 	       PWRITE;
   logic [NB_MASTER-1:0][31:0] 	       PADDR;
   logic [NB_MASTER-1:0] 	       PSEL;
   logic [NB_MASTER-1:0][31:0] 	       PWDATA;
   logic [NB_MASTER-1:0][31:0] 	       PRDATA;
   logic [NB_MASTER-1:0] 	       PREADY;
   logic [NB_MASTER-1:0] 	       PSLVERR;
   
   // GENERATE SEL SIGNAL FOR MASTER MATCHING THE ADDRESS
   generate
      for(i=0;i<NB_MASTER;i++)
	begin
	   assign apb_masters[i].PENABLE = PENABLE[i];
           assign apb_masters[i].PWRITE  = PWRITE[i];
           assign apb_masters[i].PADDR   = PADDR[i];
           assign apb_masters[i].PSEL    = PSEL[i];
           assign apb_masters[i].PWDATA  = PWDATA[i];
	   assign PRDATA[i]              = apb_masters[i].PRDATA;
	   assign PREADY[i]              = apb_masters[i].PREADY;
	   assign PSLVERR[i]             = apb_masters[i].PSLVERR;
	end
   endgenerate
   
   apb_node
     #(
       .NB_MASTER(NB_MASTER),
       .APB_DATA_WIDTH(APB_DATA_WIDTH),
       .APB_ADDR_WIDTH(APB_ADDR_WIDTH)
       )
   apb_node_i
     (
      .ACLK_i(clk_i),
      .ARESETn_i(rst_ni),
      
      .PENABLE_i(apb_slave.PENABLE),
      .PWRITE_i(apb_slave.PWRITE),
      .PADDR_i(apb_slave.PADDR),
      .PWDATA_i(apb_slave.PWDATA),
      .PRDATA_o(apb_slave.PRDATA),
      .PREADY_o(apb_slave.PREADY),
      .PSLVERR_o(apb_slave.PSLVERR),
      
      .PENABLE_o(PENABLE),
      .PWRITE_o(PWRITE),
      .PADDR_o(PADDR),
      .PSEL_o(PSEL),
      .PWDATA_o(PWDATA),
      .PRDATA_i(PRDATA),
      .PREADY_i(PREADY),
      .PSLVERR_i(PSLVERR),
      
      .START_ADDR_i(start_addr_i),
      .END_ADDR_i(end_addr_i)
      );
   
endmodule
