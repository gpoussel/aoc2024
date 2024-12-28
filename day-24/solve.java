import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;
import java.util.stream.Stream;
import java.util.TreeMap;

public class Day24 {

    protected Day24(final String filename) {
		final List<String> input = getStringList(filename);

		final String output1 = runPart1(input);
		System.out.println("Part 1: " + output1);
		
		final String output2 = runPart2(input);
		System.out.println("Part 2: " + output2);
    }

	private List<String> getStringList(final String filename) {
		try (Stream<String> stream = Files.lines(Paths.get(filename))) {
			return stream.collect(Collectors.toList());
		} catch (final IOException e) {
			e.printStackTrace();
		}
		return new ArrayList<>();
	}

    private List<Gate> parseGates(final List<String> input) {
        final List<Gate> gates = new ArrayList<>();
        boolean startParsing = false;
        for (final String line : input) {
            if (startParsing) {
                final String wire = line.split("-> ")[1];
                final String gate = line.split(" ->")[0];
                gates.add(new Gate(gate, wire));
            }
            if (line.isBlank()) {
                startParsing = true;
            }
        }
        return gates;
    }

    private Map<String, Integer> parseValues(final List<String> input) {
        final Map<String, Integer> map = new TreeMap<>();
        for (final String line : input) {
            if (line.isBlank()) {
                break;
            }
            final String wire = line.split(":")[0];
            final int value = Integer.parseInt(line.split(": ")[1]);
            map.put(wire, value);
        }
        return map;
    }

    private void calculateFinalValues(final Map<String, Integer> values, final List<Gate> gates) {
        final List<String> wires = gates.stream().map(Gate::getOutputWire).collect(Collectors.toList());
        while (!values.keySet().containsAll(wires)) {
            for (final Gate c : gates) {
                final Optional<Integer> result = c.getResult(values);
                if (result.isPresent()) {
                    values.put(c.getOutputWire(), result.get());
                }
            }
        }
    }

    private long getNumber(final Map<String, Integer> values) {
        final List<String> zWires = values.keySet().stream().filter(k -> k.startsWith("z"))
                .collect(Collectors.toList());
        Collections.sort(zWires, Collections.reverseOrder());
        final StringBuilder sb = new StringBuilder();
        for (final String zWire : zWires) {
            sb.append(values.get(zWire));
        }
        return Long.parseLong(sb.toString(), 2);
    }

    private List<Gate> findFaultyGates(final List<Gate> gates) {
        final List<Gate> faultyGates = new ArrayList<>();
        for (final Gate c : gates) {
            if (c.getOutputWire().startsWith("z") && !c.getOutputWire().equals("z45")) {
                if (!c.getOperator().equals("XOR")) {
                    faultyGates.add(c);
                }
            } else if (!c.getOutputWire().startsWith("z")
                    && !(c.getOperand1().startsWith("x") || c.getOperand1().startsWith("y"))
                    && !(c.getOperand2().startsWith("x") || c.getOperand2().startsWith("y"))) {
                if (c.getOperator().equals("XOR")) {
                    faultyGates.add(c);
                }
            } else if (c.getOperator().equals("XOR")
                    && (c.getOperand1().startsWith("x") || c.getOperand1().startsWith("y"))
                    && (c.getOperand2().startsWith("x") || c.getOperand2().startsWith("y"))) {
                if (!(c.getOperand1().endsWith("00") && c.getOperand2().endsWith("00"))) {
                    final String output = c.getOutputWire();
                    boolean anotherFound = false;
                    for (final Gate c2 : gates) {
                        if (!c2.equals(c)) {
                            if ((c2.getOperand1().equals(output) || c2.getOperand2().equals(output))
                                    && c2.getOperator().equals("XOR")) {
                                anotherFound = true;
                                break;
                            }
                        }
                    }
                    if (!anotherFound) {
                        faultyGates.add(c);
                    }
                }
            } else if (c.getOperator().equals("AND")
                    && (c.getOperand1().startsWith("x") || c.getOperand1().startsWith("y"))
                    && (c.getOperand2().startsWith("x") || c.getOperand2().startsWith("y"))) {
                if (!(c.getOperand1().endsWith("00") && c.getOperand2().endsWith("00"))) {
                    final String output = c.getOutputWire();
                    boolean anotherFound = false;
                    for (final Gate c2 : gates) {
                        if (!c2.equals(c)) {
                            if ((c2.getOperand1().equals(output) || c2.getOperand2().equals(output))
                                    && c2.getOperator().equals("OR")) {
                                anotherFound = true;
                                break;
                            }
                        }
                    }
                    if (!anotherFound) {
                        faultyGates.add(c);
                    }
                }
            }
        }
        return faultyGates;
    }

