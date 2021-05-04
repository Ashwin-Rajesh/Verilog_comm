
---

# UART Protocol

# Features
- Serial
- Full duplex
- Asynchronous

# Popular uses
- For communication between microcontrollers
- For communication between microcontrollers and a computer (for debugging or sending commands)

# Interface
 ![](./docs/uart_interface.svg)
Source : Analog Devices [1]

- 2 pins, Rx and Tx are used.
  - Rx : Read
  - Tx : Transmit
- A baud rate has to be set before-hand in both devices, because there is no clock signal.
- Standard baud rates are :
  - 9600, 19200, 38400, 57600, 115200, 230400, 460800, 921600, 1000000, 1500000
- Default voltage level is HIGH

# Protocol

- The UART packet looks like:
![](./docs/uart_packet.svg)
Source : Analog Devices [1] 

- A ```start bit``` indicates start of packet
  - The default ```HIGH``` level is pulled down to ```LOW``` for one clock cycle
  - The receiving UART detects the transition and prepares to read the subsequent bits

- The ```data frame``` holds the actual data. It can be 5 to 8 bits long if the parity bit is used, or 9 bits long if parity is not used.
  - LSB first

- ```Parity bit``` is used to check for errors. It can follow odd or even parity.

- ```Stop bit``` indicates end of packet
  - The signal is pulled ```HIGH``` for 1 to 2 cycles.

---

# Implementation

![Transmit State machine](docs/uart_tx_sm.svg)

---

# Result

![UART waveform](docs/uart_waveform.png)

Signal values :
- ```000``` : Idle
- ```001``` : Start bit
- ```010``` : Data bit
- ```011``` : Stop bit
- ```100``` : Restart stage

---

# References

1) [Analog Devices](https://www.analog.com/en/analog-dialogue/articles/uart-a-hardware-communication-protocol.html#:~:text=By%20definition%2C%20UART%20is%20a,going%20to%20the%20receiving%20end.)
2) [NandLand implementation](https://www.nandland.com/vhdl/modules/module-uart-serial-port-rs232.html)