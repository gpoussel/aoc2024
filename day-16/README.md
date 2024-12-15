# Day 16: Haskell

## Development

```
docker run -it --name aoc --rm -w /code -v %cd%:/code:ro haskell:9 bash
```

Then, in the image, run `stack script solve.hs --resolver lts-17.14`

## Launching

```
docker run --name aoc --rm -w /code -v %cd%:/code:ro haskell:9 stack script solve.hs --resolver lts-17.14
```
