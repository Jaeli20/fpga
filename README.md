# FPGA-Based Sign Language Glove Translator

This repository contains the VHDL source code, testbench, and LaTeX report for the FPGA-based sign language translator developed at Universidad Don Bosco.

## 📁 Repository Structure

- `quantizer.vhd` — Three-state analog-to-digital quantizer
- `states_packer.vhd` — Packs five fingers into a 10-bit code
- `classifier_lut.vhd` — Static letter lookup table (ASCII)
- `segment_fsm.vhd` — Commitment FSM after stable detection
- `motion_fsm.vhd` — Detects dynamic gestures (“J” and “Z”)
- `stable_detector.vhd` — Debouncing/stability detector
- `word_buffer.vhd` — Concatenates committed letters into words
- `tb_top.vhd` — Complete testbench for simulation
- (Optional) Add screenshots and LaTeX report in README or separate folders

##  How to Simulate

1. Clone the repository:  
   `git clone https://github.com/Jaeli20/fpga.git`
2. Open Vivado and create a VHDL simulation project.
3. Add all `.vhd` files to the project.
4. Set `tb_top` as the simulation top.
5. Run behavioral simulation for ~5 ms.
6. Observe waveform and Simulation Console for commit events and final word output.

##  Citation
Please cite this project as:
J. Gutierrez, F. Bustamante, M. E. Flores, "Sign Language Translator on FPGA (Basic Static Alphabet Version)," Universidad Don Bosco, 2025.
