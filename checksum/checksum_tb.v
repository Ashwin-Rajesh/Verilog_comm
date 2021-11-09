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

module checksum_tb;

    localparam p_BLOCK_LEN  = 8;
    localparam p_TWOS_COMPL = 0;

    reg r_clk   = 0;
    reg r_rst   = 0;
    reg[p_BLOCK_LEN-1:0]
        r_data  = 0;
    reg r_en    = 0;
    reg r_calc  = 0;

    wire[p_BLOCK_LEN-1:0]
        w_out;
    wire w_rdy;

    checksum_core #(
        .p_WORD_LEN(p_BLOCK_LEN),
        .p_TWOS_COMPL(p_TWOS_COMPL)
    ) DUT (
        .i_clk(r_clk),
        .i_reset(r_rst),
        
        .i_data(r_data),
        .i_en(r_en),

        .i_calc(r_calc),
        .o_checksum(w_out),
        
        .o_rdy(w_rdy)
    );

    integer i;
    
    initial begin
        $dumpfile("checksum.vcd");
        $dumpvars(0, checksum_tb);

        r_rst   <= 1'b1;
        #1;
        r_rst   <= 1'b0;

        for(i = 0; i < 100; i = i + 1) @(negedge r_clk) begin
            r_en        <= 1'b1;
            r_data      <= $random;
            $strobe("%h", r_data);
        end

        @(negedge r_clk)
        r_en            <= 1'b1;

        if(p_TWOS_COMPL)
            r_data          <= ~(w_out) + 1;
        else
            r_data          <= ~w_out;
        
        @(negedge r_clk)
        r_en            <= 1'b0;
        r_calc          <= 1'b1;

        @(negedge r_clk)
        r_calc          <= 1'b0;

        #10 
        $finish;
    end

    always #1 r_clk  <= ~r_clk;

endmodule
