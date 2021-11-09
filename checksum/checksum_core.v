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

module checksum_core #(
    parameter p_WORD_LEN    = 8,
    parameter p_TWOS_COMPL  = 0      // 1 for two's complement, 0 for one's complement
) (
    input   i_clk,
    input   i_reset,

    input[p_WORD_LEN-1:0] 
            i_data,
    input   i_en,

    input   i_calc,

    output reg [p_WORD_LEN-1:0]
            o_checksum,
    output  o_rdy
);

    // States : 0 - Getting input, 1 - Calculating and generating output
    reg     r_state     = 0;

    // Is output ready?
    assign o_rdy = (r_state == 0);

    // Result of addition
    wire    w_c;
    wire[p_WORD_LEN-1:0]    
            w_add_result;
    assign {w_c, w_add_result} = i_data + o_checksum;

    // Asnchronous reset
    always @(i_reset)
        if(i_reset) begin
            r_state     <= 0;
            o_checksum  <= 0;
        end

    // Generate seprate logic based on p_TWOS_COMPL
    generate
    if(p_TWOS_COMPL) begin
        always @(posedge i_clk) begin
            if(!r_state) begin
                if(i_en) begin
                    // Two's complement addition
                    o_checksum  <= w_add_result;
                end
                else if(i_calc) begin
                    // Output two's complement of result
                    o_checksum  <= (~o_checksum) + 1;

                    r_state     <= 1;
                end
            end    
        end
    end else begin
        always @(posedge i_clk) begin
            if(!r_state) begin
                if(i_en) begin
                    // One's complement addition
                    o_checksum  <= w_add_result + w_c;
                end
                else if(i_calc) begin
                    // Output one's complement of result
                    o_checksum  <= ~o_checksum;

                    r_state     <= 1;
                end
            end    
        end
    end
    endgenerate

endmodule
