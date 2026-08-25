# HTML parser authority includes the tree sink

When a PR derives browser-visible metadata from HTML, a tokenizer, selector engine, or element callback is not automatically a browser-semantics authority. Namespace correctness depends on the HTML tree builder and on the sink preserving parser-owned facts such as MathML `annotation-xml` integration points.

Before approving an extraction design, test the exact dependency and public API against a small namespace/lifecycle matrix:

- direct SVG and MathML elements with the same local name as the HTML target;
- HTML descendants of SVG `foreignObject` and MathML `annotation-xml` with an HTML encoding;
- a foreign-content exit tag followed by the target element;
- malformed or implicitly closed foreign content followed by the target element;
- character-reference decoding and normalization order.

Do not infer correctness from a crate's browser-grade description alone. A DOM wrapper can use a conforming tree builder while its `TreeSink` omits a parser flag and still produce the wrong namespace on an edge case. Likewise, a streaming rewriter can expose a namespace value after an approximation has already crossed an integration point. Validate observed `QualName` namespaces and derived output, not only that parsing succeeds.

The smallest safe ownership boundary is usually:

1. a maintained parser plus sink owns tree construction, namespaces, integration points, foreign exits, and implicit close behavior;
2. application code traverses tree order and accepts only the exact namespace/local-name pair;
3. application code applies display normalization and truncation after parser text/entity decoding.

Do not copy a parser's private tree-builder simulator, foreign-exit tag list, namespace stack, or implicit-close lifecycle into application code. If the only correct public API materializes a DOM, treat the dependency and bounded transient-memory increase as an explicit architecture delta. Compare feature removal and unsupported test-DOM dependencies, then obtain delta-specific approval before implementation.

Version-specific observation from 2026-08: `lol_html 3.0.1` public element namespace reporting was insufficient for direct SVG `title`; `scraper 0.27.0` did not preserve the MathML `annotation-xml` integration-point flag in its sink; `dom_query 0.28.0` with `html5ever 0.39.0` preserved the tested namespace/lifecycle matrix. Re-run the matrix before reusing these package conclusions because dependency behavior can change.
