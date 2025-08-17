# Trending T-Shirt Automation

An automated system that discovers trending content from Reddit and generates compliant t-shirt design concepts for Amazon Merch on Demand.

## Overview

This n8n workflow automates the process of:
1. **Content Discovery**: Fetches trending posts from Reddit's top daily content
2. **Compliance Review**: Uses AI to evaluate content against Amazon Merch on Demand policies
3. **Design Generation**: Creates original t-shirt concepts for approved content

## Workflow Architecture

```
Manual Trigger → Reddit API → Parse Data → Amazon TOS Review → Filter → Design Generation
```

### Components

- **Reddit Data Source**: Fetches top 10 daily posts from r/all
- **Content Parser**: Extracts relevant data (title, upvotes, comments, subreddit)
- **Amazon TOS Review Agent**: AI-powered compliance checking using OpenAI GPT-4o
- **Content Filter**: Only processes approved content
- **T-Shirt Design Agent**: Generates creative concepts using OpenAI GPT-4o-mini

## Features

✅ **Automated Content Discovery** from trending Reddit posts  
✅ **Comprehensive Compliance Checking** for Amazon Merch policies  
✅ **AI-Powered Design Generation** with structured output  
✅ **Built-in Content Filtering** to ensure policy adherence  
✅ **Structured JSON Output** for easy integration  

## Amazon Merch Compliance

The workflow includes comprehensive checking for:

- **Intellectual Property**: No trademarks, logos, copyrighted characters
- **Offensive Content**: No discriminatory, explicit, or violent content
- **Political Content**: No campaigning or election-related material
- **Platform Integrity**: No review manipulation or trust violations

## Prerequisites

### Required Services
- [n8n](https://n8n.io/) automation platform
- [Reddit API](https://www.reddit.com/dev/api/) access
- [OpenAI API](https://openai.com/api/) key

### Required n8n Nodes
- Manual Trigger
- HTTP Request
- Code (JavaScript)
- LangChain Agent
- LangChain OpenAI Chat Model
- LangChain Structured Output Parser

## Setup Instructions

### 1. Import Workflow
1. Copy the workflow JSON from `n8n-workflows/trending-tshirt-automation.json`
2. In n8n, go to **Workflows** → **Import from JSON**
3. Paste the JSON and save

### 2. Configure Credentials

#### Reddit API (OAuth2)
1. Create a Reddit app at https://www.reddit.com/prefs/apps
2. Set up OAuth2 credentials in n8n:
   - **Authorization URL**: `https://www.reddit.com/api/v1/authorize`
   - **Access Token URL**: `https://www.reddit.com/api/v1/access_token`
   - **Client ID**: Your Reddit app client ID
   - **Client Secret**: Your Reddit app client secret
   - **Scope**: `read`

#### OpenAI API
1. Get your API key from https://platform.openai.com/api-keys
2. Add OpenAI credentials in n8n with your API key

### 3. Update Configuration
- Update the Reddit User-Agent in the HTTP Request node
- Verify model selections (GPT-4o for compliance, GPT-4o-mini for design)

## Usage

1. **Manual Execution**: Click "Execute workflow" to run once
2. **Scheduled Execution**: Add a Schedule Trigger for automated runs
3. **Webhook Trigger**: Replace Manual Trigger with Webhook for external triggering

## Output Format

The workflow generates structured design concepts:

```json
{
  "topic": "Original trending topic",
  "slogans": [
    {
      "text": "Catchy Slogan",
      "design_brief": {
        "style_tags": ["bold", "modern", "minimalist"],
        "color_palette": ["black", "white"],
        "composition": "text-only",
        "background": "transparent",
        "notes": "Clean, readable design"
      }
    }
  ]
}
```

## Customization

### Modify Content Sources
- Change subreddit in the Reddit API URL
- Adjust time filter (`day`, `week`, `month`, `year`, `all`)
- Modify post limit (currently 10)

### Enhance Compliance Rules
- Update the Amazon TOS Review Agent prompt
- Add custom filtering criteria
- Implement additional validation steps

### Design Generation
- Modify the T-Shirt Design Agent prompt
- Adjust slogan requirements
- Customize output schema

## Security Notes

🔒 **Credentials**: Never commit API keys or credentials to version control  
🔒 **User-Agent**: Update Reddit User-Agent with your username  
🔒 **Rate Limits**: Respect API rate limits for Reddit and OpenAI  

## Monitoring & Debugging

- Check n8n execution logs for errors
- Monitor OpenAI API usage and costs
- Review filtered content for compliance accuracy
- Test with known compliant/non-compliant content

## Cost Considerations

- **OpenAI API**: ~$0.01-0.05 per execution depending on content volume
- **Reddit API**: Free tier available
- **n8n**: Depends on hosting (self-hosted vs cloud)

## Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Test thoroughly
4. Submit a pull request

## License

MIT License - see LICENSE file for details

## Disclaimer

This tool is for educational and automation purposes. Users are responsible for:
- Compliance with all platform policies
- Appropriate use of generated content
- Respecting intellectual property rights
- Following applicable laws and regulations

---

**🚀 Happy Automating!**