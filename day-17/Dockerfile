FROM rust:1.83
COPY . /code
WORKDIR /code/
RUN cargo install rust-script
CMD ["./solve.rs"]
