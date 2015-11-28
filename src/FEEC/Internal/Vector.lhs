\section{Vectors}

The \code{Vector} module provides a data type and
functions for the handling of vectors in $n$-dimensional Euclidean space
 $\R{n}$.

%------------------------------------------------------------------------------%

\begin{code}

{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}

module FEEC.Internal.Vector(

  -- * The Vector Type
  Vector(..), Dimensioned(..), vector,

  -- * Manipulating Vectors
  toList,

  -- * Mathematical Functions
  dot, pow

  ) where

import FEEC.Internal.Spaces
import qualified FEEC.Internal.MultiIndex as MI
import FEEC.Utility.Print
import qualified FEEC.Utility.Utility as U


\end{code}

%------------------------------------------------------------------------------%

\subsection{The \code{Vector} Type}

 Vectors in $\R{n}$ are represented using the parametrized type \code{Vector a}
 where \code{a} is the number type used to represent the scalars. Internally a
 vector is implemented using a list \code{[a]}. The dimension $n$ is inferred
 from the length of the list. Since vectors from Euclidean spaces of different
 dimension are of the same type, it is up to the user not to mix vectors from
 different spaces, which will lead to runtime errors.

%------------------------------------------------------------------------------%

\begin{code}

-- | Vectors in n-dimensional euclidean space.
data Vector a = Vector { components :: [a] } deriving (Show)

\end{code}

%------------------------------------------------------------------------------%

 To use the \code{Vector a} type in the \code{FEEC} framework, we have to make
 it an instance of the \code{VectorSpace} and the \code{EuclideanSpace} classes.
 We instantiate two types \code{Vector Rational} and \code{Vector Double} in
 order to have one type with exact arithmetic using Haskells \code{Rational}
 type and one using standard floating point arithmetic.

%------------------------------------------------------------------------------%

\begin{code}

-- | Use numerical equality for floating point arithmetic.
-- instance Eq (Vector Double) where
--    v1 == v2 = and (zipWith U.eqNum (components v1) (components v2))

-- | Use exact equality for exact arithmetic.
--instance Eq (Vector Rational) where
--    v1 == v2 = and (zipWith (==) (components v1) (components v2))


instance Eq a => Eq (Vector a) where
    v1 == v2 = and (zipWith (==) (components v1) (components v2))

-- | R^n as a vector space.
instance Ring a => VectorSpace (Vector a) where
  type Scalar (Vector a) = a
  addV (Vector l1) (Vector l2) = Vector $ zipWith add l1 l2
  sclV c (Vector l) = Vector $ map (mul c) l

-- | R^n as a Euclidean space.
instance (Field a, Eq a) => EuclideanSpace (Vector a) where
    dot (Vector l1) (Vector l2) = foldl add addId (zipWith mul l1 l2)
    toList   = components
    fromList = vector

-- | The dimension of vectors.
instance Dimensioned (Vector a) where
    dim (Vector l) = length l

\end{code}

%------------------------------------------------------------------------------%

\subsubsection{Constructors}

 The \code{Vector a} data type provides the \code{vector} function as a smart
 constructor for vectors. Even though up to now the constructor does nothing
 but calling the type constructor, the \code{vector} functions is provided to
 hide the internal implementation to other modules.

%------------------------------------------------------------------------------%

\begin{code}

-- | Create vector from list of components.
vector :: [a] -> Vector a
vector = Vector

\end{code}

%------------------------------------------------------------------------------%

\subsubsection{Printing Vectors}

 Vectors can be displayed on the command line in two ways. As an instance of
 \code{Show}, calling \code{show} on a vector will display its type structure.
 Using \code{pPrint} to render the vector, the vector is redered as a column
 vector using unicode characters.

%------------------------------------------------------------------------------%

\begin{code}

-- | Pretty printing for vectors.
instance Field a => Pretty (Vector a) where
    pPrint v = text "Vector in "
               <> rn (dim v)
               <> text ":\n"
               <> printVector 2 (map toDouble (components v))

\end{code}


