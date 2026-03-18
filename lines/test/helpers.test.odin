package lines_test

import "../../pos"
import tok "../../tokenizer"
import "../src"
import "core:fmt"
import "core:log"
import "core:testing"

@(test)
test_move_to_start_of_line :: proc(t: ^testing.T) {
	source := "123\n456\n789"
	to := src.create_tokenizer(source)

	// Move to middle of first line
	tok.advance(&to) // at '2'
	testing.expect_value(t, to.index, 1)
	src.move_to_start_of_line(&to)
	testing.expect_value(t, to.index, 0)
	testing.expect_value(t, to.current, '1')

	// Move to middle of second line
	src.advance(&to) // at '4'
	tok.advance(&to) // at '5'
	testing.expect_value(t, to.index, 5)
	src.move_to_start_of_line(&to)
	testing.expect_value(t, to.index, 4)
	testing.expect_value(t, to.current, '4')

	// Move to start of line when already at start
	src.move_to_start_of_line(&to)
	testing.expect_value(t, to.index, 4)
	testing.expect_value(t, to.current, '4')

	// Move to start of file when already at start
	to_start := src.create_tokenizer(source)
	src.move_to_start_of_line(&to_start)
	testing.expect_value(t, to_start.index, 0)
	testing.expect_value(t, to_start.current, '1')
}

@(test)
test_move_to :: proc(t: ^testing.T) {
	source := "123\n456\n789\n"
	to := src.create_tokenizer(source)

	src.move_to(&to, 5)
	testing.expect_value(t, to.index, 4)

	to2 := src.create_tokenizer(source)
	src.move_to(&to2, 8)
	testing.expect_value(t, to2.index, 8)
}

@(test)
test_get_span_lines :: proc(t: ^testing.T) {
	source := "1\n2\n3\n4\n5\n6\n7"

	// Span from '3' (index 4) to '5' (index 8)
	// With 1 before and 1 after, we want lines "2", "3", "4", "5", "6"
	span := pos.Span{4, 8}

	options := src.Span_Lines_Opts {
		before = 1,
		after  = 1,
	}

	lines, _ := src.get_span_lines(source, span, options)
	defer delete(lines)
	testing.expect_value(t, len(lines), 5)
	if len(lines) == 5 {
		testing.expect_value(t, lines[0].index, 1) // line "2"
		testing.expect_value(t, lines[1].index, 2) // line "3"
		testing.expect_value(t, lines[2].index, 3) // line "4"
		testing.expect_value(t, lines[3].index, 4) // line "5"
		testing.expect_value(t, lines[4].index, 5) // line "6"
	}
}

@(test)
test_get_span_lines_bounds :: proc(t: ^testing.T) {
	source := "1\n2\n3"
	span := pos.Span{2, 2} // At '2' (line index 1)

	options := src.Span_Lines_Opts {
		before = 5, // more than available
		after  = 5, // more than available
	}

	lines, _ := src.get_span_lines(source, span, options)
	defer delete(lines)

	testing.expect_value(t, len(lines), 3)
	if len(lines) == 3 {
		testing.expect_value(t, lines[0].index, 0)
		testing.expect_value(t, lines[1].index, 1)
		testing.expect_value(t, lines[2].index, 2)
	}
}


@(test)
test_highline_span :: proc(t: ^testing.T) {
	source := fmt.tprintln(
		"ab", //
		"bc",
		"cd",
		"de",
		"ef",
		"fg",
		"gh",
		sep = "\n",
	)
	span := pos.Span{3, 7}

	lines := src.highlight_span(source, span)
	defer delete(lines)
	defer free_all(context.temp_allocator)

	expected := fmt.tprintln(
		"   1│ ab",
		" > 2│ bc",
		"    │ ^^",
		" > 3│ cd",
		"    │ ^ ",
		"   4│ de",
		sep = "\n",
	)

	testing.expect_value(t, lines, expected)
}
