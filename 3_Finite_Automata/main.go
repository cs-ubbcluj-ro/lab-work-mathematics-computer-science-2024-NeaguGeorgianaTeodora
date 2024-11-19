package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

// FiniteAutomaton represents a finite automaton
type FiniteAutomaton struct {
	States      []string
	Alphabet    []string
	Transitions map[string]map[string]string
	FinalStates []string
}

// LoadFA loads the finite automaton from a file
func LoadFA(filename string) (*FiniteAutomaton, error) {
	file, err := os.Open(filename)
	if err != nil {
		return nil, err
	}
	defer file.Close()

	fa := &FiniteAutomaton{
		Transitions: make(map[string]map[string]string),
	}

	scanner := bufio.NewScanner(file)
	mode := ""

	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if line == "" {
			continue
		}

		switch {
		case strings.HasPrefix(line, "States:"):
			mode = "States"
			fa.States = strings.Fields(line[len("States:"):])
		case strings.HasPrefix(line, "Alphabet:"):
			mode = "Alphabet"
			fa.Alphabet = strings.Fields(line[len("Alphabet:"):])
		case strings.HasPrefix(line, "Transitions:"):
			mode = "Transitions"
		case strings.HasPrefix(line, "Final States:"):
			mode = "Final States"
			fa.FinalStates = strings.Fields(line[len("Final States:"):])
		default:
			if mode == "Transitions" {
				parts := strings.Split(line, "->")
				if len(parts) != 3 {
					return nil, fmt.Errorf("invalid transition format: %s", line)
				}
				start := strings.TrimSpace(parts[0])
				symbol := strings.TrimSpace(parts[1])
				end := strings.TrimSpace(parts[2])

				if _, exists := fa.Transitions[start]; !exists {
					fa.Transitions[start] = make(map[string]string)
				}
				fa.Transitions[start][symbol] = end
			}
		}
	}

	if err := scanner.Err(); err != nil {
		return nil, err
	}

	return fa, nil
}

// DisplayFA prints the finite automaton
func (fa *FiniteAutomaton) DisplayFA() {
	fmt.Println("States:", fa.States)
	fmt.Println("Alphabet:", fa.Alphabet)
	fmt.Println("Transitions:")
	for start, symbols := range fa.Transitions {
		for symbol, end := range symbols {
			fmt.Printf("  %s -> %s -> %s\n", start, symbol, end)
		}
	}
	fmt.Println("Final States:", fa.FinalStates)
}

// IsValidToken checks if a given string is a valid token
func (fa *FiniteAutomaton) IsValidToken(input string) bool {
	currentState := fa.States[0] // Assume the first state is the start state

	for _, char := range input {
		symbol := string(char)
		if nextState, exists := fa.Transitions[currentState][symbol]; exists {
			currentState = nextState
		} else {
			return false
		}
	}

	for _, finalState := range fa.FinalStates {
		if currentState == finalState {
			return true
		}
	}
	return false
}

func main() {
	filename := "FA.in"
	fa, err := LoadFA(filename)
	if err != nil {
		fmt.Println("Error loading FA:", err)
		return
	}

	fa.DisplayFA()

	// Bonus: Check if a given string is a valid lexical token
	fmt.Println("Enter a string to check if it's a valid token:")
	var input string
	fmt.Scanln(&input)

	if fa.IsValidToken(input) {
		fmt.Println("The string is a valid lexical token.")
	} else {
		fmt.Println("The string is not a valid lexical token.")
	}
}
