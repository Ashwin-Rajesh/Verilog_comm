`include "i2c_master_fsm.v"
`include "tristate_port.v"

module master_fsm_tb;

    reg r_clk   = 0;
    reg r_ns    = 0;
    reg r_start = 0;
    reg r_stop  = 0;
    reg r_rw    = 0;
    
    reg[7:0] r_rd_data = 0;
    wire[7:0] w_wr_data;

    wire w_read;
    wire w_ackerror;
    wire w_generror;
    
    wire w_scl,
        w_scl_i,
        w_scl_o;

    wire w_sda,
        w_sda_i,
        w_sda_o;

    wire w_active,
        w_next;

    tristate_port scl_port(
        .io_pin(w_scl), 
        .i_write(w_scl_i),

        .o_read(w_scl_o)
    );    

    tristate_port sda_port(
        .io_pin(w_sda), 
        .i_write(w_sda_i),

        .o_read(w_sda_o)
    );    

    i2c_master_fsm DUT(
        .i_clk(r_clk),
        .i_next_state(r_ns),     
        .i_start(r_start),          
        .i_stop(r_stop),           
        .i_rw(r_rw),

        .i_input(r_rd_data),   
        .o_output(w_wr_data),  
        
        .o_active(w_active),
        .o_nextbyte(w_next),
        .o_ackerror(w_ackerror),
        .o_generror(w_generror),

        .i_scl(w_scl_o),
        .o_scl(w_scl_i),
        .i_sda(w_sda_o),
        .o_sda(w_sda_i)
    );

    pullup pu_scl(w_scl);
    pullup pu_sda(w_sda);

    always #1 r_clk = !r_clk;

    initial #1000 $finish;

    integer i;

    initial begin
        $dumpfile("fsm_tb.vcd");
        $dumpvars(0, master_fsm_tb);

        r_rd_data = 8'hFF;
        r_start <= 1;

        @(negedge r_clk);
        r_start <= 0;
        r_ns    <= 1;

        while (!w_next) begin
            for(i = 0; i < 5; i++) begin
                @(negedge r_clk);
                r_ns    = 0; 
            end

            @(negedge r_clk);        
            r_ns    = 1;
        end
        
        r_rd_data = 8'hAA;

        for(i = 0; i < 5; i++) begin
            @(negedge r_clk);
            r_ns    = 0; 
        end

        @(negedge r_clk);        
        r_ns    = 1;
        

        while (!w_next) begin        
            for(i = 0; i < 5; i++) begin
                @(negedge r_clk);
                r_ns    = 0; 
            end

            @(negedge r_clk);        
            r_ns    = 1;
        end

        r_ns = 0;
        r_stop = 1;
        
        for(i = 0; i < 5; i++) begin
            @(negedge r_clk);
            r_ns    = 0; 
        end
        
        r_ns = 1;
    end

endmodule;
