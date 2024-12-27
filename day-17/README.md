# Day 17: Rust

## Development

```
docker build -t aoc-day17 .
docker run -it --name aoc --rm -w /code -v %cd%:/code:ro aoc-day17 bash
```

Then, in the image, run `./solve.rs`

## Launching

```
docker build -t aoc-day17 . && docker run --name aoc --rm aoc-day17:latest
```
