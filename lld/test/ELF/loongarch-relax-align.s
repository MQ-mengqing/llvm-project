# REQUIRES: loongarch

# RUN: llvm-mc -filetype=obj -triple=loongarch32 --mattr=+relax %s -o %t.32.o
# RUN: llvm-mc -filetype=obj -triple=loongarch64 --mattr=+relax %s -o %t.64.o
# RUN: ld.lld --section-start=.text=0x12000 --section-start=.text2=0x14000 -e 0 %t.32.o -o %t.32
# RUN: ld.lld --section-start=.text=0x12000 --section-start=.text2=0x14000 -e 0 %t.64.o -o %t.64
# RUN: ld.lld --section-start=.text=0x12000 --section-start=.text2=0x14000 -e 0 %t.32.o --no-relax -o %t.32.norelax
# RUN: ld.lld --section-start=.text=0x12000 --section-start=.text2=0x14000 -e 0 %t.64.o --no-relax -o %t.64.norelax
# RUN: llvm-objdump -td --no-show-raw-insn %t.32 | FileCheck %s --check-prefix=CHECK32R
# RUN: llvm-objdump -td --no-show-raw-insn %t.64 | FileCheck %s --check-prefix=CHECK64R
# RUN: llvm-objdump -td --no-show-raw-insn %t.32.norelax | FileCheck %s --check-prefix=CHECK32
# RUN: llvm-objdump -td --no-show-raw-insn %t.64.norelax | FileCheck %s --check-prefix=CHECK64

# RUN: ld.lld -r %t.64.o -o %t.64.r
# RUN: llvm-objdump -tdr --no-show-raw-insn %t.64.r | FileCheck %s --check-prefix=CHECKR

# CHECK32-DAG: 00012000 l       .text   {{0*}}44 .Ltext_start
# CHECK32-DAG: 00012038 l       .text   {{0*}}0c .L1
# CHECK32-DAG: 00012040 l       .text   {{0*}}04 .L2
# CHECK32-DAG: 00014000 l       .text2  {{0*}}14 .Ltext2_start

# CHECK32:        <.Ltext_start>:
# CHECK32-NEXT:         break 1
# CHECK32-NEXT:         break 2
# CHECK32-NEXT:         nop
# CHECK32-NEXT:         nop
# CHECK32-NEXT:         break 3
# CHECK32-NEXT:         nop
# CHECK32-NEXT:         nop
# CHECK32-NEXT:         nop
# CHECK32-NEXT:         pcalau12i $zero, 0
# CHECK32-NEXT:         addi.w    $zero, $zero, 0
# CHECK32-NEXT:         pcalau12i $zero, 0
# CHECK32-NEXT:         addi.w    $zero, $zero, 56
# CHECK32-NEXT:         pcalau12i $zero, 0
# CHECK32-NEXT:         addi.w    $zero, $zero, 64
# CHECK32-EMPTY:
# CHECK32-NEXT:   <.L1>:
# CHECK32-NEXT:         nop
# CHECK32-NEXT:         nop
# CHECK32-EMPTY:
# CHECK32-NEXT:   <.L2>:
# CHECK32-NEXT:         break 4

# CHECK32:        <.Ltext2_start>:
# CHECK32-NEXT:         pcalau12i  $zero, 0
# CHECK32-NEXT:         addi.w     $zero, $zero, 0
# CHECK32-NEXT:         nop
# CHECK32-NEXT:         nop
# CHECK32-NEXT:         break 5

# CHECK64-DAG: 00012000 l       .text   {{0*}}44 .Ltext_start
# CHECK64-DAG: 00012038 l       .text   {{0*}}0c .L1
# CHECK64-DAG: 00012040 l       .text   {{0*}}04 .L2
# CHECK64-DAG: 00014000 l       .text2  {{0*}}14 .Ltext2_start

