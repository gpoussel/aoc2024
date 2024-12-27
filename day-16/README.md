# Day 16: Haskell

## Development

```
docker run -it --name aoc --rm -w /code -v %cd%:/code:ro haskell:9 bash
```

Then, in the image, run `stack script solve.hs --resolver lts-23.1 --package heaps --package containers --package array --package lens`. The first launch take forever!

## Launching

```
docker run --name aoc --rm -w /code -v %cd%:/code:ro haskell:9 stack script solve.hs --resolver lts-23.1 --package heaps --package containers --package array --package lens
```
