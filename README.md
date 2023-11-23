# PS/2 Mouse Interface
This VHDL source code implements a PS/2 mouse interface, operating at a clock frequency of 12 kHz. 
The design comprises three main components, consolidated in a primary file, and is accompanied by a test bench for verification.

# Components
## 1. Initialization Component (init)
The init component initializes the mouse, injecting F6 into the mouse, and synchronizes the clock. 
This phase sets the foundation for proper communication between the mouse and the controller.

## 2. Synchronization Component (sync)
The sync component employs a D Flip-Flop (DFF) to synchronize both the clock and data signals. 
Ensuring synchronization is crucial for accurate communication between the mouse and the controller, addressing potential timing issues.

## 3. Reception Component (RX)
The RX component manages the reception of data from the mouse to the controller.
It performs an integrity check on the incoming serial data, producing a validated output.
Additionally, it incorporates a Watchdog Timer (WDT) to audit the system at defined intervals, preventing potential issues and system overflows.

## Mouse Control
The primary component orchestrating the entire system is the Mouse Control component.
It incorporates the init, sync, and RX components and operates through a well-defined state machine.
This state machine ensures effective control and monitors the integrity of transmitted information.

# Conclusion
In summary, this VHDL implementation of a PS/2 mouse interface offers a robust and well-organized solution. 
The integration of initialization, synchronization, and reception components, controlled by a state machine, ensures reliable communication between the mouse and the controller. 