# CHECK64:        <.Ltext_start>:
# CHECK64-NEXT:         break 1
# CHECK64-NEXT:         break 2
# CHECK64-NEXT:         nop
# CHECK64-NEXT:         nop
# CHECK64-NEXT:         break 3
# CHECK64-NEXT:         nop
# CHECK64-NEXT:         nop
# CHECK64-NEXT:         nop
# CHECK64-NEXT:         pcalau12i $zero, 0
# CHECK64-NEXT:         addi.d    $zero, $zero, 0
# CHECK64-NEXT:         pcalau12i $zero, 0
# CHECK64-NEXT:         addi.d    $zero, $zero, 56
# CHECK64-NEXT:         pcalau12i $zero, 0
# CHECK64-NEXT:         addi.d    $zero, $zero, 64
# CHECK64-EMPTY:
# CHECK64-NEXT:   <.L1>:
# CHECK64-NEXT:         nop
# CHECK64-NEXT:         nop
# CHECK64-EMPTY:
# CHECK64-NEXT:   <.L2>:
# CHECK64-NEXT:         break 4

# CHECK64:        <.Ltext2_start>:
# CHECK64-NEXT:         pcalau12i  $zero, 0
# CHECK64-NEXT:         addi.d     $zero, $zero, 0
# CHECK64-NEXT:         nop
# CHECK64-NEXT:         nop
# CHECK64-NEXT:         break 5

# CHECKR-DAG: 0000000000000000 l       .text    {{0*}}8c .Ltext_start
# CHECKR-DAG: 000000000000004c l       .text    {{0*}}40 .L1
# CHECKR-DAG: 0000000000000088 l       .text    {{0*}}04 .L2
# CHECKR-DAG: 0000000000000000 l       .text2   {{0*}}18 .Ltext2_start

# CHECKR:        <.Ltext_start>:
# CHECKR-NEXT:           break 1
# CHECKR-NEXT:           break 2
# CHECKR-NEXT:           nop
# CHECKR-NEXT:           0000000000000008:  R_LARCH_ALIGN       *ABS*+0xc
# CHECKR-NEXT:           nop
# CHECKR-NEXT:           nop
# CHECKR-NEXT:           break 3
# CHECKR-NEXT:           nop
# CHECKR-NEXT:           0000000000000018:  R_LARCH_ALIGN       *ABS*+0x1c
# CHECKR-NEXT:           nop
# CHECKR-NEXT:           nop
# CHECKR-NEXT:           nop
# CHECKR-NEXT:           nop
# CHECKR-NEXT:           nop
# CHECKR-NEXT:           nop
# CHECKR:        <.L1>:
# CHECKR-NEXT:           nop
# CHECKR-NEXT:           000000000000004c:  R_LARCH_ALIGN       *ABS*+0x3c
# CHECKR-NEXT:           nop
# CHECKR-NEXT:           nop
# CHECKR-NEXT:           nop
# CHECKR-NEXT:           nop
# CHECKR-NEXT:           nop
# CHECKR-NEXT:           nop
# CHECKR-NEXT:           nop
# CHECKR-NEXT:           nop
# CHECKR-NEXT:           nop
# CHECKR-NEXT:           nop
# CHECKR-NEXT:           nop
# CHECKR-NEXT:           nop
# CHECKR-NEXT:           nop
# CHECKR-NEXT:           nop
# CHECKR-EMPTY:
# CHECKR-NEXT:   <.L2>:
# CHECKR-NEXT:           break 4

# CHECK32R-DAG: 00012000 l       .text	{{0*}}44 .Ltext_start
# CHECK32R-DAG: 0001202c l       .text	{{0*}}18 .L1
# CHECK32R-DAG: 00012040 l       .text	{{0*}}04 .L2
# CHECK32R-DAG: 00014000 l       .text2	{{0*}}14 .Ltext2_start

# CHECK64R-DAG: 00012000 l       .text	{{0*}}44 .Ltext_start
# CHECK64R-DAG: 0001202c l       .text	{{0*}}18 .L1
# CHECK64R-DAG: 00012040 l       .text	{{0*}}04 .L2
# CHECK64R-DAG: 00014000 l       .text2	{{0*}}14 .Ltext2_start

  .text
.Ltext_start:
  .balign 4
  break 1
  break 2
  .balign 16
  break 3
  .balign 32
  la.pcrel $r0, .Ltext_start
  la.pcrel $r0, .L1
  la.pcrel $r0, .L2
.L1:
  .balign 64
.L2:
  break 4
  .size .L1, . - .L1
  .size .L2, . - .L2
  .size .Ltext_start, . - .Ltext_start

  .section .text2,"ax",@progbits
.Ltext2_start:
  la.pcrel $r0, .Ltext2_start
  .balign 16
  break 5
  .size .Ltext2_start, . - .Ltext2_start
