#!/usr/bin/env rust-script

use std::collections::HashMap;

#[derive(Debug)]
struct Computer {
    registers: HashMap<Register, u64>,
    program: Vec<(Instruction, Operand)>,
    pc: i64,
    output: Vec<u64>,
}

#[derive(Debug)]
enum Instruction {
    ADV,
    BXL,
    BST,
    JNZ,
    BXC,
    OUT,
    BDV,
    CDV,
}

impl From<u64> for Instruction {
    fn from(value: u64) -> Self {
        match value {
            0 => Instruction::ADV,
            1 => Instruction::BXL,
            2 => Instruction::BST,
            3 => Instruction::JNZ,
            4 => Instruction::BXC,
            5 => Instruction::OUT,
            6 => Instruction::BDV,
            7 => Instruction::CDV,
            _ => panic!("Unknown instruction"),
        }
    }
}

#[derive(Debug, Clone, Copy, Hash, Eq, PartialEq)]
enum Register {
    A,
    B,
    C,
}

#[derive(Debug)]
enum Operand {
    LITERAL(u64),
    REGISTER(Register),
    _RESERVED,
}

impl Computer {
    fn next(&mut self) {
        let p = self.program.get(self.pc as usize).unwrap();

        let o = match p.1 {
            Operand::LITERAL(value) => value,
            Operand::REGISTER(register) => *self.registers.get(&register).unwrap(),
            Operand::_RESERVED => panic!("Reserved operand"),
        };

        let a = *self.registers.get(&Register::A).unwrap();
        let b = *self.registers.get(&Register::B).unwrap();
        let c = *self.registers.get(&Register::C).unwrap();

        match p.0 {
            Instruction::ADV => {
                self.registers.insert(Register::A, a >> o);
            }
            Instruction::BXL => {
                self.registers.insert(Register::B, b ^ o);
            }
            Instruction::BST => {
                self.registers.insert(Register::B, o & 0b111);
            }
            Instruction::JNZ => {
                if a != 0 {
                    self.pc = (o as i64 / 2) - 1;
                }
            }
            Instruction::BXC => {
                self.registers.insert(Register::B, b ^ c);
            }
            Instruction::OUT => {
                self.output.push(o & 0b111);
            }
            Instruction::BDV => {
                self.registers.insert(Register::B, a >> o);
            }
            Instruction::CDV => {
                self.registers.insert(Register::C, a >> o);
            }
        };
        self.pc += 1;
    }

    fn is_running(&mut self) -> bool {
        self.pc < (self.program.len() as i64)
    }

    fn run(&mut self) -> &Vec<u64> {
        while self.is_running() {
            self.next();
        }
        &self.output
    }
}

fn main() {
    let input = include_str!("input");
    let parts = input.split("\n\n").collect::<Vec<&str>>();
    let registers = parts[0]
        .lines()
        .fold(HashMap::new(), |mut registers, line| {
            let mut parts = line.split(": ");
            let name = parts.next().unwrap().split(" ").skip(1).next().unwrap();
            let value = parts.next().unwrap().parse::<u64>().unwrap();

            let register = match name {
                "A" => Register::A,
                "B" => Register::B,
                "C" => Register::C,
                _ => panic!("Unknown register"),
            };
            registers.insert(register, value);
            registers
        });

    let program = parts[1]
        .split(": ")
        .skip(1)
        .next()
        .unwrap()
        .split(",")
        .map(|digits| digits.parse::<u64>().unwrap())
        .collect::<Vec<u64>>()
        .chunks(2)
        .map(|chunk| {
            let instruction = chunk[0].into();

            let is_combo = match instruction {
                Instruction::ADV => true,
                Instruction::BXL => false,
                Instruction::BST => true,
                Instruction::JNZ => false,
                Instruction::BXC => false,
                Instruction::OUT => true,
                Instruction::BDV => true,
                Instruction::CDV => true,
            };

            let operand = match (is_combo, chunk[1]) {
                (true, 4) => Operand::REGISTER(Register::A),
                (true, 5) => Operand::REGISTER(Register::B),
                (true, 6) => Operand::REGISTER(Register::C),
                (true, _) => Operand::LITERAL(chunk[1]),
                (false, _) => Operand::LITERAL(chunk[1]),
            };

            (instruction, operand)
        })
        .collect::<Vec<(Instruction, Operand)>>();

    let mut computer = Computer {
        registers,
        program,
        pc: 0,
        output: Vec::new(),
    };

    let output = computer.run();
    // Join output into a string
    let part1 = output.iter().map(|x| x.to_string()).collect::<Vec<String>>().join(",");
    println!("Part 1: {}", part1);

    let mut needle = 0;
    let expected_output = vec![ 2,4,1,1,7,5,1,5,4,0,5,5,0,3,3,0 ];

    let mut done = false;
    loop {
        for j in 0..0xFFFFFFFF {
            computer.registers.insert(Register::A, j + needle);
            computer.registers.insert(Register::B, 0);
            computer.registers.insert(Register::C, 0);
            computer.pc = 0;
            computer.output.clear();
            let actual_output = computer.run();
            let mut all_fields_good_so_far = true;

            for k in 0..actual_output.len() {
                if expected_output[expected_output.len() - k - 1]
                    != actual_output[actual_output.len() - k - 1]
                {
                    all_fields_good_so_far = false;
                    break;
                }
            }

            if all_fields_good_so_far {
                if expected_output.len() == actual_output.len() {
                    done = true;
                    println!("Part 2: {}", j + needle);
                }
                needle = (needle + j) << 3;
                break;
            }
        }
        if done {
            break;
        }
    }
}
