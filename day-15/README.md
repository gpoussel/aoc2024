# Day 15: C

## Development

```
docker run -it --name aoc --rm -w /code -v %cd%:/code:ro gcc:latest bash
```

Then, in the image, run `gcc -o /tmp/solve solve.c && /tmp/solve`

## Launching

```
docker build -t aoc-day15 . && docker run --name aoc --rm aoc-day15:latest
```
