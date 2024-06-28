module Main where
import Control.Applicative
import Data.Char
import Data.Maybe

data JsonValue = JsonNull
               | JsonBool Bool
               | JsonNumber Integer               -- Not spec compliant as only positive integers are supported
               | JsonString String                -- Not spec compliant as escapes are not supported
               | JsonArray [JsonValue]
               | JsonObject [(String, JsonValue)]
               deriving (Show, Eq)

newtype Parser a = Parser
  { runParser :: String -> Maybe (String, a)
  }

instance Functor Parser where
  fmap f (Parser p) = Parser $ \input -> do
    (input', x) <- p input
    Just (input', f x)

instance Applicative Parser where
  pure x = Parser $ \input -> Just (input, x)
  (Parser p1) <*> (Parser p2) = Parser $ \input -> do
    (input', f) <- p1 input
    (input'', a) <- p2 input'
    Just (input'', f a)

instance Alternative Parser where
  empty = Parser $ \_ -> Nothing
  (Parser p1) <|> (Parser p2) = Parser $ \input -> p1 input <|> p2 input 

charP :: Char -> Parser Char
charP c = Parser $ \input ->
                     case input of
                       first:rest | first == c -> Just (rest, c)
                       _ -> Nothing

stringP :: String -> Parser String
stringP = sequenceA . map charP

spanP :: (Char -> Bool) -> Parser String
spanP f = Parser $ \input -> let (token, rest) = span f input
                             in Just (rest, token)
ws :: Parser String
ws = spanP isSpace

sepBy :: Parser a -> Parser b -> Parser [b]
sepBy sep element = (:) <$> element <*> many (sep *> element)
                    <|> pure []

notNull :: Parser [a] -> Parser [a]
notNull (Parser p) = Parser $ \input -> do
                       (input', xs) <- p input
                       if null xs
                         then Nothing
                         else Just (input', xs)

jsonNull :: Parser JsonValue
jsonNull = (\_ -> JsonNull) <$>  stringP "null"

jsonBool :: Parser JsonValue
jsonBool = ((\_ -> JsonBool True) <$> stringP "true") <|> ((\_ -> JsonBool False) <$>  stringP "false")

jsonNumber :: Parser JsonValue
jsonNumber = JsonNumber . read <$> notNull (spanP isDigit)

jsonString :: Parser JsonValue
jsonString = JsonString <$> (charP '"' *> (spanP (/= '"')) <* charP '"')

jsonArray :: Parser JsonValue
jsonArray = JsonArray <$> (charP '[' *> ws *> elements <* ws <* charP ']')
  where elements = sepBy (ws *> charP ',' <* ws) jsonValue

jsonObject :: Parser JsonValue
jsonObject = JsonObject <$> (charP '{' *> ws *> pairs <* ws <* charP '}')
  where pairs = sepBy (ws *> charP ',' <* ws) pair
        pair = (\(JsonString key) _ value -> (key, value)) <$> jsonString <*> (ws *> charP ':' <* ws) <*> jsonValue

jsonValue :: Parser JsonValue
jsonValue = jsonNull <|> jsonBool <|> jsonNumber <|> jsonString <|> jsonArray <|> jsonObject

main :: IO ()
main = do
  json <- getContents
  putStrLn (show (runParser jsonValue json))
