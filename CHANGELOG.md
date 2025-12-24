# CHANGELOG

## 0.1.0

- Initial public release of `phlex.ex`
- Component-based architecture for building HTML, SVG, and other markup views in Elixir
- Core modules: `Phlex`, `Phlex.SGML`, `Phlex.HTML`, `Phlex.SVG`
- Explicit state passing for functional programming style with clear data flow
- Phoenix and Phoenix LiveView integration via `Phlex.Phoenix`
- StyleCapsule integration helper via `Phlex.StyleCapsule`
- Attribute caching with FIFO cache store for improved performance
- Fragment support for selective rendering and conditional content
- Safe content handling with `SafeValue` and `SafeObject` protocol
- Comprehensive HTML element support (standard elements, void elements, SVG elements)
- Block support with content yielding
- Helper functions for common HTML patterns
- Comprehensive test suite with 279 tests
- Quality assurance: Credo, Dialyzer, ExCoveralls
- Example applications: Phoenix demo and standalone examples
- Elixir >= 1.18 requirement

