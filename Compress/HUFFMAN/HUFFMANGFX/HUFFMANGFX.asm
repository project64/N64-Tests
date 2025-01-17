// N64 'Bare Metal' HUFFMAN GFX Demo by krom (Peter Lemon) & Andy Smith:
arch n64.cpu
endian msb
output "HUFFMANGFX.N64", create
fill 1052672 // Set ROM Size

origin $00000000
base $80000000 // Entry Point Of Code
include "LIB/N64.INC" // Include N64 Definitions
include "LIB/N64_HEADER.ASM" // Include 64 Byte Header & Vector Table
insert "LIB/N64_BOOTCODE.BIN" // Include 4032 Byte Boot Code

Start:
  include "LIB/N64_GFX.INC" // Include Graphics Macros
  N64_INIT() // Run N64 Initialisation Routine

  ScreenNTSC(640, 480, BPP32|INTERLACE|AA_MODE_2, $A0100000) // Screen NTSC: 640x480, 32BPP, Interlace, Resample Only, DRAM Origin $A0100000

  la a0,Huff // A0 = Source Address
  lui a1,$A010 // A1 = Destination Address (DRAM Start Offset)

  lbu t0,3(a0) // T0 = HI Data Length Byte
  sll t0,8
  lbu t1,2(a0) // T1 = MID Data Length Byte
  or t0,t1
  sll t0,8
  lbu t1,1(a0) // T1 = LO Data Length Byte
  or t0,t1 // T0 = Data Length
  add t0,a1 // T0 = Destination End Offset (DRAM End Offset)
  addi a0,4 // Add 4 To Huffman Offset

  lbu t1,0(a0) // T1 = (Tree Table Size / 2) - 1
  addi a0,1 // A0 = Tree Table
  sll t1,1
  addi t1,1 // T1 = Tree Table Size
  add t1,a0 // T1 = Compressed Bitstream Offset

  subi a0,5 // A0 = Source Address
  lli t6,0 // T6 = Branch/Leaf Flag (0 = Branch 1 = Leaf)
  lli t7,5 // T7 = Tree Table Offset (Reset)
HuffChunkLoop:
  lbu t2,3(t1) // T2 = Data Length Byte 0
  sll t2,8
  lbu t8,2(t1) // T8 = Data Length Byte 1
  or t2,t8
  sll t2,8
  lbu t8,1(t1) // T8 = Data Length Byte 2
  or t2,t8
  sll t2,8
  lbu t8,0(t1) // T8 = Data Length Byte 3
  or t2,t8 // T2 = Node Bits (Bit31 = First Bit)
  addi t1,4 // Add 4 To Compressed Bitstream Offset
  lui t3,$8000 // T3 = Node Bit Shifter

  HuffByteLoop: 
    beq a1,t0,HuffEnd // IF (Destination Address == Destination End Offset) HuffEnd
    nop // Delay Slot
    beqz t3,HuffChunkLoop // IF (Node Bit Shifter == 0) HuffChunkLoop
    nop // Delay Slot

    add t8,a0,t7
    lbu t4,0(t8) // T4 = Next Node
    andi t8,t6,1 // Test T6 == Leaf
    beqz t8,HuffBranch
    nop // Delay Slot
    sb t4,0(a1) // Store Data Byte To Destination IF Leaf
    addi a1,1 // Add 1 To DRAM Offset
    lli t6,0 // T6 = Branch
    lli t7,5 // T7 = Tree Table Offset (Reset)
    j HuffByteLoop
    nop // Delay Slot

    HuffBranch:
      andi t5,t4,$3F // T5 = Offset To Next Child Node
      sll t5,1
      addi t5,2 // T5 = Node0 Child Offset * 2 + 2
      li t8,$FFFFFFFE // T7 = Tree Offset NOT 1
      and t7,t8
      add t7,t5 // T7 = Node0 Child Offset

      and t8,t2,t3 // Test Node Bit (0 = Node0, 1 = Node1)
      srl t3,1 // Shift T3 To Next Node Bit
      beqz t8,HuffNode0
      nop // Delay Slot
      addi t7,1 // T7 = Node1 Child Offset
      lli t8,$40 // T8 = Test Node1 End Flag
      j HuffNodeEnd
      nop // Delay Slot
      HuffNode0:
        lli t8,$80 // T8 = Test Node0 End Flag
      HuffNodeEnd:

      and t9,t4,t8 // Test Node End Flag (1 = Next Child Node Is Data)
      beqz t9,HuffByteLoop
      nop // Delay Slot
      lli t6,1 // T6 = Leaf
      j HuffByteLoop
      nop // Delay Slot
  HuffEnd:

Loop:
  WaitScanline($1E0) // Wait For Scanline To Reach Vertical Blank
  WaitScanline($1E2)

  lli t0,$00000800 // Even Field
  sw t0,VI_Y_SCALE(a0)

  WaitScanline($1E0) // Wait For Scanline To Reach Vertical Blank
  WaitScanline($1E2)

  li t0,$02000800 // Odd Field
  sw t0,VI_Y_SCALE(a0)

  j Loop
  nop // Delay Slot

insert Huff, "Image.huff"