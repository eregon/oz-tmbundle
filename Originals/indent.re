{	decreaseIndentPattern = '(?x)
  (
    ^\s*(end|else|elseif|in|define)\b
  )';
	increaseIndentPattern = '(?x)^\s*
    (
      \b(class|proc|fun|local|import
      |if|else|elseif|for|in
      |case)\b
      (?!.*?\bend\b)
    )
    .*$';
}