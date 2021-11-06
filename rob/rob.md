# ROB (Re-order buffer)

- A re-order buffer is used to re-order packets that arrive out-of-order in digital systems. (mostly in on-chip or off-chip networks)
- Packets have a packet number and data. We feed and retrieve them separately from the ROB.
- We can reset the buffer and set a starting packet ID (unfortunately, cannot set the minumum packet ID without a reset)
- Once we reset, we can only add and remove packets to the ROB
- Reading of data can only be done in the packet ID order. 
  - We cannot peek inside the ROB. 
  - This implementation is meant only as a way to re-order out of order packets and not for applications like re-ordering instructions in processors, where peeking might be needed.
  - However, it could be done with some rather small modifications while still using a 2-port RAM

### Parameters
- ```p_WORD_LEN```
  - Length of data in the ROB    
- ```p_PID_LEN```    
  - Length of packet IDs
- ```p_ROB_SIZE```     
  - Number of elements in the ROB
  - Keep this as the expected max difference between packet IDs
  - If the variance is too much, use a FIFO to store extra packets that are rejected and try to send them again
  - ROB has more 

### Ports

| Port name         | Description | Type |
|---                | --- | --- |
| ```i_clk```       | Clock signal | wire 
| ```i_reset```     | Synchronous reset | wire
| ```i_reset_pid``` | Minimum packet ID to accept after reset | packet id 
| ```o_min_pid```   | Minimum packet ID in the ROB  | packet id
| ```o_max_pid```   | Maximum packet ID in the ROB  | packet id
| ```i_inp_pid```   | Packet ID of input packet     | packet id
| ```i_inp_data```  | Data of input packet          | data
| ```i_inp_en```    | Add the packet to ROB         | wire
| ```o_inp_ack```   | Packet was added successfully | wire
| ```o_inp_valid``` | Asyncrhonous output : is ```i_inp_pid``` entry in ROB valid? | wire (aync)
| ```o_out_data```  | Data of packet with minimum ID (```0xFF``` for invalid entry) | data
| ```i_out_en```    | Remove minimum packet ID | wire
| ```o_out_valid``` | Is the minimum packet entry valid? | wire

#### Notes

- ```o_inp_valid``` is asynchonously driven and depends on ```i_inp_data```. This can be used to check if a value already exists in the ROB before overwriting it (use it to gate ```i_inp_en```). It can also be used as an acknowledge signal indicating successfull write.

- Internally, a 2-port ```p_WORD_LEN x p_ROB_SIZE``` RAM is used for storing data and a ```1 x p_ROB_SIZE``` vector is used for storing the valid signals
- The rest is handled using ```head``` and ```tail``` like a FIFO. We only store the packet id of ```tail``` and the rest is calculated on-the-fly
