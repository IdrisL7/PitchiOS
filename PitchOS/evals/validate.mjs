#!/usr/bin/env node

import { readFileSync } from "node:fs";
import { resolve } from "node:path";

const fixturePath = resolve(process.argv[2] ?? "generate-v1.json");
const resultPath = resolve(process.argv[3] ?? "baseline-v5.json");
const fixture = JSON.parse(readFileSync(fixturePath, "utf8"));
const result = JSON.parse(readFileSync(resultPath, "utf8"));
const expectations = new Map(fixture.cases.map((testCase) => [testCase.id, testCase.expect]));

const rows = result.cases.map((testCase) => {
  const expect = expectations.get(testCase.id);
  if (!expect) {
    return { id: testCase.id, pass: false, failures: ["missing fixture"] };
  }

  const output = testCase.output ?? "";
  const words = output.trim() ? output.trim().split(/\s+/u).length : 0;
  const missing = expect.required_strings.filter((value) => !output.includes(value));
  const forbidden = expect.forbidden_strings.filter((value) => output.includes(value));
  const missingPatterns = (expect.required_patterns ?? []).filter(
    (value) => !new RegExp(value, "iu").test(output),
  );
  const forbiddenPatterns = (expect.forbidden_patterns ?? []).filter(
    (value) => new RegExp(value, "iu").test(output),
  );
  const failures = [];

  if (testCase.status !== 200) failures.push(`HTTP ${testCase.status ?? "missing"}`);
  if (!testCase.content_type?.toLowerCase().includes("text/event-stream")) {
    failures.push("invalid content type");
  }
  if (!testCase.stream_completed) failures.push("stream incomplete");
  if (!output.trim()) failures.push("empty output");
  if (words > expect.max_words) failures.push(`${words}/${expect.max_words} words`);
  if (missing.length) failures.push(`missing: ${missing.join(", ")}`);
  if (forbidden.length) failures.push(`forbidden: ${forbidden.join(", ")}`);
  if (missingPatterns.length) failures.push(`missing patterns: ${missingPatterns.join(", ")}`);
  if (forbiddenPatterns.length) failures.push(`forbidden patterns: ${forbiddenPatterns.join(", ")}`);

  return {
    id: testCase.id,
    pass: failures.length === 0,
    words,
    max_words: expect.max_words,
    elapsed_ms: testCase.elapsed_ms,
    failures,
  };
});

console.table(rows);
const passed = rows.filter((row) => row.pass).length;
console.log(`${passed}/${rows.length} cases passed`);
process.exitCode = passed === rows.length ? 0 : 1;
