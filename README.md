# bam
Brian's Abstract Machine- an LLVM-like library for functional programming languages.

BAM is a library (written in Haskell) implementing
the back end of a compiler- similar to what LLVM provides.  BAM is,
however, different in two important ways.

Firstly, most compiler back ends are written in C++, which, in the
author's opinion, is the worst possible language for the task.  BAM, by
contrast, is written in the programming language Haskell.  This has
important implementation consequences- foremost of which is that the
lazy evaluation of Haskell allows us to disentangle the instruction
selection, register allocation, and instruction scheduling passes.  See
the Choice module for more information.

Secondly, the choice of initial target languages also deeply influences
the design of a backend- and most backends use languages like C++ and
Fortran as initial target languages.  BAM uses Haskell and Prolog as
it's initial languages of choice.

BAM is sufficiently different from previous compiler back ends (that the
author is aware of) that a two-phase approach is being used.  In phase
1, a proper LLVM interface is provided.  This allows an apples to apples
comparison to LLVM.  In the second phase, the new IR targetted at
Haskell and Prolog will be introduced.

