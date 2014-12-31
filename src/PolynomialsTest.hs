{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}

import Data.Maybe
import Polynomials
import Test.QuickCheck
import Simplex
import Spaces
import qualified Numeric.LinearAlgebra.HMatrix as M

newtype V3 = V3 [Double] deriving Show
newtype S3 = S3 (Simplex [Double]) deriving Show


-- | Generate arbitrary polyhedron with non-zero vertices
instance Arbitrary (Simplex [Double]) where
    arbitrary = do
      ls <- infiniteListOf ((vector 3) `suchThat` (not . ([0,0,0] ==)))
      let l1 = head $ dropWhile (all (0==)) ls
          l2 = head $ dropWhile (not . (linearIndep' [l1])) ls
          l3 = head $ dropWhile (not . (linearIndep' [l1,l2])) ls
          l4 = head $ (drop 3 ls)
      return $ Simplex [l1,l2,l3,l4]


-- | Test list of vectors for linear independence
linearIndep :: (VectorSpace v, (Fieldf v) ~ Double)  => [v] -> Bool
linearIndep vs = m == (M.rank a)
    where m = length vs
          n = vspaceDim (vs !! 0)
          a = (m M.>< n) (concat (map toList vs))

linearIndep' :: [[Double]] -> [Double] -> Bool
linearIndep' vs v = linearIndep (v:vs)

-- | Defining property of barycentric coordinates: The barycentric coordinate
-- | function lambda_i takes value 1 on the vertex x_i of the simplex and 0 on
-- | all other vertices.
prop_barycentric :: Simplex [Double] -> Bool
prop_barycentric s@(Simplex l) = all equalsDelta [0..n]
    where n = topologicalDimension s
          equalsDelta i = all (\j -> (lambda i (l!!j)) `eqNum` delta i j) [0..n]
          lambda i = evalP (barycentricCoord s i)


delta :: Int -> Int -> Double
delta i j
      | i == j = 1
      | otherwise = 0

-- | Numerical equality accounting for round-off errors
eqNum :: Double -> Double -> Bool
eqNum a b = (abs (a - b) < 2e-13)