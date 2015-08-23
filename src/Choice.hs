
\chapter{Choice}
\label{chap:Choice}

\section{Module}

>   module Choice where

\section{Choice data structure}

The biggest problem in making a compiler backend is that there are three
different algorithms: instruction selection, register allocation, and
instruction scheduling.  By themselves, the algorithms are not of
overwhelming complexity, The problem is, decisions made by any one of
the algorithms impact the decisions made by all the rest- and the right
decision for one algorithm to pick may change depending upon the state
of the other algorithms.

For example, on the Intel x86 architecture, if we want to add the
constant {\tt 7} to an expression, we can do this in (at least) two
different ways.  We can use the {\tt ADD} instruction, or we can use the
{\tt LEA} (Load Effective Address) instruction.  Which of these two
instructions should the instruction selection algorithm pick?

This depends upon the results of the other two algorithms.  The target
of the {\tt ADD} instruction can be in memory, while this is not true
for the {\tt LEA}- however, the result of the {\tt LEA} can be stored in
a different register than the target, which is not true of the {\tt ADD}
instruction.  So the decisions of the register allocator influence which
of the two possible instructions is better.

But the instruction scheduler also has implications for which
instruction should be selected.  The {\tt ADD} instruction takes an
arithmetic functional unit, while the {\tt LEA} uses a load functional
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

\subsection{Choice}

BAM approaches the problem in a radically different way.  Rather than
trying to figure out the right decision apriori, it simply records that
a choice needs to be made.  Rather than the instructions being created
in a simple list, they are produced in a multi-tail list, or choice
tree.

>   data Choice a =
>       Choice (Choice a) (Choice a)
>       | Emit a (Choice a)
>       | Done

>   toList :: Choice a -> [ [ a ] ]
>   toList (Choice a b) = toList a ++ toList b
>   toList (Emit x a) = fmap (x:) (toList a)
>   toList Done = [ [] ]

\subsection{Constructors}

>   emit :: a -> Choice a
>   emit x = Emit x Done

>   choice2 :: Choice a -> Choice a -> Choice a
>   choice2 = Choice

>   choice3 :: Choce a -> Choice a -> Choice a -> Choice a
>   choice3 c1 c2 c3 = Choice c1 (Choice c2 c3)

>   choice4 :: Choice a -> Choice a -> Choice a -> Choice a -> Choice a
>   choice4 c1 c2 c3 c4 = choice2 (choice2 c1 c2) (choice2 c3 c4)

>   choice5 :: Choice a -> Choice a -> Choice a
>               -> Choice a -> Choice a -> Choice a
>   choice5 c1 c2 c3 c4 c5 =
>       choice2 (choice2 c1 c2) (choice3 c1 c2 c3)

>   choice6 :: Choice a -> Choice a -> Choice a
>               -> Choice a -> Choice a -> Choice a -> Choice a
>   choice6 c1 c2 c3 c4 c5 c6 =
>       choice3 (choice2 c1 c2) (choice2 c3 c4) (choice2 c5 c6)

>   choice7 :: Choice a -> Choice a -> Choice a -> Choice a
>               -> Choice a -> Choice a -> Choice a -> Choice a
>   choice7 c1 c2 c3 c4 c5 c6 c7 =
>       choice2 (choice3 c1 c2 c3) (choice4 c4 c5 c6 c7)

>   choices :: Choice a -> [ Choice a ] -> Choice a
>   choices x lst = fini $ foldr inc [ Just x ] lst
>       where
>           -- inc :: Choice a -> [ Maybe (Choice a) ]
>           --        -> [ (Maybe Choice a) ]
>           inc y [] = [ Just y ]
>           inc y ((Just x) : xs) =
>               Nothing : inc (Choice y x) xs
>           inc y (Nothing : xs) = (Just y) : xs
>           -- fini :: [ Maybe (Choice a) ] -> Choice a
>           fini [] = error "Unreachable code reached" -- Not reachable
>           fini (Nothing : xs) = fini xs
>           fini ((Just x) : xs) = fini2 x xs
>           fini2 x [] = x
>           fini2 x (Nothing : xs) = fini2 x xs
>           fini2 x ((Just y) : ys) = fini2 (Choice x y) ys

>       

\subsection{Functor, Applicative, and Monad }

>   instance Functor Choice where
>       fmap f (Choice a b) = Choice (fmap f a) (fmap f b)
>       fmap f (Emit x a) = Emit (f x) (fmap f a)
>       fmap _ Done = Done

>   followedBy :: Choice a -> Choice a -> Choice a
>   followedBy (Choice a b) c =
>               Choice (a `followedBy` c) (b `followedBy` c)
>   followedBy (Emit x a) = Emit x (a `followedBy` c)
>   followedBy Done c = c

>   bind :: Choice a -> (a -> Choice b) -> Choice b
>   bind (Choice a b) f = Choice (bind a f) (bind b f)
>   bind (Emit x a) f = f x `followedBy` (bind a f)
>   bind Done _ = Done

>   instance Applicative Choice where
>       fs <*> xs = bind fs (\f -> bind xs (\x -> emit (f x)))

>   instance Monad Choice where
>       return = emit
>       (>>=) = bind

