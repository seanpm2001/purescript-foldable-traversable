module Data.Foldable where

import Prelude
import Control.Applicative
import Data.Either
import Data.Eq
import Data.Maybe
import Data.Monoid
import Data.Tuple

class Foldable f where
  foldr :: forall a b. (a -> b -> b) -> b -> f a -> b
  foldl :: forall a b. (b -> a -> b) -> b -> f a -> b
  foldMap :: forall a m. (Monoid m) => (a -> m) -> f a -> m

instance foldableArray :: Foldable [] where
  foldr _ z []     = z
  foldr f z (x:xs) = x `f` (foldr f z xs)

  foldl _ z []     = z
  foldl f z (x:xs) = foldl f (z `f` x) xs

  foldMap _ []     = mempty
  foldMap f (x:xs) = f x <> foldMap f xs

instance foldableEither :: Foldable (Either a) where
  foldr _ z (Left _)  = z
  foldr f z (Right x) = x `f` z

  foldl _ z (Left _)  = z
  foldl f z (Right x) = z `f` x

  foldMap f (Left _)  = mempty
  foldMap f (Right x) = f x

instance foldableMaybe :: Foldable Maybe where
  foldr _ z Nothing  = z
  foldr f z (Just x) = x `f` z

  foldl _ z Nothing  = z
  foldl f z (Just x) = z `f` x

  foldMap f Nothing  = mempty
  foldMap f (Just x) = f x

instance foldableRef :: Foldable Ref where
  foldr f z (Ref x) = x `f` z

  foldl f z (Ref x) = z `f` x

  foldMap f (Ref x) = f x

instance foldableTuple :: Foldable (Tuple a) where
  foldr f z (Tuple _ x) = x `f` z

  foldl f z (Tuple _ x) = z `f` x

  foldMap f (Tuple _ x) = f x

fold :: forall f m. (Foldable f, Monoid m) => f m -> m
fold = foldMap id

traverse_ :: forall a b f m. (Applicative m, Foldable f) => (a -> m b) -> f a -> m {}
traverse_ f = foldr ((*>) <<< f) (pure {})

for_ :: forall a b f m. (Applicative m, Foldable f) => f a -> (a -> m b) -> m {}
for_ = flip traverse_

sequence_ :: forall a f m. (Applicative m, Foldable f) => f (m a) -> m {}
sequence_ = traverse_ id

mconcat :: forall f m. (Foldable f, Monoid m) => f m -> m
mconcat = foldl (<>) mempty

and :: forall f. (Foldable f) => f Boolean -> Boolean
and = foldl (&&) true

or :: forall f. (Foldable f) => f Boolean -> Boolean
or = foldl (||) false

any :: forall a f. (Foldable f) => (a -> Boolean) -> f a -> Boolean
any p = or <<< foldMap (\x -> [p x])

all :: forall a f. (Foldable f) => (a -> Boolean) -> f a -> Boolean
all p = and <<< foldMap (\x -> [p x])

sum :: forall f. (Foldable f) => f Number -> Number
sum = foldl (+) 0

product :: forall f. (Foldable f) => f Number -> Number
product = foldl (*) 1

elem :: forall a f. (Eq a, Foldable f) => a -> f a -> Boolean
elem = any  <<< (==)

notElem :: forall a f. (Eq a, Foldable f) => a -> f a -> Boolean
notElem x = not <<< elem x

find :: forall a f. (Foldable f) => (a -> Boolean) -> f a -> Maybe a
find p f = case foldMap (\x -> if p x then [x] else []) f of
  (x:_) -> Just x
  []    -> Nothing
