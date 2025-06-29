/* AI: Vector Utility Functions - VECTORPROPERTY */

-- Discover the dimensions and base type of the vector with VECTORPROPERTY
SELECT
  VectorDemoId,
  RawVector,
  Dimensions = VECTORPROPERTY(RawVector, 'Dimensions'),
  BaseType   = VECTORPROPERTY(RawVector, 'BaseType')
FROM
  VectorDemo
