{	decreaseIndentPattern = '(?x)
  (
    ^\s*(
      (end|else|elseif|in|define)\b
    |
      # case .. of nil then .. (brackets) H|T then
      \bof\snil\s+then\b|\[\]\s\w+\|\w+\sthen
    )
  )';
	increaseIndentPattern = '(?x)^\s*
    (
      \b(
        class|proc|fun|local|import
        |if|else|elseif|for|in
        |case
      )\b(?!.*?\bend\b)
    |
      # case .. of nil then .. (brackets) H|T then
      \bof\snil\s+then\b|\[\]\s\w+\|\w+\sthen
    )
    .*$';
}