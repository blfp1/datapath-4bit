![Verilog](https://img.shields.io/badge/Language-Verilog-blue?logo=verilog)
![FPGA](https://img.shields.io/badge/Hardware-DE10--Lite-red?logo=intel)
![Architecture](https://img.shields.io/badge/Architecture-Multi--Cycle-orange)
![Status](https://img.shields.io/badge/Status-Verified-success)

# MicroCore: Educational 4-Bit Microarchitecture

## Project Overview
This repository contains the RTL implementation of **MicroCore**, an educational 4-bit multi-cycle microarchitecture. The project was developed as part of the Electronic Engineering curriculum at **UNIFEI** (Federal University of Itajubá).

Unlike single-cycle processors, MicroCore utilizes a **Finite State Machine (FSM)** to orchestrate the datapath control signals across multiple clock cycles, executing instructions in stages (Fetch, Decode, Execute, Write-Back).

## Architecture Specifications
The system is built upon a modular design with the following characteristics:

- **Datapath Width:** 4-bit data bus.
- **Program Counter (PC):** 8-bit counter addressing a 256-byte instruction memory.
- **Memory (ROM):** 256x8-bit Read-Only Memory for program storage.
- **Register File:** Bank of 4 general-purpose registers (4-bit width) with dual read ports and single write port.
- **ALU (ULA):** Synchronous Arithmetic Logic Unit supporting arithmetic and bitwise operations.
- **Control Unit:** Moore FSM handling instruction cycles and handshaking signals (`ack`).

## ⚙️ Instruction Set Architecture (ISA)
The processor supports a custom set of 8-bit instructions:

| Mnemonic | Function | Description |
|:---:|:---:|:---|
| **LDR** | Load | Loads a 4-bit immediate value into a register (`Rx = Imm4`). |
| **ADD** | Arithmetic | Adds two registers (`Rd = Ra + Rb`). |
| **SUB** | Arithmetic | Subtracts two registers (`Rd = Ra - Rb`). |
| **AND** | Logic | Bitwise AND (`R0 = Ra & Rb`). |
| **OR** | Logic | Bitwise OR (`R0 = Ra | Rb`). |
| **XOR** | Logic | Bitwise XOR (`R0 = Ra ^ Rb`). |
| **NAND** | Logic | Bitwise NAND (`R0 = ~(Ra & Rb)`). |

*Note: Logic operations always store the result in Register R0.*

## Finite State Machine (Control)
The control unit implements a Moore Machine with the following states:
1.  **PC:** Updates the Program Counter.
2.  **Fetch:** Retrieves the instruction from ROM.
3.  **Decode/Ex:** Branches to specific execution states (LDR, Arithmetic, or Logic).
4.  **Write-Back:** Writes the result back to the Register File.

## 🛠 Hardware Implementation (DE10-Lite)
The project is synthesized for the **Terasic DE10-Lite** board (Intel MAX 10 FPGA).

| Component | DE10-Lite Pin | Function |
|-----------|---------------|----------|
| **Clock** | KEY[0] | Manual Clock Pulse (Step-by-step execution) |
| **Reset** | KEY[1] | Global System Reset |
| **HEX0** | Display 0 | Result / ALU Output |
| **HEX1** | Display 1 | Operand B |
| **HEX2** | Display 2 | Operand A |
| **HEX4** | Display 4 | Current FSM State |
| **HEX5** | Display 5 | Data Bus Content |

## Simulation & Testing
To run the simulation:
1. Open the project in **Intel Quartus Prime**.
2. Compile the `topmodule.v`.
3. Load the `rom.txt` file with the hexadecimal opcodes.
4. Use ModelSim or the Board for verification.

---
*Developed by [Bernardo](https://github.com/blfp1).*
