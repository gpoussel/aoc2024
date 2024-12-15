
part1 = do
  integers <- (map read) . lines <$> readFile "example" :: IO [Integer]
  return $ sum integers

  
part2 = do
  integers <- (map read) . lines <$> readFile "example" :: IO [Integer]
  return $ sum integers

main :: IO ()
main = do
  putStr "Part 1: "
  part1 >>= print
  putStr "Part 2: "
  part2 >>= print
