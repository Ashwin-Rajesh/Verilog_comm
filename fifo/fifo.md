# FIFO

- A synchronous FIFO
- Parameters
  - ```p_WORD_LEN```
    - Size of each entry
    - Default = 8
  - ```p_FIFO_SIZE``` 
    - Size of FIFO memory
    - Default= 8
- Ports
    Control, status
    - ```input i_clk```
    - ```output o_full``` 
    - ```output o_empty```

    Enqueue
    - ```input [p_WORD_LEN-1:0] enq_data```
    - ```input enq_en```    : Push to FIFO
    - ```output enq_rdy```  : Can i push to FIFO? (same as !o_full)

    Dequeue
    - ```output reg [p_WORD_LEN-1:0] deq_data```
    - ```input deq_en```    : Pop from FIFO
    - ```output deq_rdy```  : Can i pop from FIFO? (same as !o_empty)
