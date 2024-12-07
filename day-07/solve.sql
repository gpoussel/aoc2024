CREATE TABLE raw_input (line TEXT);
-- \copy raw_input from '/docker-entrypoint-initdb.d/example' with delimiter ',' csv
\copy raw_input from '/docker-entrypoint-initdb.d/input' with delimiter ',' csv

SELECT
    ROW_NUMBER() OVER () AS line_number,
    LEFT(line, POSITION(':' in line) - 1)::bigint AS target INTO target_numbers
FROM
    raw_input;

SELECT
    t.line_number,
    t.array_numbers INTO operand_numbers
FROM
    (
        SELECT
            ROW_NUMBER() OVER () AS line_number,
            STRING_TO_ARRAY(
                RIGHT(line, LENGTH(line) - POSITION(':' in line) -1),
                ' '
            )::bigint[] AS array_numbers
        FROM
            raw_input
    ) AS t;

WITH RECURSIVE
    cte AS (
        SELECT
            line_number,
            1 AS position,
            false AS completed,
            array_numbers[1] AS result
        FROM operand_numbers
        UNION ALL
        (SELECT
            cte.line_number,
            cte.position + 1 AS position,
            cte.position + 1 = ARRAY_LENGTH(array_numbers, 1) AS completed,
            UNNEST(ARRAY[cte.result * array_numbers[cte.position + 1], cte.result + array_numbers[cte.position + 1]]) AS result
        FROM operand_numbers
        JOIN cte
        ON cte.position + 1 <= ARRAY_LENGTH(array_numbers, 1)
        AND cte.line_number = operand_numbers.line_number
        )
    ),
    matching_results AS (
        SELECT DISTINCT cte.line_number, result
        FROM cte
        JOIN target_numbers ON target_numbers.line_number = cte.line_number
        AND target_numbers.target = cte.result
        WHERE completed
    )
SELECT FORMAT('Part 1: %s', SUM(matching_results.result))
FROM matching_results;

WITH RECURSIVE
    cte AS (
        SELECT
            line_number,
            1 AS position,
            false AS completed,
            array_numbers[1] AS result
        FROM operand_numbers
        UNION ALL
        (SELECT
            cte.line_number,
            cte.position + 1 AS position,
            cte.position + 1 = ARRAY_LENGTH(array_numbers, 1) AS completed,
            UNNEST(ARRAY[cte.result * array_numbers[cte.position + 1], cte.result + array_numbers[cte.position + 1], FORMAT('%s%s', cte.result, array_numbers[cte.position + 1])::bigint]) AS result
        FROM operand_numbers
        JOIN cte
        ON cte.position + 1 <= ARRAY_LENGTH(array_numbers, 1)
        AND cte.line_number = operand_numbers.line_number
        )
    ),
    matching_results AS (
        SELECT DISTINCT cte.line_number, result
        FROM cte
        JOIN target_numbers ON target_numbers.line_number = cte.line_number
        AND target_numbers.target = cte.result
        WHERE completed
    )
SELECT FORMAT('Part 2: %s', SUM(matching_results.result))
FROM matching_results;

