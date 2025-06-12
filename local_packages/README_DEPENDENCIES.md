# Local Package Overrides

## supabase_flutter 1.10.25

- Source: pub.dev
- Extraction: dart pub cache add supabase_flutter --version 1.10.25
- Custom edits:
  - Removed: sign_in_with_apple: ^5.0.0
  - Reason: Incompatible with compileSdk 35 & Android V2 embedding
