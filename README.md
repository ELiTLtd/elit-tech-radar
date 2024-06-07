# [ELiT's Tech Radar](https://techradar.englishlanguageitutoring.com)

[This Tech Radar](https://techradar.englishlanguageitutoring.com) describes the technology landscape through an ELiT lens. We've made this repo public partly because it helps us use the technology that generates the radar, and partly because it's interesting to see the technology we use at ELiT.

This is an _internal_ guide to our current favoured stack. It is intended to be a guide on what to use/do when starting a new project and provide forward looking direction for our actively developed projects.

Our internal policies are not captured on the radar. It doesn’t describe _how_ we work, only the tools and techniques we use to do so.  For the “how” of development work at ELiT please refer to our Confluence documentation.

## Quadrants

Our radar is divided into four quadrants:

* **Languages and Frameworks**

  Languages and frameworks that we use when building products.
* **Tools**

  These can be components, such as databases, software development tools, such as versions control systems; or more generic categories of tools, such as the notion of polyglot persistence.
* **Platforms**

  Things that we build software on top of such as .NET, SQL Server, Windows (etc).
* **Techniques**

  These include elements of a software development process, such as experience design; and structuring software, such as microservices.

We're following Thoughtworks approach here. For discussion on the quadrants, please see the [Thoughtworks Radar FAQ](https://www.thoughtworks.com/radar/faq)

## Rings

Each quadrant is sub divided into four rings and each item on the radar is positioned within one of those rings depending on our comfort with it:

* **Assess**

  The technology/technique has the potential to be valuable. To get something into “Assess”:

  * Provide a compelling reason to assess the technology.
  * Ideally, have plans for how to evaluate it in a reasonable time frame. 
  * Answer: “What would make us decide to move this to trial?”
* **Trial**

  The technology/technique has been assessed and has clear benefits. To move something into “Trial”: 

  * At least one team has plans to adopt this on a project that can support the risk.
  * Answer: “What would make us move this to Adopt?”
* **Adopt**

  The technology/technique is recommended for use by the majority of teams Consider it the default choice for new work.
* **Hold**

  We don't want to invest effort in this technology:

  * New projects should not use this technology.
  * Currently maintained projects need to evaluate migrating to a better solution.

## What Goes on the Radar?

Items on the Tech Radar should only be captured if the cost of change is high or the benefits of standardizing outweigh the drawbacks. Each item on the tech radar should be there for the the good of the entirety of ELiT. 

We are not producing a tech radar for the general tech community to consume, the tech radar is to guide our teams to build better software. Favour things that are going to be actioned and that fit our needs and tech stack rather over those that theoretically “could be useful.”

## What _Doesn’t_ Go on the Radar?

We only use the Tech Radar to capture decisions relevant to our current and future projects. We don’t use the Tech Radar to capture historical decisions that are no longer relevant. For example, we’d prefer to say the technology we use going forward rather than listing all the things we’ve stopped using.

## Who Contributes to the Radar?

The radar is open for anyone within ELiT to contribute to. Before contributing please read the [Contributing Guidelines](.github/CONTRIBUTING.md).

To propose a change or spark a discussion open a PR and fill out the description according to the template. New items will be reviewed by the team at the next Common Code Retro. To kick start the discussion post in the [`#dev` channel in Slack](https://team-elit.slack.com/archives/C017Z7RCS0Y).

## How is the Radar Built?

We use [Thoughtworks Tech Radar](https://github.com/thoughtworks/build-your-own-radar) to generate our Tech Radar. The radar is backed by a single CSV file (that should nicely [render](https://help.github.com/articles/rendering-csv-and-tsv-data/)). CSV files are parsed using `d3.js` so please see their [documentation](https://d3-wiki.readthedocs.io/zh_CN/latest/CSV) for escaping rules.

You can see the latest version at [techradar.englishlanguageitutoring.com](https://techradar.englishlanguageitutoring.com).

### Our Custom Radar Domain

Our radar is accessed via the custom domain [techradar.englishlanguageitutoring.com](https://techradar.englishlanguageitutoring.com). This is acting as a simple redirect to the ThoughtWorks radar with our [`./radar.csv`](./radar.csv) as input.

The redirect is accomplished using several AWS hosted resources:

1. An S3 bucket.

  Configured for static web hosting this lets us define the redirect rule that sends visitors to the ThoughtWorks radar pre-configured to load our own radar data.
2. A CloudFront distribution.

  This acts as a HTTPS middleman for the S3 bucket which otherwise would only be able to accept HTTP connections.
3. A Route53 domain entry.

  To connect our desired sub-domain to the CloudFront distribution and provide a nice, short, memorable URL from which to access our radar.

## Frequently Asked Questions

### It won't display properly!

Common causes of this happening are:

* Leaving blank lines at the bottom (make sure these are removed.)
* Forgetting to add a column (verify this by viewing it in GitHub's CSV display.)
* Bad escaping (remember to always use double quotes around fields and only ever use single or smart quotes inside.)
