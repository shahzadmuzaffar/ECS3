The core idea of ECS is to select the ON bits in a data word and transmit their index numbers as
pulse streams instead of transmitting the data bits themselves. An example is given in Figure 2(b)
where the bit sequence “0101” of Figure 2(a) is transformed into series of pulses in which the
count of pulses in each series is n + 1 with n being the ordinal number of the ON bit in the binary
sequence. In the example of Figure 2, there are two series of pulses. The first series has one pulse
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
in Figure 2(c). The apparent drawback is that more work is seemingly needed to transmit such
pulse series than the raw bits themselves. However, this is not the case as it is conceivable to
achieve high data rates, using an encoding process that makes the index numbers as small as
possible. This is accomplished by breaking the bit stream into smaller segments, reducing the
number of ON bits as much as possible in each segment, and relocating these ON bits to the
lowest index positions. The encoding information and the number of ON bits in the encoded
data are sent as a packet header along with the index numbers. All the information in the packet
header itself is transmitted as pulse streams, exactly as the index numbers. In short, instead of
transmitting bits, ECS codes them as edge counts and transmit them along with the formatting
information, itself edge-coded, so that the receiver is able to reconstitute the data word. The steps
involved in ECS transmission are explained in the following subsections.
