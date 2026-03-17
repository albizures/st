package lines_core

import "../../pos"
import tok "../../tokenizer"
import "core:log"


Line_Error :: enum {
	None,
	Already_At_End,
	Already_At_Start,
}

Line :: struct {
	using span: pos.Span,
	index:      int,
}

Tokenizer :: struct {
	using tok: tok.Tokenizer,
	line:      int,
}

create_tokenizer :: proc(source: string) -> Tokenizer {
	return Tokenizer{tok = tok.create(source)}
}

get_lines :: proc(source: string, allocator := context.allocator) -> [dynamic]Line {
	t := create_tokenizer(source)

	start := 0
	lines := make([dynamic]Line, allocator)

	for {
		line, err := advance(&t)
		if err == .None {
			append(&lines, line)
		} else {
			break
		}

		if tok.is_eof(t) {
			break
		}
	}

	return lines
}


advance :: proc(t: ^Tokenizer) -> (line: Line, err: Line_Error) {
	if tok.is_eof(t^) {
		err = .Already_At_End
		return
	}

	// if we are not at the start of a line, skip to the next newline
	if t^.index != 0 && tok.get_prev(t) != '\n' {
		for {
			if tok.is_eof(t^) {
				err = .Already_At_End
				return
			}

			if t.current == '\n' {
				t.line += 1
				tok.advance(t)
				break
			}

			tok.advance(t)
		}
	}

	start := t.index
	for {
		if t.current == '\n' || tok.is_eof(t^) {
			t.line += 1

			break
		}

		tok.advance(t)
	}

	line = {
		span  = {start, t.index},
		index = t.line - 1,
	}

	tok.advance(t) // advance the newline

	return
}

rollback :: proc(t: ^Tokenizer) -> (line: Line, err: Line_Error) {
	if t.index == 0 {
		err = .Already_At_Start
		return
	}

	end := -1

	// rollback to the end of the previous line
	for { 	// in this way we can support the tokenizer to in the middle of a line`
		if t.current == '\n' {
			end = t.index
			tok.rollback(t)
			break
		}
		tok.rollback(t)
	}

	if end == -1 {
		// reached the start of the file, can't rollback further
		err = .Already_At_Start
		return
	}

	for {
		if t.current == '\n' || t.index == 0 {
			t.line -= 1
			if t.current == '\n' {
				tok.advance(t) // advance the newline so it's not included
			}

			break
		}

		tok.rollback(t)
	}

	line = {
		span  = {t.index, end},
		index = t.line,
	}

	return
}
