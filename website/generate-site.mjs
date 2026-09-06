import { cp, mkdir, readFile, readdir, rm, writeFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

const websiteDir = path.dirname(fileURLToPath(import.meta.url));
const repoDir = path.resolve(websiteDir, "..");
const sourceDir = path.join(websiteDir, "src");
const outputDir = path.join(websiteDir, "dist");
const knowledgeDir = path.join(outputDir, "learn");
const includeKnowledge = process.env.DHEERIX_INCLUDE_KNOWLEDGE === "1";
const excluded = new Set([".git", ".github", "node_modules", "output", "outputs", "dist"]);

const sectionDetails = {
  interviews: ["Interview Preparation", "Execution guides, answer frameworks, and mock interview material.", 1],
  grind75: ["Coding Practice", "Seventy-five algorithm problems organized for deliberate practice.", 2],
  projects: ["Project Deep Dives", "Architecture decisions, production lessons, and measurable outcomes.", 3],
  architecture: ["Architecture", "Patterns, decisions, and engineering design principles.", 4],
  "master-profile": ["Professional Profile", "Engineering identity, leadership philosophy, and career narrative.", 5],
  "master-resume": ["Experience", "Detailed professional experience and technical impact.", 6],
  career: ["Career Development", "Roadmaps, timelines, and professional growth plans.", 7],
  "career-assets": ["Career Assets", "Role-specific positioning and interview collateral.", 8],
  leadership: ["Leadership", "Technical leadership practices and evidence.", 9],
  evidence: ["Evidence Logs", "Recognition, outcomes, and leadership evidence.", 10],
  stories: ["Engineering Stories", "Narratives from production engineering work.", 11],
  cheatsheets: ["Cheatsheets", "Compact reference maps across software engineering topics.", 12],
  docs: ["Repository Guides", "Principles, style, and review checklists.", 13],
};

function humanize(value) {
  return value.replace(/^\d+[-_]?/, "").replace(/[-_]/g, " ").replace(/\b\w/g, c => c.toUpperCase());
}

async function findMarkdown(directory, relative = "") {
  const files = [];
  for (const entry of await readdir(directory, { withFileTypes: true })) {
    if (entry.name.startsWith(".") || excluded.has(entry.name)) continue;
    const nextRelative = path.join(relative, entry.name);
    if (entry.isDirectory()) files.push(...await findMarkdown(path.join(directory, entry.name), nextRelative));
    else if (entry.isFile() && entry.name.toLowerCase().endsWith(".md")) files.push(nextRelative);
  }
  return files;
}

await rm(outputDir, { recursive: true, force: true });
await mkdir(outputDir, { recursive: true });
await cp(path.join(repoDir, "portfolio", "dheerix"), outputDir, { recursive: true });
await writeFile(path.join(outputDir, ".nojekyll"), "\n");

if (includeKnowledge) {
  await cp(sourceDir, knowledgeDir, { recursive: true });
  const documents = [];
  for (const relativePath of await findMarkdown(repoDir)) {
    const normalizedPath = relativePath.split(path.sep).join("/");
    const content = await readFile(path.join(repoDir, relativePath), "utf8");
    const section = normalizedPath.split("/")[0];
    const [sectionTitle, sectionDescription, sectionOrder] = sectionDetails[section] || [humanize(section), "Additional notes and reference material.", 50];
    const title = content.match(/^#\s+(.+)$/m)?.[1]?.replace(/[*_`]/g, "").trim() || humanize(path.basename(normalizedPath, ".md"));
    const description = content.replace(/```[\s\S]*?```/g, " ").split("\n").map(line => line.trim()).find(line => line && !/^(#|\||-|\d+\.)/.test(line))?.replace(/[*_`>]/g, "").slice(0, 180) || "Open this document to explore the material.";
    documents.push({ path: normalizedPath, title, description, section, sectionTitle, sectionDescription, sectionOrder, words: content.trim().split(/\s+/).filter(Boolean).length, content });
  }
  documents.sort((a, b) => a.sectionOrder - b.sectionOrder || a.path.localeCompare(b.path, undefined, { numeric: true }));
  await writeFile(path.join(knowledgeDir, "documents.json"), JSON.stringify({ generatedAt: new Date().toISOString(), documents }));
  console.log(`Generated ${documents.length} local-only documents in website/dist/learn`);
} else {
  console.log("Generated public portfolio without the Knowledge library");
}
