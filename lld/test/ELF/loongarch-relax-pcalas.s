# REQUIRES: loongarch

# RUN: llvm-mc --filetype=obj --triple=loongarch32 --mattr=+relax %s -o %t.32.o
# RUN: llvm-mc --filetype=obj --triple=loongarch64 --mattr=+relax %s -o %t.64.o

# RUN: ld.lld %t.32.o --section-start=.text=0x1000000 --section-start=.data=0x1200000 -o %t.32
# RUN: ld.lld %t.64.o --section-start=.text=0x1000000 --section-start=.data=0x1200000 -o %t.64

# RUN: llvm-objdump -d --no-show-raw-insn %t.32 | FileCheck %s --check-prefix=CHECK32
# RUN: llvm-objdump -d --no-show-raw-insn %t.64 | FileCheck %s --check-prefix=CHECK64

# CHECK32: 1000000 <_start>:
# CHECK32: 1000000:    pcalau12i $a0, 512
# CHECK32: 1000004:    addi.w    $a0, $a0, 0
# CHECK32: 1000008:    pcaddi    $a0, 524286
# CHECK32: 100000c:    pcaddi    $a0, 524285
# CHECK32: 1000010:    pcalau12i $a0, 512
# CHECK32: 1000014:    addi.w    $a0, $a0, 1
# CHECK32: 1000018:    pcalau12i $a0, 512
# CHECK32: 100001c:    addi.w    $a0, $a0, 1
# CHECK32: 1000020:    pcalau12i $a0, 512
# CHECK32: 1000024:    ld.w      $a0, $a0, 4
# CHECK32: 1000028:    pcalau12i $a0, 512
# CHECK32: 100002c:    ld.w      $a0, $a0, 8

# CHECK64: 1000000 <_start>:
# CHECK64: 1000000:    pcalau12i $a0, 512
# CHECK64: 1000004:    addi.d    $a0, $a0, 0
# CHECK64: 1000008:    pcaddi    $a0, 524286
# CHECK64: 100000c:    pcaddi    $a0, 524285
# CHECK64: 1000010:    pcalau12i $a0, 512
# CHECK64: 1000014:    addi.d    $a0, $a0, 1
# CHECK64: 1000018:    pcalau12i $a0, 512
# CHECK64: 100001c:    addi.d    $a0, $a0, 1
# CHECK64: 1000020:    pcalau12i $a0, 512
# CHECK64: 1000024:    ld.d      $a0, $a0, 8
# CHECK64: 1000028:    pcalau12i $a0, 512
# CHECK64: 100002c:    ld.d      $a0, $a0, 16

  .text
## Start at 0x1000000
  .global _start
_start:
  la.pcrel $a0, ptr_1    # Not relaxed due to out of 22bits-simm range
  la.pcrel $a0, ptr_1    # Should be relaxed to pcaddi
  la.got   $a0, ptr_1    # Should be relaxed to pcaddi
  la.pcrel $a0, ptr_2    # Not relaxed due to not aligned
  la.got   $a0, ptr_2    # Should be relaxed to pcalau12i+addi
  la.got   $a0, ptr_3    # Not relaxed
  la.got   $a0, ptr_4    # Not relaxed

  .data
## Start at 0x1200000
  .local   ptr_1, ptr_2
  .global  ptr_3
  .weak    ptr_4
ptr_1:   .byte 0
ptr_2:   .byte 0
ptr_3:   .byte 0
ptr_4:   .byte 0
