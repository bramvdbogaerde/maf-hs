module Dependency.State where 

import Data.Map hiding (partition)
import Data.List (groupBy, partition, elem)

import Interpreter.Scheme
import Dependency.Lattice

type AbstractSto v = Map CAdr v 

covering :: (RefinableLattice v) => AbstractSto v -> [AbstractSto v]
-- | a covering of a state s is a set of refinements of that state such that all possible values are accounted for
covering s = fmap fromList (sequence $ groupBy (\ a b -> fst a == fst b) [(k, v') | (k, v) <- toList s, v' <- refine v ++ [v]])

xCovering :: (RefinableLattice v) => [CAdr] -> AbstractSto v -> [AbstractSto v]
-- | values of variables outside some set X take values that are the same as either the corresponding values in s or their direct subvalues
xCovering x s = fmap fromList (sequence $ groupBy (\ a b -> fst a == fst b) ([(k, v') | (k, v) <- notInX, v' <- refine v ++ [v]] ++ inX))
                where (inX, notInX) = partition (\a -> elem (fst a) x) (toList s)

----
-- abstract evaluation of an expression given an abstract state
AbstractEval :: (Domain v) => Exp -> AbstractSto v -> v 
