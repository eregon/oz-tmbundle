{	decreaseIndentPattern = '(?x)
  (
    ^\s*(
      (end|else|elseif|in|define)\b
      # case .. of nil then .. (brackets) H|T then
      |\bof\snil\sthen\b|\[\]\s\w\|\w\sthen
    )
  )';
	increaseIndentPattern = '(?x)^\s*
    (
      \b(
        class|proc|fun|local|import
        |if|else|elseif|for|in
        |case
      )\b
      # case .. of nil then .. (brackets) H|T then
      |\bof\snil\sthen\b|\[\]\s\w\|\w\sthen
      (?!.*?\bend\b)
    )
    .*$';
}