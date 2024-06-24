main :: IO ()
main = do
  putStrLn "Hello, everybody!"
  putStrLn ("Please look at my favorite odd numbers: " ++ show (filter odd [10..20] :: [Integer]))
  putStrLn ("And my favorite even numbers: " ++ show (take 10 (filter even [854..]) :: [Integer]))
  
