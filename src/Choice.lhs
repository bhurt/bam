
\chapter{Choice}
\label{Choice}

%include lhs2TeX.fmt
%include lhs2TeX.sty

> module Choice where

> data Choice a =
>     Choice (Choice a) (Choice a)
>     | Emit a (Choice a)
>     | Done
>     | Fail

> instance Functor Choice where
>     fmap f (Choice a b) = Choice (fmap f a) (fmap f b)
>     fmap f (Emit x a) = Emit (f x) (fmap f a)
>     fmap _ Done = Done
>     fmap _ Fail = Fail

