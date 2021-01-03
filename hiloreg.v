`timescale 1ns / 1ps
module hiloreg(
	input wire clk,rst,hiwe,lowe,
	input wire[31:0] hi,lo,
	output reg[31:0] hi_o,lo_o
    );
	
	always @(negedge clk) begin
		if(rst) begin
			hi_o <= 0;
			lo_o <= 0;
		end else if (hiwe & lowe) begin
			hi_o <= hi;
			lo_o <= lo;
		end else if (hiwe) begin
			hi_o <= hi;
		end else if (lowe) begin
			lo_o <= lo;
		end 
	end
endmodule