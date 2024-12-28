# Day 18: C++

## Development

```
docker run -it --name aoc --rm -w /code -v %cd%:/code:ro gcc:latest bash
```

Then, in the image, run `g++ -o /tmp/solve solve.cpp && /tmp/solve`

## Launching

```
docker build -t aoc-day18 . && docker run --name aoc --rm aoc-day18:latest
```
