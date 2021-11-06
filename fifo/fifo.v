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
    
    output  o_full,
    output  o_empty,
    output [p_FIFO_ADDR_LEN:0]
            o_len,

    // Enqueue method
    input [p_WORD_LEN-1:0] 
            i_enq_data,
    input   i_enq_en,
    output  o_enq_rdy,

    // Dequeue method
    output [p_WORD_LEN-1:0] 
            o_out_data,
    input   i_deq_en,
    output  o_deq_rdy
);

    localparam 
        p_FIFO_ADDR_LEN = $clog2(p_FIFO_SIZE);

    // FIFO memory
    reg [p_WORD_LEN-1:0]        r_mem [p_FIFO_SIZE-1:0];

    // Pointer
    reg [p_FIFO_ADDR_LEN:0]     r_tail                      = 0;    // The value to output        (read then increment)
    reg [p_FIFO_ADDR_LEN:0]     r_head                      = 0;    // The next value to write to (write then increment)

    wire r_head_flag = r_head[p_FIFO_ADDR_LEN];
    wire r_tail_flag = r_tail[p_FIFO_ADDR_LEN];

    reg o_len;

    // For o_len, only issue is when head has wrapped around and becomes < tail.
    // In that case, pretend top bit oh head is 1 and bottom bit of tail is 0
    always @(*) begin
        case({r_head_flag, r_tail_flag})
            2'b00   : o_len <= r_head - r_tail;
            2'b01   : o_len <= {1'b1, r_head[p_FIFO_ADDR_LEN-1:0]}
                              - {1'b0, r_tail[p_FIFO_ADDR_LEN-1:0]};
            2'b10   : o_len <= r_head - r_tail;
            2'b11   : o_len <= r_head - r_tail;
        endcase
    end

    // Empty and full signals
    assign o_full   = (r_head[p_FIFO_ADDR_LEN-1:0] == r_tail[p_FIFO_ADDR_LEN-1:0]) && !(r_head[p_FIFO_ADDR_LEN] == r_tail[p_FIFO_ADDR_LEN]);
    assign o_empty  = (r_head[p_FIFO_ADDR_LEN-1:0] == r_tail[p_FIFO_ADDR_LEN-1:0]) && (r_head[p_FIFO_ADDR_LEN] == r_tail[p_FIFO_ADDR_LEN]);

    // Enqueue and dequeue ready signals
    assign o_enq_rdy  = !o_full;
    assign o_deq_rdy  = !o_empty;

    // o_out_data is asynchronous. Only tail increment is syncronous
assign o_out_data = o_empty ? {p_WORD_LEN{1'b1}} : (r_mem[r_tail[p_FIFO_ADDR_LEN-1:0]]);

    always @(posedge i_clk) begin
        // Syncrhonous reset
        if(i_reset) begin
            r_tail  <= 0;
            r_head  <= 0;
        end
        else begin
            // Enqueue : write, then increment head
            if (o_enq_rdy && i_enq_en) begin
                r_mem[r_head]   <= i_enq_data;
                r_head          <= r_head + 1;
            end
            // Dequeue : increment tail (read is asnyc)
            if (o_deq_rdy && i_deq_en) begin
                r_tail          <= r_tail + 1;
            end
        end
    end
endmodule
