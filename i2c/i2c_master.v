/*
MIT License

Copyright (c) 2021 Ashwin-Rajesh

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

`include "tristate_port.v"

module i2c_master #(
    parameter p_CLK_DIV = 10
) (
    // General signals
    input i_clk,
    inout io_sda,
    inout io_scl,
    
    // Input method
    input[7:0] inp_data,
    input[7:0] inp_addr,
    input inp_en,
    output inp_rdy,

    // Output method
    output reg [p_WORD_LEN-1:0] out_data    = 0,
    output out_rdy
);

    reg     r_sda_write = 1'b1;
    wire    w_sda_read;
    
    reg     r_scl_write = 1'b1;
    wire    w_scl_read;
    
    tristate_port sda_port(
        .io_pin(io_sda), 
        .o_read(w_sda_read), 
        .i_write(r_sda_write)
    );
    
    tristate_port scl_port(
        .io_pin(io_scl),
        .o_read(w_scl_read),
        .i_write(r_scl_write)
    );

    // State machine states
    localparam s_IDLE       = 0;
    localparam s_START      = 1;
    localparam s_ADDR       = 2;
    localparam s_READWRITE  = 3;
    localparam s_ACK        = 4;
    
    reg r_state = s_IDLE;
    reg r_clk_count = 0;

    reg r_addr = 0;
    reg r_data = 0;

    always @(posedge clk) begin
        r_clk_count <= (r_state != s_IDLE) ? r_clk_count + 1 : 0;
        case (r_state)
            s_IDLE : begin
                if(inp_en) begin
                    r_addr  <= inp_addr;
                    r_data  <= inp_data;
                    r_state <= s_ADDR;
                    r_sda_write <= 1'b0;
                end
            end
            s_ADDR : begin
                
            end
            default: begin
                r_state <= s_IDLE;
            end 
        endcase
    end

endmodule;
