# Verra: UI/UX design

## Concept
Verra is a multi-category store where you can describe what you want ("a black backpack under 5000 rupees"), say it aloud, or inspect it in 3D. The design stays quiet so products carry the colour.

## Tokens
| Role | Light | Dark |
|---|---|---|
| Ink (text, primary button) | `#16204A` | `#FFFFFF` |
| Cobalt (links, selection, AI cues) | `#3550F5` | `#B4C0FF` |
| Citron (single accent: sale badge, primary CTA in dark mode, success) | `#D6F24B` | `#D6F24B` |
| Background | `#F4F5FA` | `#0E1226` |
| Surface | `#FFFFFF` | `#181D3A` |
| Slate (secondary text) | `#6B7194` | `#6B7194` |

- **Type:** Plus Jakarta Sans only. Weights 800 for headings and prices, 700 for names and buttons, 500 for body.
- **Shape:** 16 px for inputs and buttons, 24 px for cards and banners, full circles for icon buttons.
- **Spacing:** 4 / 8 / 16 / 24 / 32. Screen gutters are 20.
- **Motion:** only in response to a touch (heart pop, page slide, voice pulse), plus the splash logo and the order-success check.
- **Responsive:** product grids use `maxCrossAxisExtent`, so phones get 2 columns, large phones and tablets 3 to 4.

## Navigation map
```
Splash -> Onboarding (3) -> Login <-> Register / Forgot password
                               |
                         Shell (bottom bar)
 Home | Categories | Search | Wishlist | Profile
  |        |           |                  |
  |        +-> Product list (sort, filter)|-> My orders, Addresses, Settings (dark mode), Edit profile
  +-> Cart -> Checkout -> Order success   +-> Admin sign in -> Dashboard
  +-> Voice search                              Overview | Products | Categories | Orders
Product list / Search / Wishlist -> Product detail -> 3D viewer, Buy now -> Checkout
```

## Key screen wireframes
```
HOME                          PRODUCT DETAIL                CART
+------------------------+    +------------------------+    +------------------------+
| Good to see you,   [bag]|   | <                 v  bag|   | Cart (2)               |
| Ayesha                  |   | [ large image / swipe ]|    | [img] Name        qty  |
| [AI Try "black bag.." mic|  |            [View in 3D]|    | [img] Name        qty  |
| [ banner carousel     ] |   |------------------------|    |------------------------|
| (o)(o)(o)(o)(o) category|   | Name              4.7* |    | Subtotal      Rs 8,400 |
| Featured  > [card][card]|   | Rs 4,200  Rs 5,600     |    | Delivery          Free |
| Trending  [card][card]  |   | Colour (o)(o)(o) Size  |    | Total         Rs 8,400 |
| Recommended > ...       |   | Reviews                |    | [Proceed to checkout]  |
+------------------------+    | [Add to cart][Buy now] |    +------------------------+
 Home Cat Search Wish Me      +------------------------+
```

## AI search behaviour
Natural-language queries are parsed into **price cap**, **colour**, **category** and **keywords**, shown back to the user as "Understood" chips so results never feel arbitrary. Voice search feeds the same parser.

## Update: visual direction from reference images
Warm off-white background (`#FBF6F1`), pale pill search field, pastel circular category icons, black primary buttons (white in dark mode), red-orange discount badges, and an orange accent (`#E8622C`) reserved for the voice microphone. Product pages use a soft image panel, a boxed size row and pastel colour swatches; dark mode inverts to near-black with a white button.
