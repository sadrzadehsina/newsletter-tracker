# 📁 Newsletter Tracker File Structure

## 📂 Directory Overview

```
newsletter-tracker/
├── 📄 README.md                     # Main dashboard and navigation
├── 📁 .github/                      # GitHub-specific configurations
│   ├── 📁 ISSUE_TEMPLATE/           # Templates for creating articles
│   └── 📁 workflows/                # GitHub Actions for automation
├── 📁 articles/                     # Current articles being processed
├── 📁 archives/                     # Organized historical articles
│   ├── 📁 by-year/                  # Articles organized by year
│   └── 📁 by-source/                # Articles organized by newsletter source
├── 📁 collections/                  # Curated collections and reading lists
├── 📁 docs/                         # Documentation and guides
├── 📁 scripts/                      # Automation and utility scripts
└── 📁 templates/                    # Article and note templates
```

## 🎯 How Each Folder Works

### 📁 `.github/`
**Purpose:** GitHub-specific automation and templates
- `ISSUE_TEMPLATE/` - Standardized forms for creating article issues
- `workflows/` - GitHub Actions for automation (weekly summaries, auto-labeling)

### 📁 `articles/`
**Purpose:** Active article management
- Store full article text when needed
- Temporary workspace for processing long articles
- Backup storage for important content

### 📁 `archives/`
**Purpose:** Long-term organization
- `by-year/` - Annual reading summaries and highlights
- `by-source/` - Newsletter-specific collections and analytics

### 📁 `collections/`
**Purpose:** Curated reading lists
- Themed collections (e.g., "AI Revolution", "Startup Advice")
- Reading challenges and goals
- Best-of lists and recommendations

### 📁 `docs/`
**Purpose:** System documentation
- Usage guides and tutorials
- Tips and best practices
- System evolution and updates

### 📁 `scripts/`
**Purpose:** Automation and utilities
- Data export/import tools
- Analytics and reporting scripts
- Integration helpers

### 📁 `templates/`
**Purpose:** Consistency tools
- Article summary templates
- Note-taking formats
- Issue creation guides

## 🔄 Workflow Integration

1. **GitHub Issues** serve as the primary database
2. **Markdown files** provide backup and detailed analysis
3. **Scripts** automate repetitive tasks
4. **Templates** ensure consistency
5. **Collections** curate valuable content

This structure supports both the immediate GitHub Issues workflow and long-term knowledge management.