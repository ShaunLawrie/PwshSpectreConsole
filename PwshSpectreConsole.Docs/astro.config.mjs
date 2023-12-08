import { defineConfig } from "astro/config";
import starlight from "@astrojs/starlight";

import tailwind from "@astrojs/tailwind";

// https://astro.build/config
export default defineConfig({
  integrations: [
    starlight({
      title: "PwshSpectreConsole",
      editLink: {
        baseUrl: "https://github.com/ShaunLawrie/PwshSpectreConsole/edit/main/PwshSpectreConsole.Docs/",
      },
      favicon: "/favicon.png",
      customCss: ["./src/tailwind.css"],
      social: {
        github: "https://github.com/ShaunLawrie/PwshSpectreConsole",
        twitter: "https://twitter.com/Shaun_Lawrie",
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
  ],
});
