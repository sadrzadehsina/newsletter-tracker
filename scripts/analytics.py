#!/usr/bin/env python3
"""
Newsletter Tracker Analytics Script

This script generates reading analytics and insights from your GitHub Issues.
Run this locally to get detailed statistics about your reading habits.
"""

import requests
import json
from datetime import datetime, timedelta
from collections import defaultdict, Counter
import argparse
import os


class NewsletterAnalytics:
    def __init__(self, owner, repo, token=None):
        self.owner = owner
        self.repo = repo
        self.token = token
        self.base_url = "https://api.github.com"
        self.headers = {
            "Accept": "application/vnd.github+json",
            "User-Agent": "Newsletter-Tracker-Analytics"
        }
        if token:
            self.headers["Authorization"] = f"token {token}"
    
    def get_issues(self, state="all", per_page=100):
        """Fetch all issues from the repository"""
        url = f"{self.base_url}/repos/{self.owner}/{self.repo}/issues"
        params = {"state": state, "per_page": per_page}
        
        all_issues = []
        page = 1
        
        while True:
            params["page"] = page
            response = requests.get(url, headers=self.headers, params=params)
            
            if response.status_code != 200:
                print(f"Error fetching issues: {response.status_code}")
                break
                
            issues = response.json()
            if not issues:
                break
                
            # Filter out pull requests
            issues = [issue for issue in issues if not issue.get("pull_request")]
            all_issues.extend(issues)
            page += 1
            
        return all_issues
    
    def analyze_reading_patterns(self):
        """Analyze reading patterns and generate insights"""
        issues = self.get_issues()
        
        # Basic statistics
        total_articles = len(issues)
        open_articles = len([i for i in issues if i["state"] == "open"])
        closed_articles = len([i for i in issues if i["state"] == "closed"])
        
        # Category analysis
        categories = Counter()
        sources = Counter()
        reading_times = Counter()
        
        # Time-based analysis
        weekly_saves = defaultdict(int)
        weekly_completions = defaultdict(int)
        
        for issue in issues:
            # Extract labels
            labels = [label["name"] for label in issue.get("labels", [])]
            
            # Count categories
            for label in labels:
                if label in ["tech", "business", "personal", "ai", "startups", "finance"]:
                    categories[label] += 1
                elif "brew" in label or "hacker" in label or "medium" in label:
                    sources[label] += 1
                elif "read" in label:
                    reading_times[label] += 1
            
            # Time analysis
            created_date = datetime.fromisoformat(issue["created_at"].replace("Z", "+00:00"))
            week_key = created_date.strftime("%Y-W%U")
            weekly_saves[week_key] += 1
            
            if issue["state"] == "closed" and issue.get("closed_at"):
                closed_date = datetime.fromisoformat(issue["closed_at"].replace("Z", "+00:00"))
                close_week = closed_date.strftime("%Y-W%U")
                weekly_completions[close_week] += 1
        
        return {
            "total_articles": total_articles,
            "open_articles": open_articles,
            "closed_articles": closed_articles,
            "completion_rate": round((closed_articles / total_articles * 100), 1) if total_articles > 0 else 0,
            "categories": dict(categories.most_common()),
            "sources": dict(sources.most_common()),
            "reading_times": dict(reading_times.most_common()),
            "weekly_saves": dict(weekly_saves),
            "weekly_completions": dict(weekly_completions)
        }
    
    def generate_report(self, analytics):
        """Generate a formatted analytics report"""
        report = f"""
# 📊 Newsletter Tracker Analytics Report
Generated on: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}

## 📈 Overview Statistics
- **Total Articles Saved:** {analytics['total_articles']}
- **Currently in Queue:** {analytics['open_articles']} 
- **Completed Reading:** {analytics['closed_articles']}
- **Completion Rate:** {analytics['completion_rate']}%

## 🏷️ Top Categories
"""
        
        for category, count in list(analytics['categories'].items())[:5]:
            percentage = round((count / analytics['total_articles'] * 100), 1)
            report += f"- **{category.title()}:** {count} articles ({percentage}%)\n"
        
        report += "\n## 📮 Top Sources\n"
        for source, count in list(analytics['sources'].items())[:5]:
            percentage = round((count / analytics['total_articles'] * 100), 1)
            report += f"- **{source.replace('-', ' ').title()}:** {count} articles ({percentage}%)\n"
        
        report += "\n## ⏱️ Reading Time Distribution\n"
        for time_type, count in analytics['reading_times'].items():
            percentage = round((count / analytics['total_articles'] * 100), 1)
            report += f"- **{time_type.replace('-', ' ').title()}:** {count} articles ({percentage}%)\n"
        
        # Recent activity (last 4 weeks)
        recent_weeks = sorted(analytics['weekly_saves'].keys())[-4:]
        report += "\n## 📅 Recent Activity (Last 4 Weeks)\n"
        
        for week in recent_weeks:
            saves = analytics['weekly_saves'].get(week, 0)
            completions = analytics['weekly_completions'].get(week, 0)
            report += f"- **Week {week}:** {saves} saved, {completions} completed\n"
        
        # Recommendations
        report += "\n## 💡 Insights & Recommendations\n"
        
        if analytics['completion_rate'] < 50:
            report += "- 📚 **Consider reducing intake:** Your completion rate is low. Try saving fewer articles to focus on quality reading.\n"
        elif analytics['completion_rate'] > 80:
            report += "- 🚀 **Great reading habits:** You're completing most articles! Consider exploring more challenging content.\n"
        
        if analytics['open_articles'] > 20:
            report += "- 📋 **Reading queue management:** You have many unread articles. Consider setting aside dedicated reading time.\n"
        
        # Find most active category
        if analytics['categories']:
            top_category = max(analytics['categories'], key=analytics['categories'].get)
            report += f"- 🎯 **Focus area:** You're most interested in **{top_category}** content. Consider creating a specialized collection.\n"
        
        return report


def main():
    parser = argparse.ArgumentParser(description="Generate newsletter tracker analytics")
    parser.add_argument("--owner", required=True, help="GitHub repository owner")
    parser.add_argument("--repo", required=True, help="GitHub repository name")
    parser.add_argument("--token", help="GitHub personal access token (optional)")
    parser.add_argument("--output", help="Output file path (optional)")
    
    args = parser.parse_args()
    
    # Try to get token from environment if not provided
    token = args.token or os.getenv("GITHUB_TOKEN")
    
    analytics = NewsletterAnalytics(args.owner, args.repo, token)
    
    print("🔍 Fetching issues and analyzing data...")
    data = analytics.analyze_reading_patterns()
    
    print("📊 Generating report...")
    report = analytics.generate_report(data)
    
    if args.output:
        with open(args.output, 'w') as f:
            f.write(report)
        print(f"📄 Report saved to {args.output}")
    else:
        print(report)


if __name__ == "__main__":
    main()