`include "i2c_master_fsm.v"
`include "tristate_port.v"

module master_fsm_tb;

    reg r_clk   = 0;
    reg r_ns    = 0;
    reg r_start = 0;
    reg r_stop  = 0;
    reg r_rw    = 0;

    reg r_clk2  = 0;
    reg r_clk2_en = 0;
    wire w_clk2 = r_clk2 && r_clk2_en;
    
    reg[7:0] r_rd_data = 0;
    wire[7:0] w_wr_data;

    wire w_read;
    wire w_ackerror;
    wire w_clkstretched;
    wire w_start_rdy;
    
    wire w_scl,
        w_scl_i,
        w_scl_o;

    wire w_sda,
        w_sda_i,
        w_sda_o;

    wire w_active,
        w_next;

    wire[3:0] w_state;

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

    reg r_sda_ext = 1;

    tristate_port sda_driver(
         .io_pin(w_sda),
         .i_write(r_sda_ext)
     );

    reg r_scl_ext = 1;

     tristate_port scl_driver(
         .io_pin(w_scl),
         .i_write(r_scl_ext)
     );

    i2c_master_fsm master_1(
        .i_clk(r_clk),
        .i_next(w_clk2),     
        .i_start(r_start),          
        .i_stop(r_stop),           
        .i_rw(r_rw),

        .i_input(r_rd_data),   
        .o_output(w_wr_data),  
        
        .o_active(w_active),
        .o_nextbyte_rdy(w_next),
        .o_ackerror(w_ackerror),
        .o_clkstretched(w_clkstretched),
        .o_start_rdy(w_start_rdy),

        .o_state(w_state),

        .i_scl(w_scl_o),
        .o_scl(w_scl_i),
        .i_sda(w_sda_o),
        .o_sda(w_sda_i)
    );

    wire w_scl_i2;
    wire w_scl_o2;

    wire w_sda_i2;
    wire w_sda_o2;

    tristate_port scl_port2(
        .io_pin(w_scl), 
        .i_write(w_scl_i2),

        .o_read(w_scl_o2)
    );    

    tristate_port sda_port2(
        .io_pin(w_sda), 
        .i_write(w_sda_i2),

        .o_read(w_sda_o2)
    );

    reg r_start2    = 0;
    reg r_stop2     = 0;
    reg r_rw2       = 0;

    reg[7:0] r_in2      = 0;
    wire[7:0] w_out2;

    wire w_active2;
    wire w_next2;
    wire w_ackerror2;
    wire w_clkstretched2;
    wire w_start_rdy2;

    wire[3:0] w_state2;

    i2c_master_fsm master_2(
        .i_clk(r_clk),
        .i_next(w_clk2),     
        .i_start(r_start2),        
        .i_stop(r_stop2),  
        .i_rw(r_rw2),

        .i_input(r_in2),
        .o_output(w_out2),
        
        .o_active(w_active2),
        .o_nextbyte_rdy(w_next2),
        .o_ackerror(w_ackerror2),
        .o_clkstretched(w_clkstretched2),
        .o_start_rdy(w_start_rdy2),

        .o_state(w_state2),

        .i_scl(w_scl_o2),
        .o_scl(w_scl_i2),
        .i_sda(w_sda_o2),
        .o_sda(w_sda_i2)
    );

    pullup pu_scl(w_scl);
    pullup pu_sda(w_sda);

    always #1 r_clk = !r_clk;
    
    always begin 
        #10 r_clk2 = 0;
        
        @(negedge r_clk)
            r_clk2 = 1;
        @(negedge r_clk)
            r_clk2 = 0;
    end

    // always begin
    //     r_scl_ext = 1;
    //     #10;
    //     while(w_scl == 1) #1;
    //     r_scl_ext = 0;
    //     #($urandom_range(15, 50));
    // end

    initial #10000 $finish;

    integer i;

    initial begin
        $dumpfile("i2c_master_fsm_arb.vcd");
        $dumpvars(0, master_fsm_tb);

        r_clk2_en = 1;

        r_rd_data = 8'hFF;
        r_start <= 1;

        @(negedge r_clk);
        r_start <= 0;

        // Send address
        while (!w_next) begin
            @(w_scl);
            if(w_state == 4 || w_state == 5)
                r_sda_ext = 0;
            else
                r_sda_ext = 1;
        end

        // Load data
        r_rd_data = 8'hAA;
        // De-assert the acknowledge
        @(negedge w_scl)    r_sda_ext = 1;
        
        // Send data
        while (!w_next) begin
            @(w_scl);
            if(w_state == 4 || w_state == 5)
                r_sda_ext = 0;
            else
                r_sda_ext = 1;
        end

        // Load data
        r_rd_data = 8'h54;
        // De-assert the acknowledge
        @(negedge w_scl)    r_sda_ext = 1;

        // Send data
        while (!w_next) begin
            @(w_scl);
            if(w_state == 4 || w_state == 5)
                r_sda_ext = 0;
            else
                r_sda_ext = 1;
        end

        @(negedge w_scl)    r_sda_ext = 1;
        
        // Send stop
        r_ns = 0;
        r_stop = 1;

        #100;

        r_stop <= 0;
        r_in2 = 8'h02;
        r_start2 <= 1;
        r_start <= 1;

        @(negedge r_clk);
        @(negedge r_clk);
        r_start  <= 0;
        r_start2 <= 0;

        // Send address
        while (!w_next2) begin
            @(w_scl);
            if(w_state2 == 4 || w_state2 == 5)
                r_sda_ext = 0;
            else
                r_sda_ext = 1;
        end

        // Load data
        r_in2 = 8'h25;
        // De-assert the acknowledge
        @(negedge w_scl)    r_sda_ext = 1;
        
        // Send data
        while (!w_next2) begin
            @(w_scl);
            if(w_state2 == 4 || w_state2 == 5)
                r_sda_ext = 0;
            else
                r_sda_ext = 1;
        end

        // Load data
        r_in2 = 8'hAC;
        // De-assert the acknowledge
        @(negedge w_scl)    r_sda_ext = 1;

        // Send data
        while (!w_next2) begin
            @(w_scl);
            if(w_state2 == 4 || w_state2 == 5)
                r_sda_ext = 0;
            else
                r_sda_ext = 1;
        end

        @(negedge w_scl)    r_sda_ext = 1;
        
        // Send stop
        r_ns = 0;
        r_stop2 = 1;

        #100 $finish;
    end

endmodule;
