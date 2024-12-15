FROM gcc:latest
COPY . /code
WORKDIR /code/
RUN gcc -o solve solve.c
CMD ["./solve"]
