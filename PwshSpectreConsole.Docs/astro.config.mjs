import { defineConfig } from "astro/config";
import starlight from "@astrojs/starlight";
import sitemap from '@astrojs/sitemap';

import tailwind from "@astrojs/tailwind";

// https://astro.build/config
export default defineConfig({
  site: "https://pwshspectreconsole.com",
  integrations: [
    starlight({
      title: "PwshSpectreConsole",
      favicon: "/favicon.png",
      customCss: ["./src/tailwind.css"],
      social: {
        rss: "https://shaunlawrie.com/rss.xml",
        github: "https://github.com/ShaunLawrie/PwshSpectreConsole",
        blueSky: "https://bsky.app/profile/shaunlawrie.com",
        youtube: "https://www.youtube.com/@shaunlawrie",
      },
      components: {
        Head: './src/components/Head.astro',
      },
      sidebar: [
        {
          label: "Guides",
          items: [
            {
              label: "Install",
              link: "/guides/install/",
            },
            {
              label: "Getting Started",
              link: "/guides/get-started/",
            },
            {
              label: "Upgrading to v2",
              link: "/guides/upgrading-to-v2/",
            },
            {
              label: "FAQs",
              link: "/guides/faqs/",
            },
          ],
        },
        {
          label: "Command Reference",
          autogenerate: {
            directory: "reference",
          },
        },
      ],
    }),
    tailwind({
      applyBaseStyles: false,
    }),
    sitemap(),
  ]
});
