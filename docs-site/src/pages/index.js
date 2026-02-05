import React from 'react';
import Layout from '@theme/Layout';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';

export default function Home() {
    const { siteConfig } = useDocusaurusContext();
    return (
        <Layout
            title={siteConfig.title}
            description="Enterprise-grade AI agents for Claude Code">
            <main style={{
                display: 'flex',
                justifyContent: 'center',
                alignItems: 'center',
                height: '80vh',
                flexDirection: 'column',
                textAlign: 'center'
            }}>
                <h1 style={{ fontSize: '3rem', marginBottom: '1rem' }}>{siteConfig.title}</h1>
                <p style={{ fontSize: '1.5rem', marginBottom: '2rem' }}>{siteConfig.tagline}</p>
                <Link
                    className="button button--primary button--lg"
                    to="/docs/intro">
                    Get Started 🚀
                </Link>
            </main>
        </Layout>
    );
}
