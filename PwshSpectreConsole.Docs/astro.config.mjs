import { defineConfig } from "astro/config";
import starlight from "@astrojs/starlight";

import tailwind from "@astrojs/tailwind";

// https://astro.build/config
export default defineConfig({
  integrations: [
    starlight({
      title: "PwshSpectreConsole",
      editLink: {
        baseUrl:
          "https://github.com/ShaunLawrie/PwshSpectreConsole/edit/main/PwshSpectreConsole.Docs/",
      },
      favicon: "/favicon.png",
      customCss: ["./src/tailwind.css"],
      social: {
        github: "https://github.com/ShaunLawrie/PwshSpectreConsole",
        twitter: "https://twitter.com/Shaun_Lawrie",
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
              label: "Upgrading to 2.0",
              link: "/guides/upgrading-to-2-0/",
              badge: {
                text: "New",
                variant: "tip",
              },
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
  ]
});
