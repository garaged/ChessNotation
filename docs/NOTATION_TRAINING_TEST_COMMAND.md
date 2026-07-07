Run the notation training variety tests on the validated simulator target:

```sh
xcodebuild test \
  -project ChessNotation.xcodeproj \
  -scheme ChessNotation \
  -destination 'platform=iOS Simulator,id=2EAAECDA-9648-453E-9C6B-1AAA4CD18234' \
  -only-testing:ChessNotationTests/NotationTrainingVarietyTests \
  -only-testing:ChessNotationTests/NotationTrainingHistoryCompatibilityTests
```
