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

module fifo #(
    parameter p_WORD_LEN = 8,
    parameter p_FIFO_SIZE = 8
) (
    // General signals
    input i_clk,
    input i_reset,
    
    output o_full,
    output o_empty,

    // Enqueue method
    input [p_WORD_LEN-1:0] enq_data,
    input enq_en,
    output enq_rdy,

    // Dequeue method
    output reg [p_WORD_LEN-1:0] deq_data    = 0,
    input deq_en,
    output deq_rdy
);

    localparam 
        p_FIFO_ADDR_LEN = $clog2(p_FIFO_SIZE);

    // FIFO memory
    reg [p_WORD_LEN-1:0]        r_mem [p_FIFO_SIZE-1:0];

    // Pointer
    reg [p_FIFO_ADDR_LEN:0]     r_tail                      = 0;
    reg [p_FIFO_ADDR_LEN:0]     r_head                      = 0;

    // Empty and full signals
    assign o_full   = (r_head[p_FIFO_ADDR_LEN-1:0] == r_tail[p_FIFO_ADDR_LEN-1:0]) && !(r_head[p_FIFO_ADDR_LEN] == r_tail[p_FIFO_ADDR_LEN]);
    assign o_empty  = (r_head[p_FIFO_ADDR_LEN-1:0] == r_tail[p_FIFO_ADDR_LEN-1:0]) && (r_head[p_FIFO_ADDR_LEN] == r_tail[p_FIFO_ADDR_LEN]);

    // Enqueue and dequeue ready signals
    assign enq_rdy  = !o_full;
    assign deq_rdy  = !o_empty;

    genvar i;

    always @(posedge i_clk) begin
        if(i_reset) begin
            r_tail  <= 0;
            r_head  <= 0;
            generate
                for (i = 0; i < p_FIFO_SIZE; i = i + 1) begin
                    r_mem[i] = 0;
                end
            endgenerate 
        end
        else begin
            if (enq_rdy && enq_en) begin
                r_mem[r_head]   <= enq_data;
                r_head          <= r_head + 1;
            end
            if (deq_rdy && deq_en) begin
                deq_data        <= r_mem[r_tail];
                r_tail          <= r_tail + 1;
            end
        end
    end
endmodule;
