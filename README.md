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

The biggest problem in making a compiler backend is that there are three
different algorithms: instruction selection, register allocation, and
instruction scheduling.  By themselves, the algorithms are not of
overwhelming complexity, The problem is, decisions made by any one of
the algorithms impact the decisions made by all the rest- and the right
decision for one algorithm to pick may change depending upon the state
of the other algorithms.

For example, on the Intel x86 architecture, if we want to add the
constant @7@ to an expression, we can do this in (at least) two
different ways.  We can use the @ADD@ instruction, or we can use the
@LEA@ (Load Effective Address) instruction.  Which of these two
instructions should the instruction selection algorithm pick?

This depends upon the results of the other two algorithms.  The target
of the @ADD@ instruction can be in memory, while this is not true
for the @LEA@- however, the result of the @LEA@ can be stored in
a different register than the target, which is not true of the @ADD@
instruction.  So the decisions of the register allocator influence which
of the two possible instructions is better.

But the instruction scheduler also has implications for which
instruction should be selected.  The @ADD@ instruction takes an
arithmetic functional unit, while the @LEA@ uses a load functional
unit.  Which instruction is optimal to emit depends upon what other
instructions are being issued at the same time, and thus what functional
units are free.

And this is a fairly simple example- in reality, things can be
significantly more complicated, as instructions require values to be in
specific registers or sets of registers, the register allocator needs to
figure out which values to spill and fill, and instruction scheduling
rules become complicated.  The correct decision for any stage to make
depends upon the results of all the other stages.

The classical solution to this problem is to just implement all three
algorithms at the same time.  This is why implementing a compiler back
end is considered such a professional coup.  While each stage is, by
itself, not of overwhelming the complexity, the combination of all three
challenge human intellectual capacity.

Unfortunately, in addition to making the result hard to implement, it
also makes it very hard to understand, change, or tune.  More
complicated algorithms that might produce better results are often not
implemented, due simply to the complexity of doing so.  Certainly
experimentation is reduced due to the high cognitive overhead.

BAM approaches the problem in a radically different way.  Rather than
trying to figure out the right decision apriori, it simply records that
a choice needs to be made.  Rather than the instructions being created
in a simple list, they are produced in a multi-tail list, or choice
tree.


