# Phlex Benchmarks

Performance benchmarks for Phlex operations.

## Running Benchmarks

```bash
# Run all benchmarks
mix bench

# Run specific benchmark
mix bench html_rendering
```

## Benchmark Suites

- **HTML Rendering**: Measures HTML component rendering performance
- **SVG Rendering**: Measures SVG component rendering performance
- **Attribute Generation**: Measures attribute string generation
- **Component Composition**: Measures nested component performance

## Output

Benchmark results are generated as HTML reports in `benchmarks/output/`.

