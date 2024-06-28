pow :: Integer -> Integer -> Integer
pow a b = b ^ a

square = pow 2
cube = pow 3

main :: IO ()
main = do
  putStrLn "Hello, everybody!"
  putStrLn ("Please look at my favorite odd numbers: " ++ show (filter odd [10..20] :: [Integer]))
  putStrLn ("And my favorite even numbers: " ++ show (take 10 (filter even [854..]) :: [Integer]))
  putStrLn ("The square of 5 is " ++ show (square 5))
  putStrLn ("The cube of 5 is " ++ show (cube 5))
