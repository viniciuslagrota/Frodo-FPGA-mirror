# Frodo Post-quantum algorithm
This document aims to explain what was done to implement the Frodo Post-quantum Algorithm in an FPGA Zynq-7000.

The FPGA Zynq-7000 is a SOC FPGA (ARM A9 dual-core + FPGA).

## Frodo explained

Read Standard Lattice-Based Key Encapsulation on Embedded Devices article.

## What was done
In order to implement the Frodo algorithm and propose enhancements on it, the first step was to use the available online implementation, proposed by its creators, and migrate the code to the ARM A9. This will be the base for further comparisons.

Analyzing the code implemented by Frodo's creators using Visual Studio, it was possible to verify the slower parts of the code. The slowest part is the implementation of the SHAKE-128 hash function, which has the purpose to be a pseudorandom number generator. The second slower part is matrix multiplication.

Therefore, in order to reduce this bottleneck, the Keccak-f1600 function, which is the major part of the SHAKE-128 hash function, was implemented in hardware (FPGA).

## Results
To perform the timing test, the code firstly executes a KEM test, which is composed of a keypair generate, encryption, and decryption, using only software. The next step is to perform the KEM using an AXI-Stream Keccak-f1600. And finally, execute the KEM using an AXI-MM Keccak-f1600.

The results are listed bellow:

| Architecture          	| Key pair (ms) 	| Encryption (ms) 	| Decryption (ms) 	| Total (ms) 	| Improvement (%) 	|
|-----------------------	|---------------	|-----------------	|-----------------	|------------	|-----------------	|
| Software              	| 467.25           	| 644.74          	| 645.75          	| 1757.33    	| -               	|
| Software + Hardware     	| 146.35           	| 205.11          	| 208.26         	| 559.72       	| 68.14           	|

An interesting observation to be pointed out is that the Frodo Post-quantum Algorithm is slower in the ARM processor than in an Intel processor. This can be easily explained by two main factors: the first one is that the Intel processor runs in a higher frequency than the ARM processor. The latter runs at 666MHz and the former at 3GHz, approximately. Although, the biggest impact is due to each one architecture. The ARM processor uses a RISC architecture, which has a reduced instruction complexity. On the other hand, the Intel processor uses a CISC architecture, which has a high instruction complexity. Therefore, the Intel processor needs less instructions to execute the same task when compared with an ARM processor. So, it is easy to figure out that and processor which runs faster and need less instructions to complete a task (Intel) will take much less time than the other that runs slower and need more instructions to perform the same task (ARM). In order to compare, the Intel processor takes 250 millions of cycles or 120 ms, approximately, to perform the KEM test; and the ARM takes 1.2 billion of cycles or 1800 ms to perform the same KEM test.

## IP-code
All IP codes implemented in hardware (VHDL) are commited in a separated repository.

## Repo organization
All projects can be found inside /frodo-fpga.sdk folder.
- /frodo-fpga.sdk/frodo_sdk: provides a simples code to test FrodoKEM using software and hardware/software co-design implementation.
- /frodo-fpga.sdk/frodo_client: provides the client side that reads SWM3000 data and implements a TCP client to send encrypted data using AES-256-GCM with keys previously exchanged using Frodo.
- /frodo-fpga.sdk/frodo_server: provides the server side that receives the SWM3000 encrypted data through a TCP server. It uses AES-256-GCM with keys previously exchanged using Frodo to decipher the received data.