# Market-Facing Portfolio — Deployment Guide

Plain static HTML/CSS site. No build step, no dependencies — this is the fastest possible path to a live URL on GitHub Pages.

## 1. Fill in the content

Search each `.html` file for bracketed placeholders like `[Company Name]` and boxes marked:

```
<p class="todo">TODO — ...</p>
```

Priority order given the deadline:
1. **index.html** — record your video, embed it (see comment in the file), and confirm the Hybrid Track bridge copy matches your actual narrative.
2. **resume.html** — drop your resume PDF into `assets/resume.pdf` (create the `assets` folder if needed).
3. **projects.html** — swap in your two consulting deliverables + the SQL project, each with a real quantified outcome.
4. **experience.html**, **commercial-awareness.html**, **qualifications.html** — fill in as time allows; these carry less rubric weight but are still graded.

Also replace `[Last Name]`, `you@email.com`, and the LinkedIn URL sitewide (Find & Replace across files).

## 2. Push to GitHub

From this folder:

```bash
git init
git add .
git commit -m "Initial portfolio"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git push -u origin main
```

(Create the empty repo on GitHub first at github.com/new — don't initialize it with a README so there's no merge conflict.)

## 3. Turn on GitHub Pages

1. On GitHub, go to your repo → **Settings** → **Pages**.
2. Under "Build and deployment," set **Source** to `Deploy from a branch`.
3. Set **Branch** to `main` and folder to `/ (root)`. Save.
4. Wait ~1 minute, then your site is live at:
   `https://YOUR_USERNAME.github.io/YOUR_REPO/`

No password protection is applied by default — it's public, which satisfies the assignment's access requirement automatically.

## 4. Test on mobile before submitting

Open the live URL on your phone. Check that:
- The nav collapses into the "MENU" toggle and opens/closes correctly
- The video plays inline
- The resume embed or its Download/Open buttons work
- Nothing overflows horizontally

## 5. Submit

Paste the live `github.io` URL into Canvas, and in the Comments box type exactly: **Hybrid Track**
