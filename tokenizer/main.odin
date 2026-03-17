package tokenizer

import "src"


CUSTOM_OFFSET :: src.CUSTOM_OFFSET

// structs
Tokenizer :: src.Tokenizer
Kind :: src.Kind
Token :: src.Token

// procs
create :: proc {
	src.create_tokenizer,
}
advance :: proc {
	src.advance_rune,
}
rollback :: proc {
	src.rollback_rune,
}
is_eof :: src.is_eof
get_value :: proc {
	src.get_value_from_tokenizer,
	src.get_value_from_source,
}
get_prev :: src.get_prev
move_to :: src.move_to
