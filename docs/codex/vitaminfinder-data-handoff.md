# VitaminFinder Data Handoff

## Status
Completed on 2026-04-25.

## What Changed
- Extracted the bundled VitaminFinder dataset from `https://vitaminfinder.lovable.app/`.
- Added `backend/migrations/00006_vitaminfinder_percent_dv_sources.sql`.
  - 342 foods imported.
  - 27 nutrient profiles imported.
  - 7,637 non-zero percent-Daily-Value food nutrient rows imported.
  - Every imported food has a remote `image_url`.
- Added `backend/migrations/00007_dedupe_adult_dri_values.sql`.
  - Cleans duplicate adult DRI rows caused by nullable `sex`.
  - Adds a partial unique index for adult DRI rows where `sex IS NULL`.
- Updated the backend `/v1/foods` endpoint:
  - Supports `nutrient=<code>` for source ranking.
  - Returns `dri_percent` for nutrient-ranked results.
  - Merges raw `food_nutrients` and imported percent-DV profiles in food details.
- Updated Flutter:
  - Explore now browses vitamins, minerals, and macros.
  - Nutrient detail pages now support all 27 imported nutrients.
  - Top sources load from the live backend.
  - Food detail shows imported percent-DV profiles without treating them as raw USDA per-100g data.

## Important Data Note
VitaminFinder's own UI labels the food values as `% Daily Value`. It does not expose raw nutrient amounts or a reliable serving-size basis. To keep tracker math correct, those values are stored in `food_nutrient_daily_values`, not in `food_nutrients`.

USDA/raw nutrient amounts should still be added later for any imported food that needs accurate meal logging.

## Verification
- `go test ./...` passed.
- `flutter test` passed.
- `flutter analyze` passed.
- `flutter build web` passed.
- Applied migrations through version 7 against local Docker Postgres.
- Rebuilt/restarted local Docker API.
- Checked:
  - `GET /v1/foods?nutrient=C&limit=3`
  - `GET /v1/foods?nutrient=Kp&limit=3`
  - `GET /v1/foods/018f0000-0000-7000-8003-000000000001`
- Visual screenshots:
  - `build/visual-vitaminfinder-vitamin-c.png`
  - `build/visual-vitaminfinder-apple-detail.png`
  - `build/visual-vitaminfinder-app-home.png`

## Browser Use Note
Browser Use still failed because the Node REPL resolves `C:\nvm4w\nodejs\node.exe` at `v22.12.0`, while the plugin requires `>= v22.22.0`. Visual verification used bundled Node `v24.14.0` with Playwright and system Chrome instead.

## Reference Sources Used
- VitaminFinder source site: `https://vitaminfinder.lovable.app/`
- USDA FoodData Central API guide: `https://fdc.nal.usda.gov/api-guide`
- NIH ODS vitamin/mineral fact sheets list: `https://ods.od.nih.gov/factsheets/list-VitaminsMinerals/`
- FDA Daily Value explainer: `https://www.fda.gov/food/nutrition-facts-label/daily-value-nutrition-and-supplement-facts-labels`
