/** @type {import('@docusaurus/plugin-content-docs').SidebarsConfig} */
const sidebars = {
    tutorialSidebar: [
        'intro',
        'library',
        {
            type: 'category',
            label: 'Guides',
            items: ['agent-team-guide', 'security-skills'],
        },
    ],
};

module.exports = sidebars;