    private String getOutput(final List<Gate> faultyGates) {
        Collections.sort(faultyGates);
        final StringBuilder sb = new StringBuilder();
        for (int i = 0; i < faultyGates.size(); i++) {
            sb.append(faultyGates.get(i).getOutputWire());
            if (i < faultyGates.size() - 1) {
                sb.append(",");
            }
        }
        return sb.toString();
    }

    protected String runPart2(final List<String> input) {
        final List<Gate> gates = parseGates(input);
        final List<Gate> faultyGates = findFaultyGates(gates);
        return getOutput(faultyGates);
    }

    protected String runPart1(final List<String> input) {
        final Map<String, Integer> values = parseValues(input);
        final List<Gate> gates = parseGates(input);
        calculateFinalValues(values, gates);
        return String.valueOf(getNumber(values));
    }

    public static void main(final String... args) {
        new Day24("input");
    }
}

class Gate implements Comparable<Gate> {

    private String outputWire;
    private final String operand1;
    private final String operand2;
    private final String operator;

    public Gate(final String gate, final String outputWire) {
        this.outputWire = outputWire;
        operand1 = gate.split(" ")[0];
        operand2 = gate.split(" ")[2];
        operator = gate.split(" ")[1];
    }

    public Gate(final String outputWire, final String operand1, final String operand2, final String operator) {
        this.outputWire = outputWire;
        this.operand1 = operand1;
        this.operand2 = operand2;
        this.operator = operator;
    }

    public Optional<Integer> getResult(final Map<String, Integer> values) {
        if (values.containsKey(operand1) && values.containsKey(operand2)) {
            switch (operator) {
                case "AND":
                    return Optional.of(values.get(operand1) & values.get(operand2));
                case "OR":
                    return Optional.of(values.get(operand1) | values.get(operand2));
                case "XOR":
                    return Optional.of(values.get(operand1) ^ values.get(operand2));
                default:
                    throw new IllegalArgumentException("Unknown operator: " + operator);
            }
        }
        return Optional.empty();
    }

    public String getOutputWire() {
        return outputWire;
    }

    public void setOutputWire(final String wire) {
        this.outputWire = wire;
    }

    public String getOperator() {
        return operator;
    }

    public String getOperand1() {
        return operand1;
    }

    public String getOperand2() {
        return operand2;
    }

    @Override
    public String toString() {
        return operand1 + " " + operator + " " + operand2 + " -> " + outputWire;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + ((outputWire == null) ? 0 : outputWire.hashCode());
        result = prime * result + ((operand1 == null) ? 0 : operand1.hashCode());
        result = prime * result + ((operand2 == null) ? 0 : operand2.hashCode());
        result = prime * result + ((operator == null) ? 0 : operator.hashCode());
        return result;
    }

    @Override
    public boolean equals(final Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (getClass() != obj.getClass())
            return false;
        final Gate other = (Gate) obj;
        if (outputWire == null) {
            if (other.outputWire != null)
                return false;
        } else if (!outputWire.equals(other.outputWire))
            return false;
        if (operand1 == null) {
            if (other.operand1 != null)
                return false;
        } else if (!operand1.equals(other.operand1))
            return false;
        if (operand2 == null) {
            if (other.operand2 != null)
                return false;
        } else if (!operand2.equals(other.operand2))
            return false;
        if (operator == null) {
            if (other.operator != null)
                return false;
        } else if (!operator.equals(other.operator))
            return false;
        return true;
    }

    @Override
    public int compareTo(final Gate o) {
        return this.getOutputWire().compareTo(o.getOutputWire());
    }

}
