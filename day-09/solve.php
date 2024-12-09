<?php

$input = trim(file_get_contents('input'));

class Block {
    public $id;
    public $size;

    public function __construct($size, $id = null) {
        $this->id = $id;
        $this->size = $size;
    }

    public function isEmpty() {
        return is_null($this->id);
    }
}

$blocks = [];
$id = 0;
$empty = false;
foreach (str_split($input) as $char) {
    if ($char !== '0') {
        if ($empty) {
            $block = new Block(intval($char));
        } else {
            $block = new Block( intval($char), $id);
        }
        $blocks[] = $block;
    }
    $empty = !$empty;
    if ($empty) {
        $id++;
    }
}

function organize_blocks(&$blocks, $can_append_partial) {
    print_blocks($blocks);
    $moved = true;
    $last_sorted_index = count($blocks) - 1;
    while ($moved) {
        $moved = false;
        for ($i = $last_sorted_index; $i >= 0 && !$moved; $i--) {
            $block_to_move = $blocks[$i];
            if ($block_to_move->isEmpty()) {
                continue;
            }
            for ($j = 0; $j < $i; $j++) {
                $block = $blocks[$j];
                if ($block->isEmpty()) {
                    // If blocks have the same size, we can move the block to the empty block
                    if ($block_to_move->size === $block->size) {
                        $block->id = $block_to_move->id;
                        $block_to_move->id = null;
                        $moved = true;
                        $last_sorted_index = $i;
                        break;
                    } else if ($block_to_move->size < $block->size) {
                        // If the block to move is smaller than the empty block
                        array_splice($blocks, $j, 0, [
                            clone $block_to_move
                        ]);
                        $block->size -= $block_to_move->size;
                        $block_to_move->id = null;
                        $moved = true;
                        $last_sorted_index = $i;
                        break;
                    } else if ($can_append_partial && $block_to_move->size > $block->size) {
                        $block_to_move->size -= $block->size;
                        $block->id = $block_to_move->id;
                        array_splice($blocks, $i + 1, 0, [
                            new Block($block->size)
                        ]);
                        $last_sorted_index = $i;
                        continue;
                    }
                }
                print_blocks($blocks);
            }
            if ($moved) {
                continue;
            }
        }
    }
}

function print_blocks($blocks) {
    if (count($blocks) > 30) {
        return;
    }
    $output = '';
    foreach ($blocks as $block) {
        for ($i = 0; $i < $block->size; $i++) {
            $output .= $block->isEmpty() ? '.' : $block->id;
        }
    }
    print_r($output . PHP_EOL);
}

function compute_checksum($blocks) {
    $checksum = 0;
    $index = 0;
    for ($i = 0; $i < count($blocks); $i++) {
        $block = $blocks[$i];
        for ($j = 0; $j < $block->size; $j++) {
            if (!$block->isEmpty()) {
                $checksum += $index * $block->id;
            }
            $index++;
        }
    }
    return $checksum;
}

$blocks_part1 = array_map(function($block) {
    return clone $block;
}, $blocks);
organize_blocks($blocks_part1, true);
print_r("Part 1: " . compute_checksum($blocks_part1) . PHP_EOL);

$blocks_part2 = array_map(function($block) {
    return clone $block;
}, $blocks);
organize_blocks($blocks_part2, false);
print_r("Part 2: " . compute_checksum($blocks_part2) . PHP_EOL);
