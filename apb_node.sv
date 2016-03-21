// Copyright 2016 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the “License”); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// ============================================================================= //
// Engineer:       Davide Rossi - davide.rossi@unibo.it                          //
//                                                                               //
// Design Name:    APB BUS                                                       //
// Module Name:    APB_BUS                                                       //
// Project Name:   PULP                                                          //
// Language:       SystemVerilog                                                 //
//                                                                               //
// Description:    This component implements a configurable APB node             //
//                                                                               //
// ============================================================================= //

module apb_node
  #(
    parameter NB_MASTER = `NB_MASTER,
    parameter APB_DATA_WIDTH = 32,
    parameter APB_ADDR_WIDTH = 32
    )
   (
    input logic                        ACLK_i,
    input logic                        ARESETn_i,
    
    // SLAVE PORT
    input  logic                       PENABLE_i,
    input  logic                       PWRITE_i,
    input  logic [31:0]                PADDR_i,
    input  logic [31:0]                PWDATA_i,
    output logic [31:0]                PRDATA_o,
    output logic                       PREADY_o,
    output logic                       PSLVERR_o,
    
    // MASTER PORTS
    output logic [NB_MASTER-1:0]       PENABLE_o,
    output logic [NB_MASTER-1:0]       PWRITE_o,
    output logic [NB_MASTER-1:0][31:0] PADDR_o,
    output logic [NB_MASTER-1:0]       PSEL_o,
    output logic [NB_MASTER-1:0][31:0] PWDATA_o,
    input  logic [NB_MASTER-1:0][31:0] PRDATA_i,
    input  logic [NB_MASTER-1:0]       PREADY_i,
    input  logic [NB_MASTER-1:0]       PSLVERR_i,
    
    // CONFIGURATION PORT
    input  logic [NB_MASTER-1:0]       START_ADDR_i,
    input  logic [NB_MASTER-1:0]       END_ADDR_i,
    
    );
   
   genvar 			       i;
   integer 			       s_loop1,s_loop2,s_loop3,s_loop4,s_loop5,s_loop6,s_loop7;
   
   // GENERATE SEL SIGNAL FOR MASTER MATCHING THE ADDRESS
   generate
      for(i=0;i<NB_MASTER;i++)
	begin
	   assign PSEL_o[i]  =  (PADDR_i >= START_ADDR_i[i]) && (PADDR_i <= END_ADDR_i[i]);
	end
   endgenerate
   
   always_comb
     begin
	// PENABLE GENERATION
	for ( s_loop1 = 0; s_loop1 < NB_MASTER; s_loop1++ )
	  begin
	     if( PSEL_o[i] == 1'b1 )
	       begin
		  PENABLE_o[i] = PENABLE_i;
	       end
	     else
	       begin
		  PENABLE_o[i] = '0;
	       end
	  end
     end
   
   // PWRITE GENERATION
   always_comb
     begin
	for ( s_loop2 = 0; s_loop2 < NB_MASTER; s_loop2++ )
	  begin
	     if( PSEL_o[i] == 1'b1 )
	       begin
		  PWRITE_o[i] = PWRITE_i;
	       end
	     else
	       begin
		  PWRITE_o[i] = '0;
	       end
	  end
     end
   
   // PADDR GENERATION
   always_comb
     begin
	for ( s_loop3 = 0; s_loop3 < NB_MASTER; s_loop3++ )
	  begin
	     if( PSEL_o[i] == 1'b1 )
	       begin
		  PADDR_o[i] = PADDR_i;
	       end
	     else
	       begin
		  PADDR_o[i] = '0;
	       end
	  end
     end
   
   // PWDATA GENERATION
   always_comb
     begin
	for ( s_loop4 = 0; s_loop4 < NB_MASTER; s_loop4++ )
	  begin
	     if(PSEL_o[i] == 1'b1)
	       begin
		  PWDATA_o[i] = PWDATA_i;
	       end
	     else
	       begin
		  PWDATA_o[i] = '0;
	       end
	  end
     end
   
   // PRDATA MUXING
   always_comb
     begin
	PRDATA_o = '0;
	for ( s_loop5 = 0; s_loop5 < NB_MASTER; s_loop5++ )
	  begin
	     if(PSEL_o[i] == 1'b1)
	       begin
		  PRDATA_o = PRDATA_i[i];
	       end
	  end
     end
   
   // PRREADY MUXING
   always_comb
     begin
	PREADY_o = '0;
	for ( s_loop6 = 0; s_loop6 < NB_MASTER; s_loop6++ )
	  begin
	     if(PSEL_o[i] == 1'b1)
	       begin
		  PRREADY_o = PRREADY_i[i];
	       end
	  end
     end
   
   // PSLVERR MUXING
   always_comb
     begin
	PSLVERR_o = '0;
	for ( s_loop7 = 0; s_loop7 < NB_MASTER; s_loop7++ )
	  begin
	     if(PSEL_o[i] == 1'b1)
	       begin
		  PSLVERR_o = PSLVERR_i[i];
	       end
	  end
     end
   
endmodule
