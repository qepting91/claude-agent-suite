// Docusaurus configuration for Claude Agent Suite
// Run `npm install` in this directory before building

const config = {
    title: 'Claude Agent Suite',
    tagline: 'Enterprise-grade AI agents for Claude Code',

    url: 'https://qepting91.github.io',
    baseUrl: '/claude-agent-suite/',

    organizationName: 'qepting91',
    projectName: 'claude-agent-suite',

    onBrokenLinks: 'throw',
    onBrokenMarkdownLinks: 'throw',

    i18n: {
        defaultLocale: 'en',
        locales: ['en'],
    },

    presets: [
        [
            'classic',
            {
                docs: {
                    sidebarPath: './sidebars.js',
                    editUrl: 'https://github.com/qepting91/claude-agent-suite/tree/main/docs-site/',
                },
                blog: false,
                theme: {
                    customCss: './src/css/custom.css',
                },
            },
        ],
    ],

    themeConfig: {
        navbar: {
            title: 'Claude Agent Suite',
            items: [
                {
                    type: 'docSidebar',
                    sidebarId: 'tutorialSidebar',
                    position: 'left',
                    label: 'Documentation',
                },
                {
                    href: 'https://github.com/qepting91/claude-agent-suite',
                    label: 'GitHub',
                    position: 'right',
                },
            ],
        },
        footer: {
            style: 'dark',
            links: [
                {
                    title: 'Docs',
                    items: [
                        {
                            label: 'Getting Started',
                            to: '/docs/intro',
                        },
                        {
                            label: 'Agent Library',
                            to: '/docs/library',
                        },
                    ],
                },
                {
                    title: 'Community',
                    items: [
                        {
                            label: 'GitHub',
                            href: 'https://github.com/qepting91/claude-agent-suite',
                        },
                    ],
                },
            ],
            copyright: `Copyright © ${new Date().getFullYear()} Claude Agent Suite. Built with Docusaurus.`,
        },
        prism: {
            additionalLanguages: ['bash', 'json', 'yaml', 'powershell'],
        },
    },
};

module.exports = config;
