# Board legibility manual acceptance

Use this checklist after installing the build from PR #30. It validates the rendered outcomes required by CN-SPEC-0028 that cannot be reduced to source constants or pixel arithmetic.

## Device matrix

Run notation training, Piece Movement, and Position Recall on:

| Device class | Dynamic Type | Required focus |
| --- | --- | --- |
| Small iPhone (5.4-inch class) | Default | Board remains dominant, pieces are easy to identify, primary action remains reachable |
| Large iPhone (6.7-inch class) | Default | Board is centered and not visually diluted by surrounding panels |
| iPad 11-inch class | Default | Board hierarchy remains clear without an oversized or sparse composition |
| Small iPhone | Accessibility XXXL or larger | Scroll reaches controls; board and instructions remain understandable |

## Steps

1. Select each of Tournament, Marble, Wood, and Metal in Settings. Close Settings and confirm the selection is retained.
2. Open an evaluated Notation Training game so the evaluation bar is present.
3. For each theme, inspect white and black pieces on both square colors. Confirm neither side merges into its adverse square and pawn size is comparable in visual weight to the other pieces.
4. Enable coordinates. Confirm labels remain visible without hiding piece identity.
5. Advance to a highlighted move. Confirm the arrow remains visible without making source or destination pieces ambiguous.
6. Open Piece Movement. Confirm the source piece, selected squares, friendly marker, and enemy marker remain distinct.
7. Open Position Recall. Confirm reconstructed pieces remain readable over the reconstructed-state overlay and that masked markers are not confused with pieces.
8. With large accessibility text, confirm the board and the next primary action can both be reached by scrolling.

## Pass criteria

- Pass: all four themes remain immediately scannable; no piece is visually lost, clipped, or mistaken for the opposite side; state markings retain a distinct form as well as colour.
- Fail: any side blends into a square, a pawn is markedly smaller than its neighbours, a contour looks like a second piece, or a control becomes unreachable.

Record the tested device, OS, theme, and a screenshot for each failure. Do not approve a visual change solely from a simulator screenshot if it has not passed the small-iPhone check.
