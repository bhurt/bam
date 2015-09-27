{-# LANGUAGE FlexibleInstances #-}

{-|
Module              : Choice
Description         : The Choice datastructure and basic operations
Copyright           : (c) Brian Hurt, 2015
License             : LGPL-2.1
Maintainer          : bhurt42@gmail.com
Stability           : experimental
Portability         : safe

This is the Choice data structure, the core data structure to BAM.  It
represents a multi-tailed list or choice tree.
-}
module Choice where

    import Data.Bifunctor

    data Choice a b =
        Choice (Choice a b) (Choice a b)    -- | Tree-like branch node
        | Emit b (Choice a b)               -- | List-like sequence node
        | Done a                            -- | Leaf node

    emit :: a -> b -> Choice a b
    emit a b = Emit b (Done a)

    fromList :: [ Choice a b ] -> Choice a b
    fromList [] = error "Empty choices list!"
    fromList [x] = x
    fromList (x:xs) = Choice x (fromList xs)

    choices :: Choice a b -> [ Choice a b ]
    choices = go []
        where
            go acc (Choice a b) = go (go acc b) a
            go acc x = x : acc

    emits :: Choice a b -> ([b], Choice a b)
    emits = go []
        where
            go acc (Emit x b) = go (x : acc) b
            go acc t = ((reverse acc), t)

    isDone :: Choice a b -> Bool
    isDone (Done _) = True
    isDone _ = False

    extend :: (a -> Choice c b) -> Choice a b -> Choice c b
    extend f (Choice a b) = Choice (extend f a) (extend f b)
    extend f (Emit x a) = Emit x (extend f a)
    extend f (Done s) = f s

    followedBy :: Choice a' b -> Choice a b -> Choice a b
    followedBy a b = extend (const b) a

    instance Functor (Choice s) where
        fmap f (Choice a b) = Choice (fmap f a) (fmap f b)
        fmap f (Emit x a) = Emit (f x) (fmap f a)
        fmap _ (Done s) = Done s

    instance Bifunctor Choice where
        bimap f g (Choice a b) = Choice (bimap f g a) (bimap f g b)
        bimap f g (Emit x a) = Emit (g x) (bimap f g a)
        bimap f _ (Done s) = Done (f s)
        first f (Choice a b) = Choice (first f a) (first f b)
        first f (Emit x a) = Emit x (first f a)
        first f (Done s) = Done (f s)
        second g (Choice a b) = Choice (second g a) (second g b)
        second g (Emit x a) = Emit (g x) (second g a)
        second _ (Done s) = Done s

    bind :: Choice a b -> (b -> Choice a c) -> Choice a c
    bind (Choice a b) f = Choice (bind a f) (bind b f)
    bind (Emit x a) f = f x `followedBy` (bind a f)
    bind (Done s) _ = Done s

    instance Applicative (Choice ()) where
        pure = emit ()
        fs <*> xs = bind fs (\f -> bind xs (\x -> emit () (f x)))

    instance Monad (Choice ()) where
        return = emit ()
        (>>=) = bind

    trunc :: Choice a b -> Choice () b
    trunc = first $ const ()

    modify :: (t -> a -> Choice t b) -> (s -> t -> u) -> t
                -> Choice s a -> Choice u b
    modify f g t (Choice a b) = Choice (modify f g t a) (modify f g t b)
    modify f g t (Emit x a) = extend (\t' -> modify f g t' a) (f t x)
    modify _ g t (Done s) = Done (g s t)


