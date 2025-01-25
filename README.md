# What Is Edge Coded Signaling (ECS3) or Pulsed-Index Communication (PIC)?

ECS3 is the third member of a novel family of block-oriented signaling techniques for single-channel, 
CDR-less serial communications (see publications section below). These techniques aim to eliminate the need for a CDR. Therefore these 
are known as CDR less protocols. These are also known as Pulsed-Index Communication techniques. These 
techniques are based on the fundamental concept of encoding data bits as pulse trains whose counts is 
also transmitted and used by the receiver for decoding.

**Note:** The HDL code provided here is an example implementation. The implementation can have several variants.

# Basic Concept:

The core idea of ECS is to select the ON bits in a data word and transmit their index numbers as
pulse streams instead of transmitting the data bits themselves. An example is given in Figure 1(b)
where the bit sequence “0101” of Figure 1(a) is transformed into series of pulses in which the
count of pulses in each series is n + 1 with n being the ordinal number of the ON bit in the binary
sequence. In the example of Figure 1, there are two series of pulses. The first series has one pulse
corresponding to the leading ON bit at position 0, and the second series has three pulses
corresponding to the ON bit at position 2. One series of pulses is separated from an adjacent
one by an inter-symbol separator α. Please note that α is not a time delay but rather a spacing
or separation symbol that is measured in clock cycles with the clock cycle count given by the
local transmitter clock at transmission and local receiver clock at reception. The clocks at both
ends do not have to be synchronized. Also, note that one is always added to the pulse count
corresponding to the index number. This operation is necessary to handle the transmission of
index 0. Otherwise, no pulse will be transferred if the bit at index 0 is ON. For each input pulse
series, the ECS receiver counts the number of the incoming rising edges, subtracts one to retrieve
the index number (i.e., n = PulseCount − 1), and sets a data-bit at the index number. This is shown
in Figure 1(c). The apparent drawback is that more work is seemingly needed to transmit such
pulse series than the raw bits themselves. However, this is not the case as it is conceivable to
achieve high data rates, using an encoding process that makes the index numbers as small as
possible. This is accomplished by breaking the bit stream into smaller segments, reducing the
number of ON bits as much as possible in each segment, and relocating these ON bits to the
lowest index positions. The encoding information and the number of ON bits in the encoded
data are sent as a packet header along with the index numbers. All the information in the packet
header itself is transmitted as pulse streams, exactly as the index numbers. In short, instead of
transmitting bits, ECS codes them as edge counts and transmit them along with the formatting
information, itself edge-coded, so that the receiver is able to reconstitute the data word.

![image](https://github.com/user-attachments/assets/151a8f18-3853-43c2-bda3-d55a3384eba0)
Figure 1: (a) Standard serial transfer, (b) edge-coded transmitter, (c) edge-coded receiver.

# Example: ECS packet formation
![image](https://github.com/user-attachments/assets/5e25f242-9049-4d74-9d87-f48471d3d741)

Figure 2: Example: ECS packet formation.

# ECS packet
![image](https://github.com/user-attachments/assets/e56f4951-da78-4e19-addf-d8b66d90607b)

Figure 3: ECS packet.

# Transmission Waveforms
![image](https://github.com/user-attachments/assets/b0ee4c2e-9695-448e-bbe4-2429bc467c32)

Figure 4: (a) Transmitter, (b) receiver, (c) indices.

## For more details please consider the following publications.

1. ECS3 (PICplus): Shahzad Muzaffar and Ibrahim (Abe) M. Elfadel. 2020. **Dynamic Edge-coded Protocols for Low-power,
   Device-to-device Communication**. ACM Trans. Sen. Netw. 17, 1, Article 8 (February 2021), 24 pages.
   [![DOI:10.1145/3426181](https://zenodo.org/badge/DOI/10.1145/3426181.svg)](https://doi.org/10.1145/3426181)
2. ECS2 (PDC): S. Muzaffar and I. M. Elfadel, "**A pulsed decimal technique for single-channel, dynamic signaling for
   IoT applications**," 2017 IFIP/IEEE International Conference on Very Large Scale Integration (VLSI-SoC), Abu Dhabi,
   United Arab Emirates, 2017, pp. 1-6.[![DOI:10.1109/VLSI-SoC.2017.8203491](https://zenodo.org/badge/DOI/10.1109/VLSI-SoC.2017.8203491.svg)](https://ieeexplore.ieee.org/document/8203491)
4. ECS1 (PIC): S. Muzaffar, J. Yoo, A. Shabra and I. A. M. Elfadel, "**A pulsed-index technique for single-channel,
   low-power, dynamic signaling**," 2015 Design, Automation & Test in Europe Conference & Exhibition (DATE), Grenoble,
   France, 2015, pp. 1485-1490. [![DOI:10.7873/DATE.2015.1070](https://zenodo.org/badge/DOI/10.7873/DATE.2015.1070.svg)](https://ieeexplore.ieee.org/document/7092624)
5. DDR-ECS: S. Muzaffar and I. A. M. Elfadel, "**Double Data Rate Dynamic Edge-Coded Signaling for Low-Power IoT
   Communication**," 2019 IFIP/IEEE 27th International Conference on Very Large Scale Integration (VLSI-SoC),
   Cuzco, Peru, 2019, pp. 317-322. [![DOI:10.1109/VLSI-SoC.2019.8920318](https://zenodo.org/badge/DOI/10.1109/VLSI-SoC.2019.8920318.svg)](https://ieeexplore.ieee.org/document/8920318)
6. Secure ECS: S. Muzaffar, O. T. Waheed, Z. Aung and I. M. Elfadel, "**Lightweight, Single-Clock-Cycle, Multilayer
   Cipher for Single-Channel IoT Communication: Design and Implementation**," in IEEE Access, vol. 9, pp. 66723-66737,
   2021. [![DOI:10.1109/ACCESS.2021.3076468](https://zenodo.org/badge/DOI/10.1109/ACCESS.2021.3076468.svg)](https://ieeexplore.ieee.org/document/9419040)
7. Secure ECS: S. Muzaffar, O. T. Waheed, Z. Aung and I. A. M. Elfadel, "Single-clock-cycle, multilayer encryption
   algorithm for single-channel IoT communications," 2017 IEEE Conference on Dependable and Secure Computing, Taipei,
   Taiwan, 2017, pp. 153-158. [![DOI:10.1109/DESEC.2017.8073841](https://zenodo.org/badge/DOI/10.1109/DESEC.2017.8073841.svg)](https://ieeexplore.ieee.org/abstract/document/8073841)

