/* AI: Vector Utility Functions - VECTOR_NORM */

-- Compute the norm (aka "magnitude") of each vector with VECTOR_NORM
SELECT
  VectorDemoId,
  RawVector,
  Norm1   = VECTOR_NORM(RawVector, 'norm1'),
  Norm2   = VECTOR_NORM(RawVector, 'norm2'),
  NormInf = VECTOR_NORM(RawVector, 'norminf')
FROM
  VectorDemo
