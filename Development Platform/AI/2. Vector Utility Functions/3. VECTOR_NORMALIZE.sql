/* AI: Vector Utility Functions - VECTOR_NORMALIZE */

-- Normalize the vectors with VECTOR_NORMALIZE (i.e., rescale to magnitude of 1)
SELECT
  VectorDemoId,
  RawVector,
  NormalizedNorm1   = VECTOR_NORMALIZE(RawVector, 'norm1'),
  NormalizedNorm2   = VECTOR_NORMALIZE(RawVector, 'norm2'),
  NormalizedNormInf = VECTOR_NORMALIZE(RawVector, 'norminf')
FROM
  VectorDemo

-- Verify the normalization by computing the magnitude of the normalized vectors and confirming they are 1
SELECT
  VectorDemoId,
  RawVector,
  NormalizedNorm1   = VECTOR_NORM(VECTOR_NORMALIZE(RawVector, 'norm1'), 'norm1'),
  NormalizedNorm2   = VECTOR_NORM(VECTOR_NORMALIZE(RawVector, 'norm2'), 'norm2'),
  NormalizedNormInf = VECTOR_NORM(VECTOR_NORMALIZE(RawVector, 'norminf'), 'norminf')
FROM
  VectorDemo
