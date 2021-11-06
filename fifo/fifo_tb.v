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

module fifo_tb;

    reg data_in = 1'b0;
    reg clk_in  = 1'b0;
    reg reset   = 1'b0;
    reg enable  = 1'b0;

    wire w_full;
    wire w_empty;

    reg[7:0] r_data_in    = 8'b0;
    reg r_enq_en        = 1'b0;
    reg r_deq_en        = 1'b0;

    wire[7:0] w_data_out;
    wire w_enq_rdy;
    wire w_deq_rdy;

    fifo #(.p_WORD_LEN(8), .p_FIFO_SIZE(8)) DUT (
        .i_clk(clk_in),
        .i_reset(reset),

        .o_full(w_full),
        .o_empty(w_empty),

        .i_enq_data(r_data_in),
        .i_enq_en(r_enq_en),
        .o_enq_rdy(w_enq_rdy),

        .o_out_data(w_data_out),
        .i_deq_en(r_deq_en),
        .o_deq_rdy(w_deq_rdy)
    );
    
    localparam  DATA_LEN = 90;
    
    reg[DATA_LEN-1:0] data = "ABCFA";

    integer i;

    initial begin
        $dumpfile("fifo.vcd");
        $dumpvars(0, DUT);

        reset   <= 1'b1;
        #1;
        reset   <= 1'b0;

        // Send data
        while(w_enq_rdy) @(negedge clk_in) begin
            r_data_in         <= $random;
            r_enq_en          <= 1'b1;
        end
        r_enq_en <= 1'b0;

        // Get the data back
        while(w_deq_rdy) @(negedge clk_in) begin
            r_deq_en         <= 1'b1;
        end 
        r_deq_en <= 1'b0;

        // Send more data
        while(w_enq_rdy) @(negedge clk_in) begin
            r_data_in         <= $random;
            r_enq_en          <= 1'b1;
        end
        r_enq_en <= 1'b0;

        // Get some of the data back
        for(i = 0; i < 3; i = i + 1) @(negedge clk_in) begin
            r_deq_en         <= 1'b1;
        end 
        r_deq_en <= 1'b0;

        // Send more data
        while(w_enq_rdy) @(negedge clk_in) begin
            r_data_in         <= $random;
            r_enq_en          <= 1'b1;
        end
        r_enq_en <= 1'b0;

        // Get the data back
        while(w_deq_rdy) @(negedge clk_in) begin
            r_deq_en         <= 1'b1;
        end 
        r_deq_en <= 1'b0;

        // Reset
        @(negedge clk_in);
        reset   <= 1'b1;
        @(negedge clk_in);
        reset   <= 1'b0;

        // Send data
        while(w_enq_rdy) @(negedge clk_in) begin
            r_data_in         <= $random;
            r_enq_en          <= 1'b1;
        end
        r_enq_en <= 1'b0;

        // Get the data back
        while(w_deq_rdy) @(negedge clk_in) begin
            r_deq_en         <= 1'b1;
        end 
        r_deq_en <= 1'b0;

        @(negedge clk_in)
        enable  <= 1'b0;

        #10 
        $finish;
    end

    always #1 clk_in  <= ~clk_in;

endmodule
