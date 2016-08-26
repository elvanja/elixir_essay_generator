# Trigram Essay Generator

An educational project intended to study Elixir.  
Can analyze some text and generate a new text based on it.

Uses the idea behind Markov chains:  
https://blog.codinghorror.com/markov-and-you/  
https://en.wikipedia.org/wiki/Trigram

Try it:
```
iex> File.read!("mysterious_affair_at_styles_by_agatha_christie.txt") \
      |> TrigramAnalyzer.analyze \
      |> EssayGenerator.generate
```

# TODO

## Use a custom structure for analysis and frequency results

## Make it work across workers
Let it distribute work across distributed machines (pun intended).

## Analyze stream in real time
Accept a stream, e.g. a hot Twitter topic, and analyze in real-time.  
Generate random tweets related the input.  
